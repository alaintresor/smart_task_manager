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
      tz.setLocalLocation(tz.getLocation('UTC')); // Set a default timezone

      final androidSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
      final iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          debugPrint('Received iOS notification: $id, $title, $body, $payload');
        },
      );
      
      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );
      
      debugPrint('Notification service initialized successfully');
      _initialized = true;
      
      // Check and request permissions
      if (Platform.isAndroid) {
        await _requestAndroidPermissions();
      } else if (Platform.isIOS) {
        await _requestIOSPermissions();
      }
    } catch (e) {
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
      rethrow;
    }
  }

  static Future<bool> checkExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;
    
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    if (androidImplementation != null) {
      final bool? hasExactAlarms = await androidImplementation.canScheduleExactNotifications();
      return hasExactAlarms ?? false;
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
      rethrow;
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
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

      await _notifications.show(id, title, body, details);
      debugPrint('Notification shown successfully');
    } catch (e) {
      debugPrint('Error showing notification: $e');
      rethrow;
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized, initializing now...');
      await init();
    }
    
    try {
      debugPrint('Scheduling notification: $id, $title, $body at $dateTime');
      
      // Check if we have exact alarm permission on Android
      if (Platform.isAndroid) {
        final hasExactAlarms = await checkExactAlarmPermission();
        if (!hasExactAlarms) {
          debugPrint('Exact alarms not available, requesting permission...');
          final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
              _notifications.resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
          await androidImplementation?.requestExactAlarmsPermission();
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

      final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);
      debugPrint('Scheduling for: $scheduledDate');
      
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      debugPrint('Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow;
    }
  }

  static Future<void> cancel(int id) async {
    try {
      debugPrint('Cancelling notification: $id');
      await _notifications.cancel(id);
      debugPrint('Notification cancelled successfully');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
      rethrow;
    }
  }
}
