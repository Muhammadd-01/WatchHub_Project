import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  static const String _pushKey = 'push_notifications_enabled';
  static const String _orderKey = 'order_notifications_enabled';

  bool _isPushEnabled = true;
  bool _isOrderEnabled = true;
  int _unreadCount = 0;

  bool get isPushEnabled => _isPushEnabled;
  bool get isOrderEnabled => _isOrderEnabled;
  int get unreadCount => _unreadCount;

  NotificationProvider() {
    _loadSettings();
  }

  void init(String userId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      _unreadCount = snapshot.docs.length;
      notifyListeners();
    });
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPushEnabled = prefs.getBool(_pushKey) ?? true;
      _isOrderEnabled = prefs.getBool(_orderKey) ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  Future<void> setPushEnabled(bool value) async {
    _isPushEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushKey, value);
  }

  Future<void> setOrderEnabled(bool value) async {
    _isOrderEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_orderKey, value);
  }
}
