// =============================================================================
// FILE: dashboard_screen.dart
// PURPOSE: Main dashboard view
// DESCRIPTION: Displays key metrics and recent activity.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/admin_scaffold.dart';
import '../../providers/admin_dashboard_provider.dart';
import '../../providers/admin_navigation_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Dashboard',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh Stats',
          onPressed: () {
            context.read<AdminDashboardProvider>().fetchStats();
          },
        ),
      ],
      body: Consumer<AdminDashboardProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.isLoading)
                  const LinearProgressIndicator(
                    color: AppColors.primaryGold,
                    backgroundColor: AppColors.surfaceColor,
                  ),
                const SizedBox(height: 16),

                // Stats Row
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildStatCard(
                        context,
                        'Total Revenue',
                        '\$${provider.totalRevenue.toStringAsFixed(2)}',
                        Icons.attach_money,
                        AppColors.success),
                    _buildStatCard(
                        context,
                        'Total Orders',
                        '${provider.orderCount}',
                        Icons.shopping_bag,
                        AppColors.info),
                    _buildStatCard(
                        context,
                        'Active Users',
                        '${provider.userCount}',
                        Icons.people,
                        AppColors.warning),
                    _buildStatCard(
                        context,
                        'Products',
                        '${provider.productCount}',
                        Icons.inventory,
                        AppColors.primaryGold),
                  ],
                ),
                const SizedBox(height: 32),

                // Recent Activity Section (Placeholder logic for now, or could fetch recent orders similarly)
                Text('Recent Orders', style: AppTextStyles.titleLarge),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
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
                      // Placeholder items - in a real app, bind this to AdminOrderProvider.orders.take(5)
                      _buildOrderListItem(context, 'ORD-001', 'John Doe',
                          '\$250.00', 'Delivered', AppColors.success),
                      const Divider(height: 1),
                      _buildOrderListItem(context, 'ORD-002', 'Jane Smith',
                          '\$120.50', 'Processing', AppColors.info),
                      const Divider(height: 1),
                      _buildOrderListItem(context, 'ORD-003', 'Mike Johnson',
                          '\$450.00', 'Pending', AppColors.warning),

                      // improved "View All" button
                      InkWell(
                        onTap: () {
                          // Switch to Orders Tab (Index 3)
                          // Assuming Orders is at index 3.
                          context.read<AdminNavigationProvider>().setIndex(3);
                        },
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
          );
        },
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

    // Use Theme colors for background to support light mode
    final cardColor = Theme.of(context).cardColor;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        // Simple subtle shadow or gradient
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color)),
                const SizedBox(height: 4),
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderListItem(BuildContext context, String orderId,
      String customer, String amount, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).hoverColor, // Surface color substitute
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt_long,
                color: Theme.of(context).iconTheme.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(orderId,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(customer, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
