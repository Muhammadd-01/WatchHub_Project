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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// Core
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/constants/app_constants.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart'; // Added this import
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/theme_provider.dart';

// Services
import 'services/supabase_service.dart';
import 'services/seeder_service.dart';
import 'services/push_notification_service.dart';

// Screens
// Screens
import 'screens/main_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/splash_screen.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Handling a background message: ${message.messageId}');
}

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

  // Initialize Firebase Cloud Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final pushNotificationService = PushNotificationService();
  await pushNotificationService.initialize();

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
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
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
          // Removed initialRoute to use home with AuthWrapper
          home: const AuthWrapper(),
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.state) {
          case AuthState.authenticated:
            return const MainScreen();
          case AuthState.unauthenticated:
            return const LoginScreen();
          case AuthState.initial:
          default:
            return const SplashScreen();
        }
      },
    );
  }
}
