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

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
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

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update order status: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
