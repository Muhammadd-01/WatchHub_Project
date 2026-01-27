// =============================================================================
// FILE: main.dart
// PURPOSE: Admin Panel entry point for WatchHub
// DESCRIPTION: Web-based admin panel for managing products, orders, and users.
//              This is a base structure with placeholder screens.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Core
import 'core/theme/admin_theme.dart';
import 'core/routes/admin_routes.dart';

// Screens
// Screens
import 'screens/auth/admin_login_screen.dart';
import 'screens/admin_main_screen.dart';

// Providers
import 'providers/admin_auth_provider.dart';
import 'providers/admin_product_provider.dart';
import 'providers/admin_order_provider.dart';
import 'providers/admin_user_provider.dart';
import 'providers/admin_category_provider.dart';
import 'providers/admin_feedback_provider.dart';
import 'providers/admin_cart_provider.dart';
import 'providers/admin_dashboard_provider.dart';
import 'providers/admin_navigation_provider.dart';
import 'providers/admin_theme_provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase using the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://gsoxyadehywfpeuuyger.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdzb3h5YWRlaHl3ZnBldXV5Z2VyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2MTc0ODIsImV4cCI6MjA4MzE5MzQ4Mn0.MWeLkq2O5rCpF4_MJjqALXhtVeB3mozXKTvVb-WI6eM',
  );

  runApp(const WatchHubAdminApp());
}

/// WatchHub Admin Panel Application
class WatchHubAdminApp extends StatelessWidget {
  const WatchHubAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProductProvider()),
        ChangeNotifierProvider(create: (_) => AdminOrderProvider()),
        ChangeNotifierProvider(create: (_) => AdminUserProvider()),
        ChangeNotifierProvider(create: (_) => AdminCategoryProvider()),
        ChangeNotifierProvider(create: (_) => AdminFeedbackProvider()),
        ChangeNotifierProvider(create: (_) => AdminCartProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
        ChangeNotifierProvider(create: (_) => AdminNavigationProvider()),
        ChangeNotifierProvider(create: (_) => AdminThemeProvider()),
      ],
      child: Consumer<AdminThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'WatchHub Admin',
            debugShowCheckedModeBanner: false,
            theme: AdminTheme.lightTheme,
            darkTheme: AdminTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            // Remove initialRoute, use home with AuthWrapper
            home: const AuthWrapper(),
            onGenerateRoute: AdminRoutes.generateRoute,
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Trigger an initial check or just rely on the listener internally
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminAuthProvider>(
      builder: (context, auth, _) {
        // Wrap in SafeArea for mobile devices to prevent content going above status bar
        return SafeArea(
          child: auth.isAuthenticated
              ? const AdminMainScreen()
              : const AdminLoginScreen(),
        );
      },
    );
  }
}
