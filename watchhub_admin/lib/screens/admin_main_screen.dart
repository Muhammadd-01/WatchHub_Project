// =============================================================================
// FILE: admin_main_screen.dart
// PURPOSE: Main Shell for Admin Panel
// DESCRIPTION: Holds the Sidebar and the IndexedStack of pages.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_navigation_provider.dart';
import '../../widgets/admin_sidebar.dart';

// Screens
import 'dashboard/dashboard_screen.dart';
import 'products/products_list_screen.dart';
import 'orders/orders_list_screen.dart';
import 'users/users_list_screen.dart';
import 'categories/categories_screen.dart';
import 'feedback/feedback_screen.dart';
import 'carts/active_carts_screen.dart';
import 'reviews/reviews_screen.dart';
import 'profile/admin_profile_screen.dart';
import 'settings/settings_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  final List<Widget> _pages = [
    const DashboardScreen(), // 0
    const ProductsListScreen(), // 1
    const CategoriesScreen(), // 2
    const OrdersListScreen(), // 3
    const ActiveCartsScreen(), // 4
    const UsersListScreen(), // 5
    const ReviewsScreen(), // 6
    const FeedbackScreen(), // 7
    const AdminProfileScreen(), // 8
    const SettingsScreen(), // 9
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Consumer<AdminNavigationProvider>(
      builder: (context, nav, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          // On mobile, we use a Drawer. On desktop, we show Sidebar in a Row.
          drawer: isDesktop
              ? null
              : Drawer(
                  backgroundColor: Theme.of(context).cardColor,
                  child: AdminSidebar(
                    selectedIndex: nav.currentIndex,
                    onItemSelected: (index) {
                      nav.setIndex(index);
                      Navigator.pop(context); // Close drawer
                    },
                  ),
                ),
          body: Row(
            children: [
              // Desktop Sidebar
              if (isDesktop)
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      right: BorderSide(
                          color: Theme.of(context).dividerColor, width: 1),
                    ),
                  ),
                  child: AdminSidebar(
                    selectedIndex: nav.currentIndex,
                    onItemSelected: (index) {
                      nav.setIndex(index);
                    },
                  ),
                ),

              // Main Content
              Expanded(
                child: IndexedStack(
                  index: nav.currentIndex,
                  children: _pages,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
