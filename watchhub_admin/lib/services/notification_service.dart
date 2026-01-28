// =============================================================================
// FILE: notification_service.dart
// PURPOSE: Send push notifications from admin panel
// DESCRIPTION: Uses OneSignal REST API to send notifications to all app users.
// =============================================================================

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {
  /// Get OneSignal App ID from environment
  static String get _oneSignalAppId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';

  /// Get OneSignal REST API Key from environment
  static String get _oneSignalRestApiKey =>
      dotenv.env['ONESIGNAL_REST_API_KEY'] ?? '';

  /// Send push notification to all app users about a new product
  static Future<bool> notifyNewProduct({
    required String productName,
    required String productBrand,
    String? productId,
  }) async {
    if (_oneSignalAppId.isEmpty || _oneSignalRestApiKey.isEmpty) {
      debugPrint('NotificationService: Missing OneSignal credentials in .env');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_oneSignalRestApiKey',
        },
        body: jsonEncode({
          'app_id': _oneSignalAppId,
          'included_segments': ['All'], // Send to all subscribed users
          'headings': {'en': '🆕 New Watch Added!'},
          'contents': {'en': 'Check out the new $productBrand $productName!'},
          'data': {
            'type': 'new_product',
            'productId': productId,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('NotificationService: Sent to ${data['recipients']} users');
        return true;
      } else {
        debugPrint(
            'NotificationService: Failed with status ${response.statusCode}');
        debugPrint('NotificationService: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('NotificationService: Error sending notification - $e');
      return false;
    }
  }

  /// Send custom notification to all users
  static Future<bool> sendToAll({
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    if (_oneSignalAppId.isEmpty || _oneSignalRestApiKey.isEmpty) {
      debugPrint('NotificationService: Missing OneSignal credentials in .env');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_oneSignalRestApiKey',
        },
        body: jsonEncode({
          'app_id': _oneSignalAppId,
          'included_segments': ['All'],
          'headings': {'en': title},
          'contents': {'en': message},
          'data': data,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('NotificationService: Error - $e');
      return false;
    }
  }
}
