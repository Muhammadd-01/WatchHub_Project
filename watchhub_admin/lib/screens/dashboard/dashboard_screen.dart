// =============================================================================
// FILE: dashboard_screen.dart
// PURPOSE: Main dashboard view
// DESCRIPTION: Displays key metrics and recent activity.
// =============================================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/admin_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Dashboard',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Row
            Row(
              children: [
                Expanded(
                    child: _buildStatCard('Total Revenue', '\$124,500',
                        Icons.attach_money, AppColors.success)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildStatCard('Total Orders', '1,254',
                        Icons.shopping_bag, AppColors.info)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildStatCard('Active Users', '3,450', Icons.people,
                        AppColors.warning)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildStatCard('Products', '45', Icons.inventory,
                        AppColors.primaryGold)),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Activity Section (Placeholder)
            Text('Recent Orders', style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              alignment: Alignment.center,
              child: Text('Recent orders table will appear here',
                  style: AppTextStyles.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodySmall),
              const SizedBox(height: 4),
              Text(value, style: AppTextStyles.headlineMedium),
            ],
          ),
        ],
      ),
    );
  }
}
