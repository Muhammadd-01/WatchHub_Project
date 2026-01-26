// =============================================================================
// FILE: auth_provider.dart
// PURPOSE: Authentication state management for WatchHub
// DESCRIPTION: Manages authentication state, user data, and provides auth
//              methods to the UI layer. Uses Firebase Auth and Firestore.
// =============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_crud_service.dart';
import '../services/push_notification_service.dart';

/// Authentication state provider
///
/// PURPOSE:
/// Manages the application-wide authentication state. It acts as the bridge
/// between the UI (screens) and the backend services (AuthService, Firestore).
///
/// CALLED FROM:
/// - main.dart (AuthWrapper listens to state to switch between Login/Main screens)
/// - LoginScreen, SignupScreen (calls signIn, signUp, signInWithGoogle)
/// - ProfileScreen (calls signOut)
///
/// This provider:
/// - Manages authentication state (loading, authenticated, unauthenticated)
/// - Provides current user data from Firestore
/// - Exposes auth methods (signUp, signIn, signOut, etc.)
/// - Listens to auth state changes for reactive UI updates
class AuthProvider extends ChangeNotifier {
  // Services
  final AuthService _authService = AuthService();
  final FirestoreCrudService _firestoreService = FirestoreCrudService();

  // State
  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _errorMessage;
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;

  // Auth state subscription
  StreamSubscription<User?>? _authSubscription;

  // Getters
  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading =>
      _isEmailLoading || _isGoogleLoading || _isFacebookLoading;
  bool get isEmailLoading => _isEmailLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  bool get isFacebookLoading => _isFacebookLoading;
  bool get isAuthenticated =>
      _state == AuthState.authenticated && _user != null;
  String? get uid => _user?.uid ?? _authService.currentUid;

  /// Constructor - starts listening to auth state changes
  AuthProvider() {
    _initAuthListener();
  }

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  /// Initializes the auth state listener
  void _initAuthListener() {
    _authSubscription = _authService.authStateChanges.listen(
      _handleAuthStateChange,
      onError: (error) {
        debugPrint('AuthProvider: Auth stream error - $error');
        _setError('Authentication error occurred');
      },
    );
  }

  /// Handles auth state changes from Firebase
  Future<void> _handleAuthStateChange(User? firebaseUser) async {
    debugPrint('AuthProvider: Auth state changed - ${firebaseUser?.uid}');

    if (firebaseUser == null) {
      // User signed out
      _user = null;
      _state = AuthState.unauthenticated;
      notifyListeners();
    } else {
      // User signed in - fetch user data from Firestore
      try {
        final userModel = await _firestoreService.getUser(firebaseUser.uid);
        if (userModel != null) {
          _user = userModel;
          _state = AuthState.authenticated;
        } else {
          // User exists in Auth but not Firestore (edge case)
          _state = AuthState.authenticated;
          _user = UserModel(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'User',
            email: firebaseUser.email ?? '',
            createdAt: DateTime.now(),
          );
        }

        // Register user with OneSignal for push notifications
        if (!kIsWeb) {
          try {
            final pushService = PushNotificationService();
            await pushService.loginUser(firebaseUser.uid);
            debugPrint('AuthProvider: Linked user to OneSignal');
          } catch (e) {
            debugPrint('AuthProvider: Error linking to OneSignal - $e');
          }
        }

        notifyListeners();
      } catch (e) {
        debugPrint('AuthProvider: Error fetching user data - $e');
        _setError('Failed to load user data');
      }
    }
  }

  // ===========================================================================
  // SIGN UP
  // ===========================================================================

  /// Signs up a new user
  ///
  /// This will:
  /// 1. Create user in Firebase Auth
  /// 2. Create user document in Firestore with UID
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      _setEmailLoading(true);
      _clearError();

      final userModel = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      _user = userModel;
      _state = AuthState.authenticated;

