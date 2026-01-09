// =============================================================================
// FILE: auth0_service.dart
// PURPOSE: Auth0 Authentication Service
// DESCRIPTION: Handles authentication using Auth0 (Social Login).
// =============================================================================

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Auth0Service {
  late Auth0 _auth0;
  bool _isInitialized = false;

  // Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Load environment variables if not already loaded
    if (!dotenv.isInitialized) {
      await dotenv.load(fileName: ".env");
    }

    final domain = dotenv.env['AUTH0_DOMAIN'];
    final clientId = dotenv.env['AUTH0_CLIENT_ID'];

    if (domain == null || clientId == null) {
      debugPrint('Auth0Service: Missing configuration in .env');
      return; // Or throw an exception
    }

    _auth0 = Auth0(domain, clientId);
    _isInitialized = true;
    debugPrint('Auth0Service: Initialized with domain $domain');
  }

  /// Login with Auth0
  ///
  /// [connection] - Optional connection name:
  /// - 'google-oauth2' for Google Sign-In
  /// - 'facebook' for Facebook Sign-In
  /// - null for Universal Login (shows all enabled connections)
  Future<Credentials?> login({String? connection}) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final credentials = await _auth0.webAuthentication(scheme: 'demo').login(
            parameters: connection != null ? {'connection': connection} : {},
          );
      debugPrint(
          'Auth0Service: Login successful. User: ${credentials.user.name}');
      return credentials;
    } catch (e) {
      debugPrint('Auth0Service: Login error - $e');
      return null;
    }
  }

  /// Logout from Auth0
  Future<void> logout() async {
    if (!_isInitialized) await initialize();

    try {
      await _auth0.webAuthentication(scheme: 'demo').logout();
      debugPrint('Auth0Service: Logout successful');
    } catch (e) {
      debugPrint('Auth0Service: Logout error - $e');
    }
  }

  // Get current credentials (if valid)
  Future<Credentials?> getCredentials() async {
    if (!_isInitialized) await initialize();
    try {
      return await _auth0.credentialsManager.credentials();
    } catch (e) {
      return null;
    }
  }
}
