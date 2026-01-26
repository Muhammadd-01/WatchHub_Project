// =============================================================================
// FILE: admin_sidebar.dart
// PURPOSE: Sidebar Navigation Widget
// DESCRIPTION: Displays navigation items and handles selection.
// =============================================================================

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
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
              _buildNavItem(context, 'Dashboard', Icons.dashboard_outlined, 0),
              _buildNavItem(context, 'Products', Icons.inventory_2_outlined, 1),
              _buildNavItem(context, 'Categories', Icons.category_outlined, 2),
              _buildNavItem(context, 'Orders', Icons.shopping_bag_outlined, 3),
              _buildNavItem(
                  context, 'Active Carts', Icons.shopping_cart_checkout, 4),
              _buildNavItem(context, 'Users', Icons.people_outline, 5),
              _buildNavItem(context, 'Reviews', Icons.rate_review_outlined, 6),
              _buildNavItem(context, 'Feedback', Icons.feedback_outlined, 7),
              const Divider(color: AppColors.divider, height: 32),
              _buildNavItem(
                  context, 'Profile', Icons.account_circle_outlined, 8),
              _buildNavItem(context, 'Settings', Icons.settings_outlined, 9),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
      BuildContext context, String title, IconData icon, int index) {
    final bool isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primaryGold : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: isSelected
              ? AppTextStyles.titleSmall.copyWith(color: AppColors.primaryGold)
              : AppTextStyles.bodyMedium,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isSelected
            ? AppColors.primaryGold.withOpacity(0.1)
            : Colors.transparent,
        onTap: () => onItemSelected(index),
      ),
    );
  }
}
