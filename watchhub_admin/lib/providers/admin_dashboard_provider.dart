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
  int _categoryCount = 0;
  int _brandCount = 0;
  int _reviewCount = 0;
  int _feedbackCount = 0;
  double _totalRevenue = 0.0;
  List<double> _dailyRevenue = [];

  bool get isLoading => _isLoading;
  int get productCount => _productCount;
  int get orderCount => _orderCount;
  int get userCount => _userCount;
  int get categoryCount => _categoryCount;
  int get brandCount => _brandCount;
  int get reviewCount => _reviewCount;
  int get feedbackCount => _feedbackCount;
  double get totalRevenue => _totalRevenue;
  List<double> get dailyRevenue => _dailyRevenue;

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

      // 5. Category Count
      final categorySnapshot =
          await _firestore.collection('categories').count().get();
      _categoryCount = categorySnapshot.count ?? 0;

      // 6. Brand Count
      final brandSnapshot = await _firestore.collection('brands').count().get();
      _brandCount = brandSnapshot.count ?? 0;

      // 7. Review Count
      final reviewSnapshot =
          await _firestore.collection('reviews').count().get();
      _reviewCount = reviewSnapshot.count ?? 0;

      // 8. Feedback Count
      final feedbackSnapshot =
          await _firestore.collection('feedback').count().get();
      _feedbackCount = feedbackSnapshot.count ?? 0;

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

      // 5. Daily Revenue for Graph (Last 7 days)
      _calculateDailyRevenue(revenueQuery.docs);
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateDailyRevenue(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final now = DateTime.now();
    final Map<int, double> dailyMap = {};

    // Initialize last 7 days with 0
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i)).day;
      dailyMap[day] = 0.0;
    }

    for (var doc in docs) {
      final data = doc.data();
      final timestamp = data['createdAt'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate();
        final day = date.day;
        if (dailyMap.containsKey(day)) {
          double amount = 0;
          if (data['total'] != null) {
            amount = (data['total'] as num).toDouble();
          } else if (data['totalAmount'] != null) {
            amount = (data['totalAmount'] as num).toDouble();
          }
          dailyMap[day] = (dailyMap[day] ?? 0.0) + amount;
        }
      }
    }

    // Convert to sorted list (oldest to newest)
    final sortedDays = dailyMap.keys.toList()..sort();
    _dailyRevenue = sortedDays.map((day) => dailyMap[day]!).toList();
  }
}
