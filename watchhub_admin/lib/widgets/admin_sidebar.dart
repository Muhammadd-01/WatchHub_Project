// =============================================================================
// FILE: admin_sidebar.dart
// PURPOSE: Sidebar Navigation Widget
// DESCRIPTION: Displays navigation items and handles selection.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../providers/admin_notification_provider.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isCollapsed;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              Align(
                alignment:
                    isCollapsed ? Alignment.center : Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/watchhub_logo.png',
                  width: isCollapsed ? 40 : 48,
                  height: isCollapsed ? 40 : 48,
                  fit: BoxFit.contain,
                ),
              ),
              if (!isCollapsed)
                Positioned(
                  left: 60,
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'WatchHub',
                      style: AppTextStyles.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
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
              _buildNavItem(
                  context, 'Brands', Icons.branding_watermark_outlined, 3),
              _buildNavItem(context, 'Orders', Icons.shopping_bag_outlined, 4),
              _buildNavItem(
                  context, 'Active Carts', Icons.shopping_cart_checkout, 5),
              _buildNavItem(context, 'Users', Icons.people_outline, 6),
              _buildNavItem(context, 'Reviews', Icons.rate_review_outlined, 7),
              _buildNavItem(context, 'Feedback', Icons.feedback_outlined, 8),
              _buildNavItem(context, 'Wishlists', Icons.favorite_outline, 9),
              _buildNavItem(
                  context, 'Notifications', Icons.notifications_outlined, 10),
              _buildNavItem(
                  context, 'FAQs', Icons.question_answer_outlined, 11),
              const Divider(color: AppColors.divider, height: 32),
              _buildNavItem(
                  context, 'Profile', Icons.account_circle_outlined, 12),
              _buildNavItem(context, 'Settings', Icons.settings_outlined, 13),
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
      child: Tooltip(
        message: isCollapsed ? title : '',
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGold.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                // Icon
                Align(
                  alignment:
                      isCollapsed ? Alignment.center : Alignment.centerLeft,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        icon,
                        color: isSelected
                            ? AppColors.primaryGold
                            : AppColors.textSecondary,
                        size: 24,
                      ),
                      if (title == 'Notifications')
                        Consumer<AdminNotificationProvider>(
                          builder: (context, notificationProv, _) {
                            final count = notificationProv.unreadCount;
                            if (count == 0) return const SizedBox.shrink();
                            return Positioned(
                              right: -6,
                              top: -6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                // Text
                if (!isCollapsed)
                  Positioned(
                    left: 36,
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: isSelected
                            ? AppTextStyles.titleSmall
                                .copyWith(color: AppColors.primaryGold)
                            : AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
