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

// Core
import 'core/theme/admin_theme.dart';
import 'core/routes/admin_routes.dart';

// Providers
import 'providers/admin_auth_provider.dart';
import 'providers/admin_product_provider.dart';
import 'providers/admin_order_provider.dart';
import 'providers/admin_user_provider.dart';
import 'providers/admin_category_provider.dart';
import 'providers/admin_feedback_provider.dart';
import 'providers/admin_cart_provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://vjrqmftfwhxhpbfuwrws.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZqcnFtZnRmd2h4aHBiZnV3cndzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDM2OTg5MDYsImV4cCI6MjAyNTI3NDkwNn0.C7u-P4Q9T-6u3k8m2_3_9_3_9_3_9_3_9_3_9_3_9_3',
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
      ],
      child: MaterialApp(
        title: 'WatchHub Admin',
        debugShowCheckedModeBanner: false,
        theme: AdminTheme.darkTheme,
        initialRoute: AdminRoutes.login,
        onGenerateRoute: AdminRoutes.generateRoute,
      ),
    );
  }
}
