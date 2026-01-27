// =============================================================================
// FILE: notification_service.dart
// PURPOSE: Admin Notification Service
// DESCRIPTION: Creates notifications in Firestore for admin panel visibility.
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'admin_notifications';

  /// Create a notification for admin panel
  static Future<void> createNotification({
    required String type,
    required String title,
    required String message,
    String? userId,
    String? orderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection(_collection).add({
        'type': type,
        'title': title,
        'message': message,
        'userId': userId,
        'orderId': orderId,
        'metadata': metadata,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail - don't disrupt user experience for notification errors
      print('Failed to create admin notification: $e');
    }
  }

  /// Notify admin of new feedback
  static Future<void> notifyFeedback({
    required String userName,
    required String subject,
    int? rating,
  }) async {
    await createNotification(
      type: 'feedback',
      title: 'New Feedback from $userName',
      message: '$subject${rating != null ? ' (Rating: $rating/5)' : ''}',
    );
  }

  /// Notify admin of new review
  static Future<void> notifyReview({
    required String userName,
    required String productName,
    required int rating,
    String? comment,
  }) async {
    await createNotification(
      type: 'review',
      title: 'New Review: $productName',
      message:
          '$userName rated $rating/5${comment != null ? ': "$comment"' : ''}',
    );
  }

  /// Notify admin of order placed
  static Future<void> notifyOrderPlaced({
    required String orderNumber,
    required String userName,
    required double total,
  }) async {
    await createNotification(
      type: 'order_placed',
      title: 'New Order: $orderNumber',
      message: '$userName placed an order for \$${total.toStringAsFixed(2)}',
    );
  }

  /// Notify admin of order cancelled
  static Future<void> notifyOrderCancelled({
    required String orderNumber,
    required String userName,
  }) async {
    await createNotification(
      type: 'order_cancelled',
      title: 'Order Cancelled: $orderNumber',
      message: '$userName cancelled their order',
    );
  }

  /// Notify admin of order completed
  static Future<void> notifyOrderCompleted({
    required String orderNumber,
  }) async {
    await createNotification(
      type: 'order_completed',
      title: 'Order Completed: $orderNumber',
      message: 'Order has been marked as completed',
    );
  }

  /// Notify admin when user adds item to wishlist
  static Future<void> notifyWishlist({
    required String userName,
    required String productName,
  }) async {
    await createNotification(
      type: 'wishlist',
      title: 'New Wishlist Item',
      message: '$userName added "$productName" to their wishlist',
    );
  }
}
