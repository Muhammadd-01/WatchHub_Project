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
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard(context, 'Total Revenue', '\$124,500',
                    Icons.attach_money, AppColors.success),
                _buildStatCard(context, 'Total Orders', '1,254',
                    Icons.shopping_bag, AppColors.info),
                _buildStatCard(context, 'Active Users', '3,450', Icons.people,
                    AppColors.warning),
                _buildStatCard(context, 'Products', '45', Icons.inventory,
                    AppColors.primaryGold),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Activity Section
            Text('Recent Orders', style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            Container(
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
              child: Column(
                children: [
                  _buildOrderListItem('ORD-001', 'John Doe', '\$250.00',
                      'Delivered', AppColors.success),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildOrderListItem('ORD-002', 'Jane Smith', '\$120.50',
                      'Processing', AppColors.info),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildOrderListItem('ORD-003', 'Mike Johnson', '\$450.00',
                      'Pending', AppColors.warning),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildOrderListItem('ORD-004', 'Emily Davis', '\$89.99',
                      'Cancelled', AppColors.error),

                  // improved "View All" button
                  InkWell(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/orders'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      child: Text('View All Orders',
                          style: AppTextStyles.labelLarge
                              .copyWith(color: AppColors.primaryGold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final width = MediaQuery.of(context).size.width;
    // Responsive width logic for cards
    double cardWidth = (width > 1200)
        ? (width - 300 - 48) / 4
        : (width > 600)
            ? (width - 48) / 2
            : width - 48;
    // Constrain max width for cleaner look on huge screens
    if (cardWidth > 300) cardWidth = 300;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground,
            AppColors.cardBackground.withOpacity(0.8), // subtle gradient
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            offset: const Offset(0, 8),
            blurRadius: 16,
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
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(value,
                    style: AppTextStyles.headlineMedium
                        .copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderListItem(String orderId, String customer, String amount,
      String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.receipt_long, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(orderId,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(customer,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.bold)),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(status,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: statusColor, fontSize: 10)),
              )
            ],
          )
        ],
      ),
    );
  }
}
