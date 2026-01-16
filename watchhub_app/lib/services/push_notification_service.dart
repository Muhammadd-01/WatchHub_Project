// =============================================================================
// FILE: push_notification_service.dart
// PURPOSE: Push Notification service for WatchHub using OneSignal
// DESCRIPTION: Handles push notifications using OneSignal SDK.
//              Replaces direct Firebase Cloud Messaging integration.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to handle Push Notifications via OneSignal
class PushNotificationService {
  bool _isInitialized = false;

  /// Initialize OneSignal
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey,
      {String? uid}) async {
    if (_isInitialized) return;

    // 1. Load Environment Variables
    if (!dotenv.isInitialized) {
      await dotenv.load(fileName: ".env");
    }

    final appId = dotenv.env['ONESIGNAL_APP_ID'];
    if (appId == null) {
      debugPrint('PushNotificationService: ONESIGNAL_APP_ID missing in .env');
      return;
    }

    // 2. Initialize SDK
    // Remove if log privacy is needed
    // OneSignal.Debug.setLogLevel(OSLogLevel.VERBOSE);
    OneSignal.initialize(appId);

    // 3. Request Permission
    final permission = await OneSignal.Notifications.requestPermission(true);
    debugPrint('OneSignal Permission Accepted: $permission');

    // 4. Set Notification Handlers
    _setupNotificationHandlers(navigatorKey);

    // 5. Login User (if UID provided)
    if (uid != null) {
      await loginUser(uid);
    }

    _isInitialized = true;
    debugPrint('OneSignal Initialized');
  }

  /// Associate the current user with OneSignal
  Future<void> loginUser(String uid) async {
    debugPrint('PushNotificationService: Logging in user $uid');
    await OneSignal.login(uid);
    await _updateUserTokenInFirestore(uid);
  }

  /// Logout user from OneSignal
  Future<void> logoutUser() async {
    debugPrint('PushNotificationService: Logging out user');
    await OneSignal.logout();
  }

  /// Setup foreground and background notification handlers
  void _setupNotificationHandlers(GlobalKey<NavigatorState> navigatorKey) {
    // Handle Foreground Notifications
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint(
          'OneSignal: Notification received in foreground: ${event.notification.title}');

      // Prevent Notification if disabled in app settings
      // Note: OneSignal usually respects system settings, but we can do extra checks here
      event.notification.display();
    });

    // Handle Notification Clicks
    OneSignal.Notifications.addClickListener((event) {
      debugPrint(
          'OneSignal: Notification clicked: ${event.notification.title}');

      // Navigate to Orders if it's an order notification (simple logic)
      final title = event.notification.title?.toLowerCase() ?? '';
      final body = event.notification.body?.toLowerCase() ?? '';

      if (title.contains('order') || body.contains('order')) {
        navigatorKey.currentState?.pushNamed('/orders');
      }
    });
  }

  /// Update the OneSignal Player ID (Subscription ID) in Firestore

  /// Note: OneSignal v5+ uses the External ID (login) mostly, but Subscription ID is still useful.
  Future<void> _updateUserTokenInFirestore(String uid) async {
    try {
      final id = OneSignal.User.pushSubscription.id;
      if (id != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'oneSignalPlayerId': id,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('PushNotificationService: OneSignal ID saved: $id');
      }
    } catch (e) {
      debugPrint('PushNotificationService: Error saving OneSignal ID - $e');
    }
  }
}
