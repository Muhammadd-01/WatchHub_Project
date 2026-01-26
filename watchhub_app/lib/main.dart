import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Main entry point
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (not supported on web)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    AppTheme.setSystemUIOverlayStyle();
  }

  // Initialize Firebase with generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Push Notifications (OneSignal) - not supported on web
  if (!kIsWeb) {
    final pushNotificationService = PushNotificationService();
    try {
      await pushNotificationService.initialize(navigatorKey);
    } catch (e) {
      debugPrint('main: Error initializing PushNotificationService - $e');
    }
  }

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await SupabaseService.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
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
