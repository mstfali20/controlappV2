import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:controlapp/const/data.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('Background notification: ${message.messageId} | ${message.data}');
}

class FirebaseApi {
  FirebaseApi();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'controlapp_notifications',
    'ControlApp Notifications',
    description: 'General ControlApp notifications',
    importance: Importance.high,
  );

  Future<void> initNotifications() async {
    await _initializeLocalNotifications();
    await _requestPermissions();
    await _ensureFcmToken();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      _showForegroundNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('Notification opened: ${message.messageId} | ${message.data}');
    });
  }

  Future<void> _initializeLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(settings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log('Notification permission status: ${settings.authorizationStatus}');

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _ensureFcmToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        fcmtokenstring = token;
        log('FCM token: $token');
      }
    } catch (error) {
      log('Failed to fetch FCM token: $error');
    }

    _messaging.onTokenRefresh.listen((token) {
      fcmtokenstring = token;
      log('FCM token refreshed: $token');
    });
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final hasContent = notification != null ||
        (message.data['title'] ?? '').toString().isNotEmpty ||
        (message.data['body'] ?? '').toString().isNotEmpty;

    if (!hasContent) {
      return;
    }

    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: notification?.android?.smallIcon ?? '@mipmap/ic_launcher',
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final notificationId = notification?.hashCode ?? message.hashCode;

    await _localNotifications.show(
      notificationId,
      title ?? 'ControlApp',
      body ?? '',
      details,
    );
  }
}