      debugPrint('AuthProvider: Sign up successful - ${userModel.uid}');

      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      debugPrint('AuthProvider: Sign up error - $e');
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setEmailLoading(false);
    }
  }

  // ===========================================================================
  // SIGN IN
  // ===========================================================================

  /// Signs in an existing user
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setEmailLoading(true);
      _clearError();

      final userModel = await _authService.signIn(
        email: email,
        password: password,
      );

      _user = userModel;
      _state = AuthState.authenticated;

      debugPrint('AuthProvider: Sign in successful - ${userModel?.uid}');

      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      debugPrint('AuthProvider: Sign in error - $e');
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setEmailLoading(false);
    }
  }

  /// Signs in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setGoogleLoading(true);
      _clearError();

      final userModel = await _authService.signInWithGoogle();

      _user = userModel;
      _state = AuthState.authenticated;

      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      debugPrint('AuthProvider: Google sign in error - $e');
      _setError('Failed to sign in with Google');
      return false;
    } finally {
      _setGoogleLoading(false);
    }
  }

  /// Signs in with Facebook
  Future<bool> signInWithFacebook() async {
    try {
      _setFacebookLoading(true);
      _clearError();

      final userModel = await _authService.signInWithFacebook();

      _user = userModel;
      _state = AuthState.authenticated;

      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      debugPrint('AuthProvider: Facebook sign in error - $e');
      _setError('Failed to sign in with Facebook');
      return false;
    } finally {
      _setFacebookLoading(false);
    }
  }

  // ===========================================================================
  // SIGN OUT
  // ===========================================================================

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      _setEmailLoading(true);

      await _authService.signOut();

      _user = null;
      _state = AuthState.unauthenticated;

      debugPrint('AuthProvider: Sign out successful');

      notifyListeners();
    } catch (e) {
      debugPrint('AuthProvider: Sign out error - $e');
      _setError('Failed to sign out');
    } finally {
      _setEmailLoading(false);
    }
  }

  // ===========================================================================
  // PASSWORD RESET
  // ===========================================================================

  /// Sends a password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setEmailLoading(true);
      _clearError();

      await _authService.sendPasswordResetEmail(email);

      debugPrint('AuthProvider: Password reset email sent');

      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      debugPrint('AuthProvider: Password reset error - $e');
      _setError('Failed to send reset email');
      return false;
    } finally {
      _setEmailLoading(false);
    }
  }

  // ===========================================================================
  // UPDATE PROFILE
  // ===========================================================================

  /// Updates the user's profile information
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? profileImageUrl,
  }) async {
    if (_user == null) return false;

    try {
      _setEmailLoading(true);
      _clearError();

      final updates = <String, dynamic>{};

      if (name != null && name != _user!.name) {
        updates['name'] = name;
        await _authService.updateDisplayName(name);
      }

      if (phone != null) {
        updates['phone'] = phone;
      }

      if (address != null) {
        updates['address'] = address;
      }

      if (profileImageUrl != null) {
        updates['profileImageUrl'] = profileImageUrl;
      }

      if (updates.isNotEmpty) {
        await _firestoreService.updateUser(_user!.uid, updates);

        // Update local user model
        _user = _user!.copyWith(
          name: name ?? _user!.name,
          phone: phone ?? _user!.phone,
          address: address ?? _user!.address,
          profileImageUrl: profileImageUrl ?? _user!.profileImageUrl,
          updatedAt: DateTime.now(),
        );

        notifyListeners();
      }

      debugPrint('AuthProvider: Profile updated');

      return true;
    } catch (e) {
      debugPrint('AuthProvider: Update profile error - $e');
      _setError('Failed to update profile');
      return false;
    } finally {
      _setEmailLoading(false);
    }
  }

  // ===========================================================================
  // REFRESH USER
  // ===========================================================================

  /// Refreshes the user data from Firestore
  Future<void> refreshUser() async {
    if (uid == null) return;

    try {
      final userModel = await _firestoreService.getUser(uid!);
      if (userModel != null) {
        _user = userModel;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AuthProvider: Refresh user error - $e');
    }
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  void _setEmailLoading(bool loading) {
    _isEmailLoading = loading;
    notifyListeners();
  }

  void _setGoogleLoading(bool loading) {
    _isGoogleLoading = loading;
    notifyListeners();
  }

  void _setFacebookLoading(bool loading) {
    _isFacebookLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state =
          _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
  }

  /// Clears the current error message
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // ===========================================================================
  // CLEANUP
  // ===========================================================================

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Authentication state enum
enum AuthState {
  /// Initial state before checking auth
  initial,

  /// User is authenticated
  authenticated,

  /// User is not authenticated
  unauthenticated,

  /// An error occurred
  error,
}
