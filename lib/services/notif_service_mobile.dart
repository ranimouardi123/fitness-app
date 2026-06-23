import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifService {
  static FlutterLocalNotificationsPlugin? _plugin;

  static Future<void> init() async {
    _plugin = FlutterLocalNotificationsPlugin();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin!.initialize(settings);
    await _plugin!
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> show(String titre, String corps) async {
    if (_plugin == null) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'chat_channel', 'Messages',
        importance: Importance.high, priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );
    await _plugin!.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      titre, corps, details,
    );
  }
}