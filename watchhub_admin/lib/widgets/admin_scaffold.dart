// =============================================================================
// FILE: admin_scaffold.dart
// PURPOSE: Main layout scaffold for Admin Panel
// DESCRIPTION: Provides responsive layout with sidebar and header.
// =============================================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/admin_routes.dart';

class AdminScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;

  const AdminScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    // Basic responsive check
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(title, style: AppTextStyles.appBarTitle),
              backgroundColor: AppColors.scaffoldBackground,
              actions: actions,
            ),
      drawer: isDesktop ? null : _buildSidebar(context),
      body: Row(
        children: [
          // Sidebar for desktop
          if (isDesktop)
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(
                  right: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: _buildSidebar(context),
            ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                if (isDesktop) _buildDesktopHeader(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // If it's a sub-page, show back button?
              // Since we use pushReplacement for sidebar, the stack is usually 1 deep.
              // But if we open "Add Product" (dialog) or potential future detail screens:
              // We'll unconditionally add it if requested, or check navigator.
              // Adding a manual back button as requested:
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    // Maybe show a meaningful message or do nothing
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No previous page to go back to.')));
                  }
                },
                tooltip: 'Go Back',
              ),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.displaySmall),
            ],
          ),
          Row(
            children: actions ?? [],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Column(
      children: [
        // Logo
        Container(
          height: 100,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.goldGradient,
                ),
                child: const Icon(Icons.watch, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 12),
              Text('WatchHub', style: AppTextStyles.headlineSmall),
            ],
          ),
        ),
        const Divider(color: AppColors.divider, height: 1),

        // Navigation
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            children: [
              _buildNavItem(context, 'Dashboard', Icons.dashboard_outlined,
                  AdminRoutes.dashboard),
              _buildNavItem(context, 'Products', Icons.inventory_2_outlined,
                  AdminRoutes.products),
              _buildNavItem(context, 'Categories', Icons.category_outlined,
                  AdminRoutes.categories),
              _buildNavItem(context, 'Orders', Icons.shopping_bag_outlined,
                  AdminRoutes.orders),
              _buildNavItem(context, 'Active Carts',
                  Icons.shopping_cart_checkout, AdminRoutes.carts),
              _buildNavItem(
                  context, 'Users', Icons.people_outline, AdminRoutes.users),
              _buildNavItem(context, 'Feedback', Icons.feedback_outlined,
                  AdminRoutes.feedback),
              const Divider(color: AppColors.divider, height: 32),
              _buildNavItem(context, 'Settings', Icons.settings_outlined,
                  AdminRoutes.settings),
            ],
          ),
        ),

        // User Profile / Logout
        Container(
          padding: const EdgeInsets.all(16),
          child:
              _buildNavItem(context, 'Logout', Icons.logout, AdminRoutes.login),
        ),
      ],
    );
  }

  Widget _buildNavItem(
      BuildContext context, String title, IconData icon, String route) {
    // Simple verification (in a real app, use GoRouter state)
    final isActive = ModalRoute.of(context)?.settings.name == route;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppColors.primaryGold : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: isActive
              ? AppTextStyles.titleSmall.copyWith(color: AppColors.primaryGold)
              : AppTextStyles.bodyMedium,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isActive
            ? AppColors.primaryGold.withOpacity(0.1)
            : Colors.transparent,
        onTap: () {
          if (route == AdminRoutes.login) {
            // Handle logout
            Navigator.pushReplacementNamed(context, AdminRoutes.login);
          } else {
            // Use pushReplacementNamed to simulate "tab switching" behavior for sidebar items
            // But for sub-pages not in sidebar, we might want pushNamed.
            // For now, consistent sidebar behavior:
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }
}
