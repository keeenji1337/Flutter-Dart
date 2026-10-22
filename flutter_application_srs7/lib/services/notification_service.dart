import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background message handler required by Firebase Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log('Handling a background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'Важные уведомления (Lab 7)',
    description: 'Канал для подтверждения регистрации и push-уведомлений FCM',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Инициализация локальных уведомлений и Firebase Cloud Messaging
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Настройка параметров инициализации для Android и iOS
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          developer.log('Notification clicked: ${response.payload}');
        },
      );

      // 2. Создание канала уведомлений для Android 8.0+
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(_channel);
        // Запрос разрешения на уведомления для Android 13+
        await androidImplementation.requestNotificationsPermission();
      }

      // 3. Настройка Firebase Cloud Messaging
      await _setupFCM();

      _isInitialized = true;
    } catch (e, stack) {
      developer.log('Error initializing notification service: $e', stackTrace: stack);
    }
  }

  Future<void> _setupFCM() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Запрос разрешений для iOS / Web / Android 13+
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      developer.log('FCM Permission status: ${settings.authorizationStatus}');

      // Получение уникального токена устройства
      try {
        // ignore: deprecated_member_use
        _fcmToken = await messaging.getToken();
        developer.log('FCM Device Token: $_fcmToken');
      } catch (e) {
        developer.log('Could not get FCM token (may need google-services.json): $e');
      }

      // Слушатель обновления токена
      // ignore: deprecated_member_use
      messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        developer.log('FCM Token refreshed: $newToken');
      });

      // Настройка фонового обработчика
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Обработка push-уведомлений в активном состоянии приложения (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log('Received foreground FCM message: ${message.data}');
        RemoteNotification? notification = message.notification;

        // Если в сообщении есть уведомление, отображаем его локально
        if (notification != null) {
          showNotification(
            title: notification.title ?? 'Новое push-уведомление',
            body: notification.body ?? '',
            payload: message.data.toString(),
          );
        }
      });

      // Обработка клика по уведомлению, когда приложение открыто из фона
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        developer.log('App opened from notification: ${message.messageId}');
      });

      // Проверка начального сообщения, если приложение было запущено кликом по пушу
      RemoteMessage? initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        developer.log('App launched from terminated state via notification: ${initialMessage.messageId}');
      }
    } catch (e) {
      developer.log('FCM setup failed: $e');
    }
  }

  /// Показ локального push-уведомления (в шторке уведомлений устройства)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      await _localNotifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e) {
      developer.log('Failed to show notification: $e');
    }
  }

  /// Отправка push-уведомления об успешной регистрации пользователя
  Future<void> showRegistrationSuccessNotification({
    required String fullName,
    required String email,
  }) async {
    await showNotification(
      title: 'Регистрация успешна! 🎉',
      body: 'Пользователь $fullName ($email) успешно сохранен в Firebase Database!',
      payload: 'registration_success',
    );
  }
}
