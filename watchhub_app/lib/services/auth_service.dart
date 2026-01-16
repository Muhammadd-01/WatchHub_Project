// =============================================================================
// FILE: auth_service.dart
// PURPOSE: Firebase Authentication service for WatchHub
// DESCRIPTION: Handles all authentication operations including signup, login,
//              logout, and password reset. CRITICAL: On signup, automatically
//              creates a user document in Firestore using the Firebase Auth UID.
// =============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'auth0_service.dart';
import '../models/user_model.dart';
import 'firestore_crud_service.dart';

/// Authentication service using Firebase Auth
///
/// CRITICAL FLOW - User Signup:
/// 1. Create user in Firebase Authentication
/// 2. Get the UID from the created user
/// 3. IMMEDIATELY create a document in Firestore at users/{uid}
/// 4. The UID is stored in the document AND used as the document ID
///
/// This ensures consistent user identification across all services.
class AuthService {
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore CRUD service for creating user documents
  final FirestoreCrudService _firestoreService = FirestoreCrudService();

  // ===========================================================================
  // AUTH STATE
  // ===========================================================================

  /// Stream of authentication state changes
  ///
  /// Returns a stream that emits the current user whenever auth state changes.
  /// Useful for reactive UI updates.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in user (null if not signed in)
  User? get currentUser => _auth.currentUser;

  /// Current user's UID (null if not signed in)
  String? get currentUid => _auth.currentUser?.uid;

  /// Whether a user is currently signed in
  bool get isSignedIn => _auth.currentUser != null;

  // ===========================================================================
  // SIGN UP
  // ===========================================================================

  /// Signs up a new user with email and password
  ///
  /// CRITICAL: This method:
  /// 1. Creates the user in Firebase Authentication
  /// 2. Gets the UID from Firebase Auth
  /// 3. Creates a user document in Firestore at users/{uid}
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password (min 6 characters)
  /// - [name]: User's full name
  /// - [phone]: User's phone number (optional)
  ///
  /// Returns the created [UserModel] on success.
  /// Throws [AuthException] on failure.
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      // Step 1: Create user in Firebase Authentication
      debugPrint('AuthService: Creating user in Firebase Auth...');

      User? firebaseUser;

      try {
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        firebaseUser = userCredential.user;
      } catch (e) {
        // CRITICAL FIX: Handle "PigeonUserDetails" type cast error
        // Sometimes the plugin throws a TypeError/CastError even if creation succeeded
        if (e.toString().contains('PigeonUserDetails') || e is TypeError) {
          debugPrint('AuthService: Caught potential type error: $e');
          debugPrint('AuthService: Checking if user was actually created...');

          // Check if we have a current user despite the error
          firebaseUser = _auth.currentUser;

          if (firebaseUser != null && firebaseUser.email == email.trim()) {
            debugPrint(
                'AuthService: RECOVERED from cast error. User exists: ${firebaseUser.uid}');
          } else {
            rethrow; // Genuine failure
          }
        } else {
          rethrow; // Genuine other error
        }
      }

      // Step 2: Get the UID from the created user
      if (firebaseUser == null) {
        throw AuthException('Failed to create user account');
      }

      final String uid = firebaseUser.uid;
      debugPrint('AuthService: User created with UID: $uid');

      // Step 3: Update display name in Firebase Auth
      try {
        await firebaseUser.updateDisplayName(name);
      } catch (e) {
        debugPrint('AuthService: Warning - Failed to update display name: $e');
        // Continue anyway, this is non-critical
      }

      // Step 4: Create user document in Firestore
      // CRITICAL: The document ID is the Firebase Auth UID
      debugPrint('AuthService: Creating Firestore user document...');

      final UserModel userModel = UserModel(
        uid: uid, // Same as Firebase Auth UID
        name: name,
        email: email.trim(),
        phone: phone,
        createdAt: DateTime.now(),
      );

      // Create the user document using the UID as document ID
      await _firestoreService.createUser(userModel);

      debugPrint('AuthService: User signup complete. UID: $uid');

