import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:smart_task_manager/core/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({Key? key}) : super(key: key);

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  bool _notificationsEnabled = false;
  bool _exactAlarmsEnabled = false;
  String _statusMessage = 'Checking notification permissions...';

  @override
  void initState() {
    super.initState();
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
      final hasExactAlarms = await NotificationService.checkExactAlarmPermission();
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
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        
        await androidImplementation?.requestNotificationsPermission();
        await androidImplementation?.requestExactAlarmsPermission();
        
        // Check if permissions were granted
        await _checkPermissions();
      } else if (Platform.isIOS) {
        await _checkNotificationPermission(); // This will request permissions on iOS
      }
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
                  await NotificationService.showNotification(
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
                  
                  await NotificationService.scheduleNotification(
                    id: 1,
                    title: 'Scheduled Notification',
                    body: 'This notification was scheduled to appear 5 seconds later',
                    dateTime: scheduledTime,
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
                  await NotificationService.cancel(0);
                  await NotificationService.cancel(1);
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
                    importance: Importance.max,
                    priority: Priority.high,
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