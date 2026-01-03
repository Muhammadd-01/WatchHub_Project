// =============================================================================
// FILE: app_routes.dart
// PURPOSE: Application routing configuration for WatchHub
// DESCRIPTION: Defines all named routes and route generation for navigation
//              throughout the app. Includes auth-protected routes.
// =============================================================================

import 'package:flutter/material.dart';
import '../../screens/profile/about_sub_pages.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/main_screen.dart';
import '../../screens/product/product_details_screen.dart';
import '../../screens/product/products_screen.dart';
import '../../screens/cart/cart_screen.dart';
import '../../screens/checkout/checkout_screen.dart';
import '../../screens/wishlist/wishlist_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/profile/settings_screen.dart';
import '../../screens/orders/orders_screen.dart';
import '../../screens/orders/order_details_screen.dart';
import '../../screens/reviews/reviews_screen.dart';
import '../../screens/reviews/write_review_screen.dart';
import '../../screens/feedback/feedback_screen.dart';
import '../../screens/home/search_screen.dart';
import '../../screens/home/category_screen.dart';
import '../../screens/notifications/notification_screen.dart';
import '../../screens/profile/about_screen.dart';
import '../../screens/profile/help_support_screen.dart';

/// Application route names
///
/// Use these constants for navigation to avoid typos.
class AppRoutes {
  // Private constructor
  AppRoutes._();

  // ===========================================================================
  // AUTH ROUTES
  // ===========================================================================
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // ===========================================================================
  // MAIN ROUTES
  // ===========================================================================
  static const String main = '/main';
  static const String home = '/home';
  static const String search = '/search';
  static const String category = '/category';
  static const String products = '/products';
  static const String productDetails = '/product-details';

  // ===========================================================================
  // CART & CHECKOUT
  // ===========================================================================
  static const String cart = '/cart';
  static const String checkout = '/checkout';

  // ===========================================================================
  // USER ROUTES
  // ===========================================================================
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings'; // Added settings route
  static const String wishlist = '/wishlist';
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';
  static const String notifications = '/notifications';
  static const String about = '/about';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String licenses = '/licenses';
  static const String help = '/help';

  // ===========================================================================
  // REVIEWS & FEEDBACK
  // ===========================================================================
  static const String reviews = '/reviews';
  static const String writeReview = '/write-review';
  static const String feedback = '/feedback';

  // ===========================================================================
  // ROUTE GENERATION
  // ===========================================================================

  /// Generates routes based on settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments
    final args = settings.arguments;

    switch (settings.name) {
      // Auth routes
      case splash:
        return _buildRoute(const SplashScreen(), settings);

      case login:
        return _buildRoute(const LoginScreen(), settings);

      case signup:
        return _buildRoute(const SignupScreen(), settings);

      case forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);

      // Main routes
      case main:
        return _buildRoute(const MainScreen(), settings);

      case home:
        return _buildRoute(const HomeScreen(), settings);

      case search:
        return _buildRoute(const SearchScreen(), settings);

      case category:
        final categoryArgs = args as Map<String, dynamic>?;
        return _buildRoute(
          CategoryScreen(
            title: categoryArgs?['title'] ?? 'Products',
            brand: categoryArgs?['brand'],
            category: categoryArgs?['category'],
          ),
          settings,
        );

      case products:
        final productArgs = args as Map<String, dynamic>?;
        return _buildRoute(
          ProductsScreen(
            title: productArgs?['title'] ?? 'All Watches',
            brand: productArgs?['brand'],
            category: productArgs?['category'],
          ),
          settings,
        );

      case productDetails:
        final productId = args as String;
        return _buildRoute(
          ProductDetailsScreen(productId: productId),
          settings,
        );

      // Cart & Checkout
      case cart:
        return _buildRoute(const CartScreen(), settings);

      case checkout:
        return _buildRoute(const CheckoutScreen(), settings);

      // User routes
      case profile:
        return _buildRoute(const ProfileScreen(), settings);

      case editProfile:
        return _buildRoute(const EditProfileScreen(), settings);

      case AppRoutes.settings:
        return _buildRoute(const SettingsScreen(), settings);

      case wishlist:
        return _buildRoute(const WishlistScreen(), settings);

      case orders:
        return _buildRoute(const OrdersScreen(), settings);

      case orderDetails:
        final orderId = args as String;
        return _buildRoute(OrderDetailsScreen(orderId: orderId), settings);

      case notifications:
        return _buildRoute(const NotificationScreen(), settings);

      case about:
        return _buildRoute(const AboutScreen(), settings);

      case terms:
        return _buildRoute(const TermsOfServicePage(), settings);

      case privacy:
        return _buildRoute(const PrivacyPolicyPage(), settings);

      case licenses:
        return _buildRoute(const AppLicensePage(), settings);

      case help:
        return _buildRoute(const HelpSupportScreen(), settings);

      // Reviews & Feedback
      case reviews:
        final productId = args as String;
        return _buildRoute(ReviewsScreen(productId: productId), settings);

      case writeReview:
        final productId = args as String;
        return _buildRoute(WriteReviewScreen(productId: productId), settings);

      case feedback:
        return _buildRoute(const FeedbackScreen(), settings);

      // Unknown route
      default:
        return _buildRoute(const _UnknownRouteScreen(), settings);
    }
  }

  /// Builds a material page route with fade transition
  static PageRouteBuilder<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  /// Builds a slide transition route
  static PageRouteBuilder<dynamic> _buildSlideRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

/// Unknown route fallback screen
class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you\'re looking for doesn\'t exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
