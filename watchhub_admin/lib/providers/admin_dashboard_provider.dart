// =============================================================================
// FILE: admin_dashboard_provider.dart
// PURPOSE: Provide dashboard stats
// DESCRIPTION: Fetches counts for products, orders, users, etc.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  int _productCount = 0;
  int _orderCount = 0;
  int _userCount = 0;
  double _totalRevenue = 0.0;

  bool get isLoading => _isLoading;
  int get productCount => _productCount;
  int get orderCount => _orderCount;
  int get userCount => _userCount;
  double get totalRevenue => _totalRevenue;

  Future<void> fetchStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Product Count
      final productSnapshot =
          await _firestore.collection('products').count().get();
      _productCount = productSnapshot.count ?? 0;

      // 2. Order Count
      final orderSnapshot = await _firestore.collection('orders').count().get();
      _orderCount = orderSnapshot.count ?? 0;

      // 3. User Count
      final userSnapshot = await _firestore.collection('users').count().get();
      _userCount = userSnapshot.count ?? 0;

      // 4. Revenue
      final revenueQuery = await _firestore.collection('orders').get();
      double sum = 0;
      for (var doc in revenueQuery.docs) {
        final data = doc.data();
        if (data['total'] != null) {
          sum += (data['total'] as num).toDouble();
        } else if (data['totalAmount'] != null) {
          sum += (data['totalAmount'] as num).toDouble();
        }
      }
      _totalRevenue = sum;
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
