// =============================================================================
// FILE: admin_routes.dart
// PURPOSE: Routing configuration for Admin Panel
// DESCRIPTION: Defines all routes for the admin panel navigation.
// =============================================================================

import 'package:flutter/material.dart';
import '../../screens/auth/admin_login_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/products/products_list_screen.dart';
import '../../screens/orders/orders_list_screen.dart';
import '../../screens/users/users_list_screen.dart';
import '../../screens/categories/categories_screen.dart';
import '../../screens/feedback/feedback_screen.dart';
import '../../screens/carts/active_carts_screen.dart';

/// Admin Panel Routes
class AdminRoutes {
  AdminRoutes._();

  // Route names
  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String addProduct = '/products/add';
  static const String editProduct = '/products/edit';
  static const String orders = '/orders';
  static const String orderDetails = '/orders/details';
  static const String users = '/users';
  static const String userDetails = '/users/details';
  static const String categories = '/categories';
  static const String feedback = '/feedback';
  static const String carts = '/carts';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());

      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case products:
        return MaterialPageRoute(builder: (_) => const ProductsListScreen());

      case orders:
        return MaterialPageRoute(builder: (_) => const OrdersListScreen());

      case users:
        return MaterialPageRoute(builder: (_) => const UsersListScreen());

      case categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen());

      case feedback:
        return MaterialPageRoute(builder: (_) => const FeedbackScreen());

      case carts:
        return MaterialPageRoute(builder: (_) => const ActiveCartsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
