// =============================================================================
// FILE: admin_user_provider.dart
// PURPOSE: Manage Users (Promote, Demote, Delete)
// DESCRIPTION: Logic for user management with Super Admin protection.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Promote user to admin
  Future<bool> updateUserRole(String uid, String newRole) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection('users').doc(uid).update({'role': newRole});
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update role: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete user
  Future<bool> deleteUser(String uid, String email) async {
    // PROTECT SUPER ADMIN
    if (email == 'admin@watchhub.com') {
      _errorMessage = 'Cannot delete Super Admin!';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();
    try {
      // Note: This only deletes the Firestore doc.
      // Deleting Authentication user requires Firebase Admin SDK (Cloud Functions)
      // or re-authenticating as that user, which we can't do easily here.
      // For now, we will mark them as disabled or just delete the doc so they can't login
      // (if your app checks firestore doc on login).

      // We'll delete the doc.
      await _firestore.collection('users').doc(uid).delete();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete user: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
