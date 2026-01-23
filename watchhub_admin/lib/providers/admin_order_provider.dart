// =============================================================================
// FILE: admin_order_provider.dart
// PURPOSE: Manage orders in Admin Panel
// DESCRIPTION: Handles fetching and updating orders.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminOrderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Free Email Relay URL (Google Apps Script)
  /// Instructions in docs/SETUP_GUIDE.md
  static const String emailRelayUrl =
      'https://script.google.com/macros/s/AKfycbxB-RRd6dRUyiYTEsKwBwjDDkRx7KcHtEfAeVy45TsLP8Hmo3lw3LaMxOlU8Rnm28cQ/exec';

  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CollectionReference get _orderCollection => _firestore.collection('orders');

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot =
          await _orderCollection.orderBy('createdAt', descending: true).get();
      _orders = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      _errorMessage = 'Failed to fetch orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus,
      {String? userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _orderCollection.doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      final index = _orders.indexWhere((o) => o['id'] == orderId);
      if (index != -1) {
        _orders[index]['status'] = newStatus;
      }

      // Send Notification
      if (userId != null) {
        // Fetch user notification preferences
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final userData = userDoc.data();

        final bool pushEnabled = userData?['pushNotificationsEnabled'] ?? true;
        final bool orderEnabled = userData?['orderUpdatesEnabled'] ?? true;

        if (pushEnabled && orderEnabled) {
          String title = 'Order Update';
          String message = 'Your order status has been updated to $newStatus.';

          if (newStatus == 'approved') {
            title = 'Order Approved';
            message = 'Your order has been approved and is being processed.';
          } else if (newStatus == 'shipped') {
            title = 'Order Shipped';
            message = 'Your order is on its way!';
          } else if (newStatus == 'delivered') {
            title = 'Order Delivered';
            message = 'Your order has been delivered. Enjoy!';
          } else if (newStatus == 'cancelled') {
            title = 'Order Cancelled';
            message = 'Your order was cancelled.';
          }

          await _sendNotification(userId, title, message);
          await _sendEmail(userId, title, message);
          await _sendPushNotification(userId, title, message);
        } else {
          debugPrint(
              'AdminOrderProvider: Notifications suppressed by user settings for $userId');
        }
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update order status: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sends a notification to a user
  Future<void> _sendNotification(
      String uid, String title, String message) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .add({
        'title': title,
        'message': message,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('AdminOrderProvider: Notification sent to $uid');
    } catch (e) {
      debugPrint('AdminOrderProvider: Error sending notification - $e');
    }
  }

  /// Sends an email via Free Relay (Google Apps Script)
  Future<void> _sendEmail(String uid, String title, String message) async {
    try {
      // 1. Get user email
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userEmail = userDoc.data()?['email'];

      if (userEmail == null) {
        debugPrint('AdminOrderProvider: User email not found for $uid');
        return;
      }

      // 2. Try sending via Relay if configured
      if (emailRelayUrl != 'YOUR_EMAIL_RELAY_URL') {
        final response = await http.post(
          Uri.parse(emailRelayUrl),
          body: jsonEncode({
            'to': userEmail,
            'subject': title,
            'message': '<p>$message</p>',
          }),
        );

        if (response.statusCode == 200) {
          debugPrint('AdminOrderProvider: Email sent via Relay successfully');
          return;
        } else {
          debugPrint(
              'AdminOrderProvider: Relay failed with status ${response.statusCode}');
        }
      }

      // 3. Fallback: Add to mail collection (Requires Firebase Extension)
      await _firestore.collection('mail').add({
        'to': [userEmail],
        'message': {
          'subject': title,
          'text': message,
          'html': '<p>$message</p>',
        },
      });
      debugPrint('AdminOrderProvider: Email queued in Firestore (Fallback)');
    } catch (e) {
      debugPrint('AdminOrderProvider: Error sending email - $e');
    }
  }

  /// Sends a real push notification via OneSignal REST API
  Future<void> _sendPushNotification(
      String uid, String title, String body) async {
    try {
      // 1. Get User's OneSignal ID
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final playerId = userDoc.data()?['oneSignalPlayerId'];

      if (playerId == null) {
        debugPrint(
            'AdminOrderProvider: OneSignal Player ID not found for $uid');
        return;
      }

      // 2. Get API Keys from .env
      final appId = dotenv.env['ONESIGNAL_APP_ID'];
      final restApiKey = dotenv.env['ONESIGNAL_REST_API_KEY'];

      if (appId == null ||
          restApiKey == null ||
          appId == 'YOUR_ONESIGNAL_APP_ID') {
        debugPrint(
            'AdminOrderProvider: OneSignal keys not configured. Skipping push.');
        return;
      }

      // 3. Send Request to OneSignal REST API
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $restApiKey',
        },
        body: jsonEncode({
          'app_id': appId,
          'include_player_ids': [playerId],
          'headings': {'en': title},
          'contents': {'en': body},
          'data': {'type': 'order_update'},
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('AdminOrderProvider: OneSignal Push sent successfully');
      } else {
        debugPrint(
            'AdminOrderProvider: OneSignal Push failed - ${response.body}');
      }
    } catch (e) {
      debugPrint('AdminOrderProvider: Error sending OneSignal Push - $e');
    }
  }
}
