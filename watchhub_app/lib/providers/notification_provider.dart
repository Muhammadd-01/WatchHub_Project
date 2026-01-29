import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firestore_crud_service.dart';
import 'dart:async';

class NotificationProvider extends ChangeNotifier {
  static const String _pushKey = 'push_notifications_enabled';
  static const String _orderKey = 'order_notifications_enabled';

  bool _isPushEnabled = true;
  bool _isOrderEnabled = true;
  int _unreadCount = 0;
  StreamSubscription? _unreadSubscription;
  final FirestoreCrudService _firestoreService = FirestoreCrudService();

  String? _userId;

  bool get isPushEnabled => _isPushEnabled;
  bool get isOrderEnabled => _isOrderEnabled;
  int get unreadCount => _unreadCount;

  NotificationProvider() {
    _loadSettings();
  }

  void init(String userId) {
    if (_userId == userId) return; // Already initialized for this user

    _userId = userId;
    _loadRemoteSettings();

    // Cancel existing subscription if any
    _unreadSubscription?.cancel();

    _unreadSubscription = FirebaseFirestore.instance
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

  Future<void> markAllAsRead() async {
    if (_userId == null) return;
    try {
      await _firestoreService.markAllNotificationsRead(_userId!);
      // Count will be updated automatically by the stream listener
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
    }
  }

  @override
  void dispose() {
    _unreadSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPushEnabled = prefs.getBool(_pushKey) ?? true;
      _isOrderEnabled = prefs.getBool(_orderKey) ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading local notification settings: $e');
    }
  }

  Future<void> _loadRemoteSettings() async {
    if (_userId == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _isPushEnabled = data['pushNotificationsEnabled'] ?? true;
        _isOrderEnabled = data['orderUpdatesEnabled'] ?? true;

        // Sync to local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_pushKey, _isPushEnabled);
        await prefs.setBool(_orderKey, _isOrderEnabled);

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading remote notification settings: $e');
    }
  }

  Future<void> setPushEnabled(bool value) async {
    _isPushEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushKey, value);

    // Sync to Firestore
    if (_userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .update({'pushNotificationsEnabled': value});
    }
  }

  Future<void> setOrderEnabled(bool value) async {
    _isOrderEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_orderKey, value);

    // Sync to Firestore
    if (_userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .update({'orderUpdatesEnabled': value});
    }
  }
}
