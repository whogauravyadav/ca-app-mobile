import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase_options.dart';
import 'api_client.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (DefaultFirebaseOptions.isConfigured) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref.watch(apiClientProvider));
});

class PushNotificationService {
  PushNotificationService(this._api);

  final ApiClient _api;
  final _local = FlutterLocalNotificationsPlugin();
  final _opened = StreamController<Map<String, dynamic>>.broadcast();

  bool _ready = false;
  String? _token;

  Stream<Map<String, dynamic>> get onNotificationOpened => _opened.stream;

  Future<void> init() async {
    if (_ready) return;

    await _initLocalNotifications();

    if (!DefaultFirebaseOptions.isConfigured) {
      debugPrint(
        'Firebase not configured — push disabled. Inbox API still works.',
      );
      _ready = true;
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      if (Platform.isAndroid) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      await messaging.subscribeToTopic('all_users');

      _token = await messaging.getToken();
      if (_token != null) {
        await registerTokenWithBackend(_token!);
      }

      messaging.onTokenRefresh.listen((t) {
        _token = t;
        registerTokenWithBackend(t);
      });

      FirebaseMessaging.onMessage.listen(_showForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpened);

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        _handleOpened(initial);
      }

      _ready = true;
    } catch (e, st) {
      debugPrint('Firebase init failed: $e\n$st');
      _ready = true;
    }
  }

  Future<void> registerTokenWithBackend(String token) async {
    try {
      await _api.post('/device-tokens', data: {
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
    } catch (e) {
      debugPrint('Device token register failed: $e');
    }
  }

  Future<void> syncToken() async {
    if (_token != null) {
      await registerTokenWithBackend(_token!);
      return;
    }
    if (!DefaultFirebaseOptions.isConfigured) return;
    try {
      _token = await FirebaseMessaging.instance.getToken();
      if (_token != null) await registerTokenWithBackend(_token!);
    } catch (_) {}
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          _opened.add(data);
        } catch (_) {}
      },
    );

    final androidPlugin = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'ca_default',
        'Current Affairs',
        description: 'Articles, quizzes and updates',
        importance: Importance.high,
      ),
    );

    if (Platform.isAndroid) {
      await androidPlugin?.requestNotificationsPermission();
    }
  }

  Future<void> _showForeground(RemoteMessage message) async {
    final n = message.notification;
    final title = n?.title ?? message.data['title']?.toString() ?? 'Update';
    final body = n?.body ?? message.data['body']?.toString() ?? '';

    await _local.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ca_default',
          'Current Affairs',
          channelDescription: 'Articles, quizzes and updates',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleOpened(RemoteMessage message) {
    _opened.add(Map<String, dynamic>.from(message.data));
  }

  Future<void> dispose() async {
    await _opened.close();
  }
}
