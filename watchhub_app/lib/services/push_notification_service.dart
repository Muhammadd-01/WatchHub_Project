import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to handle Firebase Cloud Messaging (Push Notifications)
class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize Push Notifications
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey,
      {String? uid}) async {
    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
      return;
    }

    // 2. Initialize Local Notifications (for displaying foreground notifications)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Note: iOS permission is handled by requestPermission above, but we need settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        navigatorKey.currentState?.pushNamed('/orders');
      },
    );

    // 3. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
            'Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });

    // 4. Handle Background/Terminated Click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      navigatorKey.currentState?.pushNamed('/orders');
    });

    // 5. Check Initial Message (Terminated state)
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      navigatorKey.currentState?.pushNamed('/orders');
    }

    // 6. Get Token and Save it
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
      if (token != null && uid != null) {
        await saveToken(uid, token);
      }
    } catch (e) {
      debugPrint('PushNotificationService: Error getting FCM token - $e');
      // If it's an APNS token error, we don't want to crash the app
      if (e.toString().contains('apns-token-not-set')) {
        debugPrint(
            'PushNotificationService: APNS token not yet available. This is expected on iOS simulators or before APNS initialization is complete.');
      }
    }
  }

  /// Save FCM token to Firestore User document
  Future<void> saveToken(String uid, String token) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('PushNotificationService: Token saved for $uid');
    } catch (e) {
      debugPrint('PushNotificationService: Error saving token - $e');
    }
  }

  /// Show a local notification when app is in foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    // 1. Get user preferences from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final isPushEnabled = prefs.getBool('push_notifications_enabled') ?? true;
    final isOrderEnabled = prefs.getBool('order_notifications_enabled') ?? true;

    // 2. Determine if this is an order update
    final notification = message.notification;
    if (notification == null) return;

    final title = notification.title?.toLowerCase() ?? '';
    final body = notification.body?.toLowerCase() ?? '';
    final isOrderUpdate = title.contains('order') ||
        body.contains('order') ||
        title.contains('status') ||
        body.contains('ship');

    // 3. Apply filtering rules
    // Case A: Overall push is disabled
    if (!isPushEnabled) {
      debugPrint('Push notifications are disabled in settings. Skipping.');
      return;
    }

    // Case B: This is an order update but order notifications are disabled
    if (isOrderUpdate && !isOrderEnabled) {
      debugPrint('Order updates are disabled in settings. Skipping.');
      return;
    }

    final android = message.notification?.android;

    if (android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // channel Id
            'High Importance Notifications', // channel Name
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }
}
