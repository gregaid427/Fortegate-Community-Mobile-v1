// lib/appcore/service/fcm_service.dart

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../helpers/storage_helper.dart';

class FCMService {
  FCMService._();
  static final FCMService instance = FCMService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize FCM with user
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _requestPermission();
    await _initLocalNotifications();
    await _getToken();
    _bindMessageListeners();
  }

  /// Initialize FCM without user (guest mode)
  Future<void> initWithoutUser() async {
if (_initialized && _fcmToken != null) return;
    _initialized = true;

    await _requestPermission();
    await _initLocalNotifications();
    await _getToken();
    
    debugPrint('📱 FCM initialized (guest mode)');
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Initialize local notifications
  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _handleNotificationTap(jsonDecode(details.payload!));
        }
      },
    );
  }

  /// Get FCM token
 Future<void> _getToken() async {
  for (int i = 0; i < 5; i++) {
    try {
      _fcmToken = await _messaging.getToken();

      if (_fcmToken != null) {
        //update backend with token
        
        await StorageHelper.setFCMToken(_fcmToken!);
        debugPrint('📱 FCM Token: ${_fcmToken!.substring(0, 20)}...');
        return;
      }
    } catch (e) {
      debugPrint('⚠️ FCM attempt ${i + 1} failed: $e');
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  debugPrint('❌ Unable to obtain FCM token after retries');
}

  /// Bind message listeners
  void _bindMessageListeners() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // Background/terminated - app opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationNavigation);

    // App opened from terminated state
    _messaging.getInitialMessage().then((message) {
      if (message != null) _handleNotificationNavigation(message);
    });

    // Token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      _fcmToken = newToken;
      await StorageHelper.setFCMToken(newToken);
      debugPrint('🔄 FCM Token refreshed');
    });
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const android = AndroidNotificationDetails(
      'default_channel',
      'Default',
      importance: Importance.max,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(android: android, iOS: ios),
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification navigation
  void _handleNotificationNavigation(RemoteMessage message) {
    if (message.data.isEmpty) return;
    _handleNotificationTap(message.data);
  }

  /// Handle notification tap
  void _handleNotificationTap(Map<String, dynamic> data) {
    final screen = data['screen'];
    debugPrint('🔔 Notification tapped - Screen: $screen');
    // Navigation will be handled by the app's navigator key
  }
}