      return userModel;
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Firebase Auth Error - ${e.code}: ${e.message}');
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('AuthService: Error during signup - $e');
      rethrow;
    }
  }

  // ===========================================================================
  // SIGN IN
  // ===========================================================================

  /// Signs in an existing user with email and password
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  ///
  /// Returns the [UserModel] from Firestore on success.
  /// Throws [AuthException] on failure.
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('AuthService: Signing in user...');

      User? firebaseUser;

      try {
        // Sign in with Firebase Auth
        final UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(
                email: email.trim(), password: password);
        firebaseUser = userCredential.user;
      } catch (e) {
        // CRITICAL FIX: Handle "PigeonUserDetails" type cast error for Login
        if (e.toString().contains('PigeonUserDetails') || e is TypeError) {
          debugPrint(
              'AuthService: Caught potential type error during login: $e');

          // Check if we have a current user despite the error
          firebaseUser = _auth.currentUser;

          if (firebaseUser != null && firebaseUser.email == email.trim()) {
            debugPrint(
                'AuthService: RECOVERED from login cast error. User: ${firebaseUser.uid}');
          } else {
            rethrow;
          }
        } else {
          rethrow;
        }
      }

      if (firebaseUser == null) {
        throw AuthException('Failed to sign in');
      }

      final String uid = firebaseUser.uid;
      debugPrint('AuthService: Signed in with UID: $uid');

      // Fetch user data from Firestore
      final UserModel? userModel = await _firestoreService.getUser(uid);

      if (userModel == null) {
        // User exists in Auth but not in Firestore (edge case)
        // Create the Firestore document
        debugPrint('AuthService: User document not found, creating...');

        final newUserModel = UserModel(
          uid: uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? email,
          createdAt: DateTime.now(),
        );

        await _firestoreService.createUser(newUserModel);
        return newUserModel;
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Firebase Auth Error - ${e.code}: ${e.message}');
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('AuthService: Error during sign in - $e');
      rethrow;
    }
  }

  // Auth0 Service
  final Auth0Service _auth0Service = Auth0Service();

  /// Constructor - Initialize Auth0
  AuthService() {
    _initializeAuth0();
  }

  Future<void> _initializeAuth0() async {
    try {
      await _auth0Service.initialize();
    } catch (e) {
      debugPrint('AuthService: Failed to initialize Auth0 - $e');
    }
  }

  // ===========================================================================
  // SOCIAL SIGN IN (Auth0)
  // ===========================================================================

  /// Signs in using Auth0 with Google
  ///
  /// CALLED FROM:
  /// - LoginScreen (via AuthProvider)
  /// - SignupScreen (via AuthProvider)
  ///
  /// DESCRIPTION:
  /// Initiates the Auth0 login flow specifically for Google.
  /// 1. Opens Auth0 Web Auth with Google connection.
  /// 2. User signs in with Google account.
  /// 3. Returns Auth0 Credentials.
  /// 4. Checks if user exists in Firestore (using Auth0 'sub' as UID).
  /// Signs in using Auth0 with Google
  Future<UserModel> signInWithGoogle() async {
    return signInWithSocial(connection: 'google-oauth2');
  }

  /// Signs in using Auth0 with Facebook
  Future<UserModel> signInWithFacebook() async {
    return signInWithSocial(connection: 'facebook');
  }

  /// Internal method to handle Auth0 sign-in with specific connection
  Future<UserModel> signInWithSocial({String? connection}) async {
    try {
      debugPrint(
          'AuthService: Starting Auth0 Sign In with ${connection ?? "Universal Login"}...');

      // 1. Trigger Auth0 login with specific connection
      final credentials = await _auth0Service.login(connection: connection);

      if (credentials == null) {
        throw AuthException('Sign in canceled or failed');
      }

      final auth0User = credentials.user;
      final String uid = auth0User.sub; // Use Auth0 Subject ID as UID

      debugPrint('AuthService: Auth0 Sign In successful. UID: $uid');

      // 2. Check if user exists in Firestore
      final UserModel? existingUser = await _firestoreService.getUser(uid);

      if (existingUser != null) {
        return existingUser;
      }

      // 3. Create new user document
      debugPrint('AuthService: Creating new user document for Auth0 user...');

      final newUser = UserModel(
        uid: uid,
        name: auth0User.name ?? auth0User.nickname ?? 'User',
        email: auth0User.email ?? '',
        createdAt: DateTime.now(),
        profileImageUrl: auth0User.pictureUrl?.toString(),
      );

      await _firestoreService.createUser(newUser);
      debugPrint(
          'AuthService: User document created with profile picture: ${newUser.profileImageUrl}');

      return newUser;
    } catch (e) {
      debugPrint('AuthService: Auth0 Login Error - $e');
      throw AuthException('Failed to sign in with $connection');
    }
  }

  /// Logs out from Auth0 and Firebase
  Future<void> socialLogout() async {
    try {
      await _auth0Service.logout();
    } catch (e) {
      debugPrint('AuthService: Auth0 logout error - $e');
    }
  }

  // ===========================================================================
  // SIGN OUT
  // ===========================================================================

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      debugPrint('AuthService: Signing out...');
      await socialLogout(); // Ensure Auth0 logout
      await _auth.signOut();
      debugPrint('AuthService: Sign out complete');
    } catch (e) {
      debugPrint('AuthService: Error during sign out - $e');
      throw AuthException('Failed to sign out');
    }
  }

  // ===========================================================================
  // PASSWORD RESET
  // ===========================================================================

  /// Sends a password reset email to the specified address
  ///
  /// Parameters:
  /// - [email]: Email address to send reset link to
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('AuthService: Sending password reset email to $email');
      await _auth.sendPasswordResetEmail(email: email.trim());
      debugPrint('AuthService: Password reset email sent');
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Firebase Auth Error - ${e.code}: ${e.message}');
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('AuthService: Error sending reset email - $e');
      throw AuthException('Failed to send password reset email');
    }
  }

  // ===========================================================================
  // EMAIL VERIFICATION
  // ===========================================================================

  /// Sends an email verification to the current user
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        debugPrint('AuthService: Verification email sent');
      }
    } catch (e) {
      debugPrint('AuthService: Error sending verification email - $e');
      throw AuthException('Failed to send verification email');
    }
  }

  /// Reloads the current user to check email verification status
  Future<bool> checkEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      debugPrint('AuthService: Error checking email verification - $e');
      return false;
    }
  }

  // ===========================================================================
  // UPDATE PROFILE
  // ===========================================================================

  /// Updates the current user's display name in Firebase Auth
  Future<void> updateDisplayName(String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name);
      debugPrint('AuthService: Display name updated');
    } catch (e) {
      debugPrint('AuthService: Error updating display name - $e');
      throw AuthException('Failed to update display name');
    }
  }

  /// Updates the current user's email in Firebase Auth
  ///
  /// Note: This may require recent authentication
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
      debugPrint('AuthService: Email update verification sent');
    } catch (e) {
      debugPrint('AuthService: Error updating email - $e');
      throw AuthException('Failed to update email');
    }
  }

  /// Updates the current user's password
  ///
  /// Note: This may require recent authentication
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      debugPrint('AuthService: Password updated');
    } catch (e) {
      debugPrint('AuthService: Error updating password - $e');
      throw AuthException('Failed to update password');
    }
  }

  // ===========================================================================
  // RE-AUTHENTICATION
  // ===========================================================================

  /// Re-authenticates the current user (required for sensitive operations)
  Future<void> reauthenticate(String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _auth.currentUser?.reauthenticateWithCredential(credential);
      debugPrint('AuthService: Re-authentication successful');
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('AuthService: Error during re-authentication - $e');
      throw AuthException('Re-authentication failed');
    }
  }

  // ===========================================================================
  // DELETE ACCOUNT
  // ===========================================================================

  /// Deletes the current user's account
  ///
  /// This will:
  /// 1. Delete the user from Firebase Authentication
  /// 2. The Firestore user document should be cleaned up separately
  Future<void> deleteAccount() async {
    try {
      final uid = currentUid;
      if (uid != null) {
        // Delete user data from Firestore first
        await _firestoreService.deleteUser(uid);
      }

      // Then delete from Firebase Auth
      await _auth.currentUser?.delete();
      debugPrint('AuthService: Account deleted');
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('AuthService: Error deleting account - $e');
      throw AuthException('Failed to delete account');
    }
  }

  // ===========================================================================
  // ERROR MESSAGES
  // ===========================================================================

  /// Converts Firebase Auth error codes to user-friendly messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists with this email address';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled';
      case 'weak-password':
        return 'Please choose a stronger password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'An error occurred. Please try again';
    }
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
