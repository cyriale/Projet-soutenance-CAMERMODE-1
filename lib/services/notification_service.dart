import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Handler de haut niveau pour les messages en arrière-plan.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Background Message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (kIsWeb) return;

    try {
      // 1. Demander les permissions FCM
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // 2. Configuration Initiale pour flutter_local_notifications
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );

      // Correction finale : Utilisation de 'settings:' nommé
      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint("Notification cliquée: ${response.payload}");
        },
      );

      // 3. Créer le canal Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'camermode_channel',
        'CamerMode Notifications',
        description: 'Canal pour les alertes CamerMode',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 4. Handlers de messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    } catch (e) {
      debugPrint("Notification Init Error: $e");
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'camermode_channel',
      'CamerMode Notifications',
      channelDescription: 'Canal pour les alertes CamerMode',
      importance: Importance.max,
      priority: Priority.high,
    );

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title ?? "CamerMode",
      body: message.notification?.body ?? "",
      notificationDetails: platformDetails,
      payload: message.data.toString(),
    );
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}
