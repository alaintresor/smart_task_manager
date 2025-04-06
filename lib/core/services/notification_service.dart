import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) {
      debugPrint('NotificationService already initialized');
      return;
    }
    
    try {
      debugPrint('Initializing notification service...');
      tz.initializeTimeZones();
      // Use local timezone instead of UTC for better scheduling accuracy
      try {
        tz.setLocalLocation(tz.getLocation('America/New_York')); // You should replace this with dynamic timezone detection
      } catch (e) {
        // Fallback to UTC if local timezone is not available
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      final androidSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
      final iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          debugPrint('Received iOS notification: $id, $title, $body, $payload');
        },
      );

      if(kIsWeb){
        // Web-specific initialization
    
        return;
      }
      
      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        
      );

      // Set initialization flag before actual initialization to prevent race conditions
      _initialized = true;

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );
      
      debugPrint('Notification service initialized successfully');
      
      // Check and request permissions
      if (Platform.isAndroid) {
        await _requestAndroidPermissions();
      } else if (Platform.isIOS) {
        await _requestIOSPermissions();
      }
    } catch (e) {
      // Reset initialization flag if initialization fails
      _initialized = false;
      debugPrint('Error initializing notification service: $e');
      rethrow;
    }
  }

  static Future<void> _requestAndroidPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
              
      if (androidImplementation != null) {
        // Request notification permission
        final bool? permissionGranted = await androidImplementation.requestNotificationsPermission();
        debugPrint('Android notification permission granted: $permissionGranted');
        
        // Request exact alarm permission
        final bool? exactAlarmsGranted = await androidImplementation.requestExactAlarmsPermission();
        debugPrint('Android exact alarms permission granted: $exactAlarmsGranted');

        // Check if exact alarms are actually available
        final bool? hasExactAlarms = await androidImplementation.canScheduleExactNotifications();
        debugPrint('Android can schedule exact notifications: $hasExactAlarms');
      }
    } catch (e) {
      debugPrint('Error requesting Android permissions: $e');
      // Don't rethrow here to prevent app crashes during permission request
      // Instead, log the error and continue
    }
  }

  static Future<bool> checkExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;
    
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
              
      if (androidImplementation != null) {
        final bool? hasExactAlarms = await androidImplementation.canScheduleExactNotifications();
        return hasExactAlarms ?? false;
      }
    } catch (e) {
      debugPrint('Error checking exact alarm permission: $e');
    }
    return false;
  }
  
  static Future<void> _requestIOSPermissions() async {
    try {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
              
      if (iosImplementation != null) {
        final bool? granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('iOS notification permissions granted: $granted');
      }
    } catch (e) {
      debugPrint('Error requesting iOS permissions: $e');
      // Don't rethrow here to prevent app crashes during permission request
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized, initializing now...');
      await init();
    }
    
    try {
      debugPrint('Showing notification: $id, $title, $body');
      
      const androidDetails = AndroidNotificationDetails(
        'task_channel',
        'Task Reminders',
        channelDescription: 'Reminder notifications for tasks',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(id, title, body, details, payload: payload);
      debugPrint('Notification shown successfully');
    } catch (e) {
      debugPrint('Error showing notification: $e');
      // Log error but don't rethrow to prevent app crashes
    }
  }

  static Future<List<PendingNotificationRequest>> checkPendingNotifications() async {
    try {
      if (!_initialized) {
        await init();
      }
      final pendingNotifications = await _notifications.pendingNotificationRequests();
      debugPrint('Pending notifications: ${pendingNotifications.length}');
      for (var notification in pendingNotifications) {
        debugPrint('Pending notification: id=${notification.id}, title=${notification.title}, body=${notification.body}');
      }
      return pendingNotifications;
    } catch (e) {
      debugPrint('Error checking pending notifications: $e');
      return [];
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  }) async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized, initializing now...');
      await init();
    }
    
    try {
      debugPrint('Scheduling notification: $id, $title, $body at $dateTime');
      
      // Ensure the scheduled time is in the future
      final now = DateTime.now();
      if (dateTime.isBefore(now)) {
        debugPrint('Warning: Scheduled time is in the past, adjusting to now + 5 seconds');
        dateTime = now.add(const Duration(seconds: 5));
      }
      
      // Check if we have exact alarm permission on Android
      if (Platform.isAndroid) {
        final hasExactAlarms = await checkExactAlarmPermission();
        if (!hasExactAlarms) {
          debugPrint('Exact alarms not available, requesting permission...');
          final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
              _notifications.resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
          if (androidImplementation != null) {
            await androidImplementation.requestExactAlarmsPermission();
          }
        }
      }
      
      final androidDetails = const AndroidNotificationDetails(
        'task_channel',
        'Task Reminders',
        channelDescription: 'Reminder notifications for tasks',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableLights: true,
        fullScreenIntent: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Get current timezone
      tz.TZDateTime scheduledDate = tz.TZDateTime.from(dateTime, tz.local);
      debugPrint('Scheduling for: $scheduledDate');
      
      // Calculate seconds from now
      final int secondsFromNow = dateTime.difference(now).inSeconds;
      debugPrint('Scheduling notification in $secondsFromNow seconds from now');
      
      // Use zonedSchedule with the correctly formatted TZDateTime
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidAllowWhileIdle: true, // Allow notification when device is in low-power idle modes
        uiLocalNotificationDateInterpretation: 
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      
      // Verify the notification was scheduled
      await Future.delayed(const Duration(milliseconds: 500));
      final pendingNotifications = await checkPendingNotifications();
      if (pendingNotifications.any((notification) => notification.id == id)) {
        debugPrint('✅ Notification scheduled successfully and verified');
      } else {
        debugPrint('❌ Failed to verify scheduled notification');
      }
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      // Log error but don't rethrow to prevent app crashes during scheduling
    }
  }

  static Future<void> cancel(int id) async {
    try {
      debugPrint('Cancelling notification: $id');
      await _notifications.cancel(id);
      debugPrint('Notification cancelled successfully');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
      // Log error but don't rethrow to prevent app crashes
    }
  }

  static Future<void> cancelAll() async {
    try {
      debugPrint('Cancelling all notifications');
      await _notifications.cancelAll();
      debugPrint('All notifications cancelled successfully');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }
}