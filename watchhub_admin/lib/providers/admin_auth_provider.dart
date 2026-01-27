// =============================================================================
// FILE: admin_auth_provider.dart
// PURPOSE: Authentication state management for Admin Panel
// DESCRIPTION: Manages admin authentication state.
// TODO: Implement full admin authentication with role verification
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = false;
  bool _isAdmin = false;
  String? _errorMessage;
  String? _adminName;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _isAdmin;
  bool get isAdmin => _isAdmin;
  String? get errorMessage => _errorMessage;
  String? get adminName => _adminName;
  String? get adminEmail => _user?.email;
  String? get userId => _user?.uid;

  AdminAuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      await _checkAdminRole(user.uid);
    } else {
      _isAdmin = false;
      _adminName = null;
    }
    notifyListeners();
  }

  Future<void> _checkAdminRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        _isAdmin = data?['role'] == 'admin';
        _adminName = data?['name'] as String?;
      }
    } catch (e) {
      debugPrint('Error checking admin role: $e');
      _isAdmin = false;
    }
  }

  /// Update admin profile
  Future<void> updateProfile({String? name}) async {
    if (_user == null) return;

    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;

      await _firestore.collection('users').doc(_user!.uid).update(updates);
      _adminName = name;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating admin profile: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  /// TODO: Add additional admin verification
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _checkAdminRole(credential.user!.uid);
        if (!_isAdmin) {
          await _auth.signOut();
          _errorMessage = 'Access denied. Admin privileges required.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Authentication failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _isAdmin = false;
    _adminName = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Seeds a default super admin user if it doesn't exist.
  /// Email: admin@watchhub.com, Password: admin123
  Future<bool> seedDefaultAdmin() async {
    try {
      // Attempt to create the user
      final credential = await _auth.createUserWithEmailAndPassword(
          email: 'admin@watchhub.com', password: 'admin123');

      // If successful, we are logged in. Create the admin document.
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'name': 'Super Admin',
          'email': 'admin@watchhub.com',
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'phone': '',
        });

        // Update local state
        _isAdmin = true;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // User exists. We can't log them in without password, but we assume
        // the developer knows the password 'admin123'.
        print('Default admin already exists.');
      } else {
        print('Error seeding admin: ${e.message}');
      }
    } catch (e) {
      print('Error seeding admin: $e');
    }
    return false;
  }
}
