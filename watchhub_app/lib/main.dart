// =============================================================================
// FILE: main.dart
// PURPOSE: Application entry point for WatchHub
// DESCRIPTION: Initializes Firebase, Supabase, and providers.
//              Sets up the Material app with routing and theming.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Core
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/constants/app_constants.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/theme_provider.dart';

// Services
import 'services/supabase_service.dart';
import 'services/seeder_service.dart';

/// Main entry point
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  AppTheme.setSystemUIOverlayStyle();

  // Initialize Firebase with generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase
  await SupabaseService.initialize(
    url: 'https://mpsiczyqptlhxbukzwfj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1wc2ljenlxcHRsaHhidWt6d2ZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY5MDczMDYsImV4cCI6MjA4MjQ4MzMwNn0.xWwTDK6VoXvjjTDDYYWO5PVqOzZRGBd7T11JRHXne-g',
  );

  // Seed database with sample products if needed
  final seeder = SeederService();
  await seeder.seedIfNeeded();

  // Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const WatchHubApp(),
    ),
  );
}

/// Root widget of the application
class WatchHubApp extends StatelessWidget {
  const WatchHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          // App info
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,

          // Theme Configuration
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          // Routing
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,

          // Global scroll behavior
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            physics: const BouncingScrollPhysics(),
          ),
        );
      },
    );
  }
}
