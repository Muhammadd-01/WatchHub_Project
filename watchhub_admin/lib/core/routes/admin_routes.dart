// =============================================================================
// FILE: admin_routes.dart
// PURPOSE: Routing configuration for Admin Panel
// DESCRIPTION: Defines all routes for the admin panel navigation.
// =============================================================================

import 'package:flutter/material.dart';
import '../../screens/auth/admin_login_screen.dart';
import '../../screens/auth/admin_forgot_password_screen.dart';
import '../../screens/admin_main_screen.dart';
// Sub-pages that are PUSHED on top of the shell:
// (Currently none, as Add/Edit Product is a dialog. If we have Detail pages, import them here)

/// Admin Panel Routes
class AdminRoutes {
  AdminRoutes._();

  // Route names
  static const String login = '/';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard =
      '/dashboard'; // Used for redirection after login

  // These might be used for deeplinking later, or sub-pages.
  // For now, the main tabs are inside AdminMainScreen and don't need named routes
  // unless we implement deep linking logic in MainScreen.

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());

      case forgotPassword:
        return MaterialPageRoute(
            builder: (_) => const AdminForgotPasswordScreen());

      case dashboard:
        // This is now the "Main App Shell"
        return MaterialPageRoute(builder: (_) => const AdminMainScreen());

      default:
        // Fallback
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
