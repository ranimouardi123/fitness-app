import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_router.dart';
import 'app_theme.dart';
import 'services/database_helper.dart';
import 'services/chat_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Navigateur global pour deep link
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'chat_channel', 'Messages',
      channelDescription: 'Notifications de messagerie',
      importance: Importance.high, priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
  );
  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    message.notification?.title ?? '💬 Nouveau message',
    message.notification?.body ?? '',
    details,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await ChatService.initSupabase();
  await ChatService.instance.initNotifications();
  if (kIsWeb) {
    await databaseFactoryWeb.openDatabase('fitness.db');
  }
  await DatabaseHelper.instance.initCoachParDefaut();
  await _initFCM();
  _ecouterNouveauxMessages();
  runApp(const FitnessApp());
}

Future<void> _initFCM() async {
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  final prefs = await SharedPreferences.getInstance();
  final role = prefs.getString('user_role') ?? '';
  final userId = prefs.getInt('user_id');

  if (role == 'adherent' && userId != null) {
    await messaging.subscribeToTopic('adherent_$userId');
  } else if (role == 'coach') {
    await messaging.subscribeToTopic('coach_messages');
  }

  // Notification reçue en foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    await ChatService.instance.afficherNotificationExterne(
      titre: message.notification?.title ?? '💬 Nouveau message',
      corps: message.notification?.body ?? '',
    );
  });

  // Tap sur notification quand app en background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _naviguerVersChat();
  });

  // Tap sur notification quand app fermée
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _naviguerVersChat();
    });
  }

  // Tap sur notification locale
  flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (details) {
      _naviguerVersChat();
    },
  );
}

Future<void> _naviguerVersChat() async {
  final prefs = await SharedPreferences.getInstance();
  final role = prefs.getString('user_role') ?? '';

  if (role == 'coach') {
    appRouter.go('/coach');
  } else if (role == 'adherent') {
    appRouter.go('/adherent/chat');
  }
}

void _ecouterNouveauxMessages() {
  final db = Supabase.instance.client;
  int dernierIdVu = 0;
  bool premier = true;

  db.from('messages').stream(primaryKey: ['id']).listen((data) async {
    if (data.isEmpty) return;
    if (premier) {
      premier = false;
      if (data.isNotEmpty) {
        final ids = data.map((m) => m['id'] as int? ?? 0).toList();
        dernierIdVu = ids.reduce((a, b) => a > b ? a : b);
      }
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? '';
    for (final msg in data) {
      final id = msg['id'] as int? ?? 0;
      final expediteur = msg['expediteur'] as String? ?? '';
      if (id > dernierIdVu) {
        dernierIdVu = id;
        if (role == 'coach' && expediteur == 'adherent') {
          await ChatService.instance.afficherNotificationExterne(
            titre: '💬 Nouveau message',
            corps: msg['texte'] ?? '',
          );
        } else if (role == 'adherent' && expediteur == 'coach') {
          await ChatService.instance.afficherNotificationExterne(
            titre: '💪 Coach Ayoub',
            corps: msg['texte'] ?? '',
          );
        }
      }
    }
  });
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fitness Coach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: appRouter,
    );
  }
}
