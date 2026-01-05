// =============================================================================
// FILE: admin_order_provider.dart
// PURPOSE: Manage orders in Admin Panel
// DESCRIPTION: Handles fetching and updating orders.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  /// Sends an email via Firebase Extension (mail collection)
  Future<void> _sendEmail(String uid, String title, String message) async {
    try {
      // 1. Get user email
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userEmail = userDoc.data()?['email'];

      if (userEmail == null) {
        debugPrint('AdminOrderProvider: User email not found for $uid');
        return;
      }

      // 2. Add to mail collection
      await _firestore.collection('mail').add({
        'to': [userEmail],
        'message': {
          'subject': title,
          'text': message,
          'html': '<p>$message</p>', // Simple HTML
        },
      });
      debugPrint('AdminOrderProvider: Email queued for $userEmail');
    } catch (e) {
      debugPrint('AdminOrderProvider: Error sending email - $e');
    }
  }
}
