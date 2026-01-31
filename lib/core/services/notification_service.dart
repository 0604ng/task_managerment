import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  /// INIT – gọi trong main()
  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notifications.initialize(initSettings);
  }

  /// SCHEDULE TASK REMINDER (đúng giờ)
  static Future<void> scheduleTaskNotification({
    required String taskId,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    if (dateTime.isBefore(DateTime.now())) return;

    final androidDetails = AndroidNotificationDetails(
      'task_reminder',
      'Task Reminder',
      channelDescription: 'Notify when task is due',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    await _notifications.zonedSchedule(
      taskId.hashCode,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      NotificationDetails(android: androidDetails),

      /// ⚠️ ANDROID 12+
      androidScheduleMode: Platform.isAndroid
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexact,

      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// TEST NOTIFICATION (dùng trong Profile)
  static Future<void> sendTestNotification() async {
    final androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notification',
      channelDescription: 'Test notification permission',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notifications.show(
      9999,
      '🔔 Reminder enabled',
      'You will receive task notifications on time',
      NotificationDetails(android: androidDetails),
    );
  }

  /// CANCEL
  static Future<void> cancel(String taskId) async {
    await _notifications.cancel(taskId.hashCode);
  }
}
