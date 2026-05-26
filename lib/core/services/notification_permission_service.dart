import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionService {
  /// Xin toàn bộ quyền cần cho reminder
  static Future<bool> requestAll() async {
    // Android < 13 → không cần POST_NOTIFICATIONS
    if (Platform.isAndroid) {
      // Android 13+
      final notificationStatus = await Permission.notification.request();

      // Android 12+ (exact alarm)
      final exactAlarmStatus =
      await Permission.scheduleExactAlarm.request();

      return notificationStatus.isGranted &&
          exactAlarmStatus.isGranted;
    }

    return true;
  }

  /// Check if all reminder permissions are granted
  static Future<bool> isGranted() async {
    if (Platform.isAndroid) {
      final notificationStatus = await Permission.notification.status;
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      return notificationStatus.isGranted && exactAlarmStatus.isGranted;
    }
    return true;
  }
}
