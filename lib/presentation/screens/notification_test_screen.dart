import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:smart_task_manager/core/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/main.dart';

// Import with alias to resolve the name conflict
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;

class NotificationTestScreen extends ConsumerStatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  ConsumerState<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends ConsumerState<NotificationTestScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  bool _notificationsEnabled = false;
  bool _exactAlarmsEnabled = false;
  String _statusMessage = 'Checking notification permissions...';
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    // We'll get the notification service in didChangeDependencies
    _statusMessage = 'Initializing...';
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the notification service from the provider
    _notificationService = ref.read(notificationServiceProvider);
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await _checkNotificationPermission();
    if (Platform.isAndroid) {
      await _checkExactAlarmPermission();
    }
  }

  Future<void> _checkExactAlarmPermission() async {
    try {
      // Use the notification service's method to check exact alarm permissions
      final hasExactAlarms = await _notificationService.checkExactAlarmPermission();
      setState(() {
        _exactAlarmsEnabled = hasExactAlarms;
        _updateStatusMessage();
      });
    } catch (e) {
      setState(() {
        _exactAlarmsEnabled = false;
        _statusMessage = 'Error checking exact alarm permission: $e';
      });
    }
  }

  Future<void> _checkNotificationPermission() async {
    try {
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        
        final bool? granted = await androidImplementation?.areNotificationsEnabled();
        
        setState(() {
          _notificationsEnabled = granted ?? false;
          _updateStatusMessage();
        });
      } else if (Platform.isIOS) {
        final IOSFlutterLocalNotificationsPlugin? iosImplementation =
            flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        
        final bool? granted = await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        
        setState(() {
          _notificationsEnabled = granted ?? false;
          _updateStatusMessage();
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking permissions: $e';
      });
    }
  }

  void _updateStatusMessage() {
    if (Platform.isAndroid) {
      _statusMessage = 'Notifications: ${_notificationsEnabled ? "✓" : "✗"}\n'
          'Exact Alarms: ${_exactAlarmsEnabled ? "✓" : "✗"}';
    } else {
      _statusMessage = 'Notifications: ${_notificationsEnabled ? "✓" : "✗"}';
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await _notificationService.requestPermissions();
      // Check if permissions were granted
      await _checkPermissions();
    } catch (e) {
      setState(() {
        _statusMessage = 'Error requesting permissions: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _statusMessage,
                style: TextStyle(
                  color: _notificationsEnabled && (!Platform.isAndroid || _exactAlarmsEnabled)
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (!_notificationsEnabled || (Platform.isAndroid && !_exactAlarmsEnabled))
              ElevatedButton(
                onPressed: _requestPermissions,
                child: const Text('Request Permissions'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _notificationService.showNotification(
                    id: 0,
                    title: 'Immediate Notification',
                    body: 'This is a test notification that shows immediately',
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Immediate notification sent')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error sending notification: $e')),
                    );
                  }
                }
              },
              child: const Text('Show Immediate Notification'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final scheduledTime = DateTime.now().add(const Duration(seconds: 5));
                  debugPrint('Scheduling notification for: $scheduledTime');
                  
                  await _notificationService.scheduleNotification(
                    id: 1,
                    title: 'Scheduled Notification',
                    body: 'This notification was scheduled to appear 5 seconds later',
                    scheduledDate: scheduledTime,
                  );
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification scheduled for 5 seconds from now')),
                    );
                  }
                } catch (e) {
                  debugPrint('Error scheduling notification: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error scheduling notification: $e')),
                    );
                  }
                }
              },
              child: const Text('Schedule Notification (5 seconds)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Cancel notifications with IDs 0 and 1
                  await _notificationService.cancelAll();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All notifications cancelled')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error cancelling notifications: $e')),
                    );
                  }
                }
              },
              child: const Text('Cancel All Notifications'),
            ),
            const SizedBox(height: 20),
            // Direct test with notification plugin
            ElevatedButton(
              onPressed: () async {
                try {
                  const AndroidNotificationDetails androidDetails =
                      AndroidNotificationDetails(
                    'direct_test_channel',
                    'Direct Test Notifications',
                    channelDescription: 'For directly testing notifications',
                    importance: fln.Importance.max,
                    priority: fln.Priority.high,
                  );
                  
                  const NotificationDetails details =
                      NotificationDetails(android: androidDetails);
                  
                  await flutterLocalNotificationsPlugin.show(
                    100,
                    'Direct Test',
                    'This is a direct test notification',
                    details,
                  );
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Direct test notification sent')),
                    );
                  }
                } catch (e) {
                  debugPrint('Error with direct test: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error with direct test: $e')),
                    );
                  }
                }
              },
              child: const Text('Direct Plugin Test'),
            ),
          ],
        ),
      ),
    );
  }
} 