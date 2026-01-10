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

import 'package:shared_preferences/shared_preferences.dart';

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
import 'providers/notification_provider.dart';
import 'providers/search_provider.dart';

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

  // 1. Load settings from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isPushEnabled = prefs.getBool('push_notifications_enabled') ?? true;
  final isOrderEnabled = prefs.getBool('order_notifications_enabled') ?? true;

  // 2. Suppress if push is disabled
  if (!isPushEnabled) {
    debugPrint('BackgroundHandler: Push notifications disabled. Skipping.');
    return;
  }

  // 3. Suppress if order update and order notifications disabled
  final notification = message.notification;
  if (notification != null) {
    final title = notification.title?.toLowerCase() ?? '';
    final body = notification.body?.toLowerCase() ?? '';
    final isOrderUpdate = title.contains('order') ||
        body.contains('order') ||
        title.contains('status') ||
        body.contains('ship');

    if (isOrderUpdate && !isOrderEnabled) {
      debugPrint('BackgroundHandler: Order updates disabled. Skipping.');
      return;
    }
  }

  debugPrint('BackgroundHandler: Notification allowed.');
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
  try {
    await pushNotificationService.initialize(navigatorKey);
  } catch (e) {
    debugPrint('main: Error initializing PushNotificationService - $e');
  }

  // Initialize Supabase
  await SupabaseService.initialize(
    url: 'https://gsoxyadehywfpeuuyger.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdzb3h5YWRlaHl3ZnBldXV5Z2VyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2MTc0ODIsImV4cCI6MjA4MzE5MzQ4Mn0.MWeLkq2O5rCpF4_MJjqALXhtVeB3mozXKTvVb-WI6eM',
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
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
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

          // Navigation
          navigatorKey: navigatorKey,

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
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildAuthScreen(context, auth),
        );
      },
    );
  }

  Widget _buildAuthScreen(BuildContext context, AuthProvider auth) {
    switch (auth.state) {
      case AuthState.authenticated:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (auth.user != null) {
            final notifProvider =
                Provider.of<NotificationProvider>(context, listen: false);
            notifProvider.init(auth.user!.uid);
          }
        });
        return const MainScreen(key: ValueKey('main_screen'));
      case AuthState.unauthenticated:
        return const LoginScreen(key: ValueKey('login_screen'));
      case AuthState.initial:
      default:
        return const SplashScreen(key: ValueKey('splash_screen'));
    }
  }
}
