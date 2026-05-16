import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // TODO: Fix initialization for current version
    // const AndroidInitializationSettings androidSettings =
    //     AndroidInitializationSettings('@mipmap/ic_launcher');
    // const InitializationSettings settings = InitializationSettings(
    //   android: androidSettings,
    // );
    // await _notificationsPlugin.initialize(settings);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // TODO: Fix show method
    // const NotificationDetails details = NotificationDetails(
    //   android: AndroidNotificationDetails(
    //     'farmtok_channel',
    //     'FarmTok Notifications',
    //     importance: Importance.high,
    //     priority: Priority.high,
    //   ),
    // );
    // await _notificationsPlugin.show(
    //   DateTime.now().millisecond,
    //   title,
    //   body,
    //   details,
    //   payload: payload,
    // );
  }

  // Scheduling not implemented in this version
  // static Future<void> scheduleWeatherAlert({...})

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}