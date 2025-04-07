import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_task_manager/data/models/task.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;

// Import with alias to resolve the name conflict
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin;
  bool _initialized = false;

  NotificationService({required this.notificationsPlugin});

  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('NotificationService already initialized');
      return;
    }
    
    try {
      debugPrint('Initializing notification service...');
      
      // Initialize timezone data
      tz.initializeTimeZones();
      // Use local timezone instead of UTC for better scheduling accuracy
      try {
        // You should replace this with dynamic timezone detection for production
        tz.setLocalLocation(tz.getLocation('America/New_York')); 
      } catch (e) {
        // Fallback to UTC if local timezone is not available
        tz.setLocalLocation(tz.getLocation('UTC'));
        debugPrint('Failed to set local timezone: $e');
      }

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification,
      );
      
      if (kIsWeb) {
        // Web-specific initialization if needed
        _initialized = true;
        return;
      }
      
      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      
      // Set initialization flag before actual initialization to prevent race conditions
      _initialized = true;
      
      await notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      );
      
      debugPrint('Notification service initialized successfully');
      
      // Check and request permissions based on platform
      if (Platform.isAndroid) {
        await _requestAndroidPermissions();
      } else if (Platform.isIOS) {
        await _requestIOSPermissions();
      }
    } catch (e) {
      // Reset initialization flag if initialization fails
      _initialized = false;
      debugPrint('Error initializing notification service: $e');
      // Don't rethrow to prevent app crashes
    }
  }

  Future<void> _requestAndroidPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          notificationsPlugin.resolvePlatformSpecificImplementation<
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
    }
  }

  Future<bool> checkExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;
    
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          notificationsPlugin.resolvePlatformSpecificImplementation<
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
  
  Future<void> _requestIOSPermissions() async {
    try {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          notificationsPlugin.resolvePlatformSpecificImplementation<
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

  Future<void> requestPermissions() async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized, initializing now...');
      await initialize();
    }
    
    if (Platform.isAndroid) {
      await _requestAndroidPermissions();
    } else if (Platform.isIOS) {
      await _requestIOSPermissions();
    }
  }

  Future<void> scheduleTaskReminder(Task task) async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized, initializing now...');
      await initialize();
    }
    
    try {
      if (task.dueDate.isAfter(DateTime.now())) {
        // Schedule for 1 hour before due date
        final scheduleTime = task.dueDate.subtract(const Duration(hours: 1));
        
        if (scheduleTime.isAfter(DateTime.now())) {
          await scheduleNotification(
            id: task.id.hashCode,
            title: 'Task Reminder',
            body: 'Your task "${task.title}" is due in 1 hour',
            scheduledDate: scheduleTime,
            payload: task.id,
          );
          debugPrint('Scheduled 1-hour reminder for task ${task.id}');
        }
        
        // Schedule for due time
        await scheduleNotification(
          id: task.id.hashCode + 1,
          title: 'Task Due',
          body: 'Your task "${task.title}" is due now',
          scheduledDate: task.dueDate,
          payload: task.id,
        );
        debugPrint('Scheduled due time notification for task ${task.id}');
      }
    } catch (e) {
      debugPrint('Error scheduling task reminders: $e');
      // Log error but don't rethrow to prevent app crashes
    }
  }

  Future<void> cancelTaskReminders(String taskId) async {
    try {
      debugPrint('Cancelling reminders for task $taskId');
      await notificationsPlugin.cancel(taskId.hashCode);
      await notificationsPlugin.cancel(taskId.hashCode + 1);
      debugPrint('Canceled reminders for task $taskId');
    } catch (e) {
      debugPrint('Error cancelling task reminders: $e');
      // Log error but don't rethrow to prevent app crashes
    }
  }

  Future<List<PendingNotificationRequest>> checkPendingNotifications() async {
    try {
      if (!_initialized) {
        await initialize();
      }
      final pendingNotifications = await notificationsPlugin.pendingNotificationRequests();
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

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized, initializing now...');
      await initialize();
    }
    
    try {
      debugPrint('Showing notification: $id, $title, $body');
      
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'task_reminders',
        'Task Reminders',
        channelDescription: 'Notifications for task reminders',
        importance: fln.Importance.max,
        priority: fln.Priority.high,
        playSound: true,
        enableLights: true,
      );
      
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      
      await notificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
      debugPrint('Notification shown successfully');
    } catch (e) {
      debugPrint('Error showing notification: $e');
      // Log error but don't rethrow to prevent app crashes
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized, initializing now...');
      await initialize();
    }
    
    try {
      debugPrint('Scheduling notification: $id, $title, $body at $scheduledDate');
      
      // Ensure the scheduled time is in the future
      final now = DateTime.now();
      if (scheduledDate.isBefore(now)) {
        debugPrint('Warning: Scheduled time is in the past, adjusting to now + 5 seconds');
        scheduledDate = now.add(const Duration(seconds: 5));
      }
      
      // Check if we have exact alarm permission on Android
      if (Platform.isAndroid) {
        final hasExactAlarms = await checkExactAlarmPermission();
        if (!hasExactAlarms) {
          debugPrint('Exact alarms not available, requesting permission...');
          final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
              notificationsPlugin.resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
          if (androidImplementation != null) {
            await androidImplementation.requestExactAlarmsPermission();
          }
        }
      }
      
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'task_reminders',
        'Task Reminders',
        channelDescription: 'Notifications for task reminders',
        importance: fln.Importance.max,
        priority: fln.Priority.high,
        playSound: true,
        enableLights: true,
        fullScreenIntent: true,
      );
      
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      
      // Get current timezone
      tz.TZDateTime scheduledTzDate = tz.TZDateTime.from(scheduledDate, tz.local);
      debugPrint('Scheduling for: $scheduledTzDate');
      
      // Calculate seconds from now
      final int secondsFromNow = scheduledDate.difference(now).inSeconds;
      debugPrint('Scheduling notification in $secondsFromNow seconds from now');
      
      // Use zonedSchedule with the correctly formatted TZDateTime
      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTzDate,
        platformChannelSpecifics,
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

  Future<void> cancelAll() async {
    try {
      debugPrint('Cancelling all notifications');
      await notificationsPlugin.cancelAll();
      debugPrint('All notifications cancelled successfully');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
      // Log error but don't rethrow to prevent app crashes
    }
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    // Handle iOS notification when app is in foreground
    debugPrint('Received iOS notification: $id, $title, $body, $payload');
    // Here you could add code to show a custom dialog or in-app notification
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    final String? payload = response.payload;
    debugPrint('Notification clicked: ${response.payload}');
    
    if (payload != null) {
      // Navigate to specific task details
      // You would typically use a navigation service or similar to navigate
      // to the task details page with the task ID from the payload
    }
  }
}