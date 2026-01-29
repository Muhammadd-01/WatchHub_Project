// =============================================================================
// FILE: admin_notification_provider.dart
// PURPOSE: Manage Admin Notifications unread count
// DESCRIPTION: Listens to admin_notifications collection.
// =============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _unreadCount = 0;
  StreamSubscription? _subscription;

  int get unreadCount => _unreadCount;

  AdminNotificationProvider() {
    _startListening();
  }

  void _startListening() {
    _subscription?.cancel();
    _subscription = _firestore
        .collection('admin_notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      _unreadCount = snapshot.docs.length;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error listening to admin notifications: $e');
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
