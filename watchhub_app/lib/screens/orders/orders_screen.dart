// =============================================================================
// FILE: orders_screen.dart
// PURPOSE: Orders list screen for WatchHub
// DESCRIPTION: Displays user's order history.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_crud_service.dart';
import '../../models/order_model.dart';
import '../../widgets/common/glass_container.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirestoreCrudService _firestoreService = FirestoreCrudService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      _orders = await _firestoreService.getOrders(authProvider.uid!);
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        title: Text('My Orders', style: AppTextStyles.appBarTitle),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGold,
                ),
              ),
            )
          : _orders.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              color: AppColors.primaryGold,
              onRefresh: _loadOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  return _OrderCard(
                    order: _orders[index],
                  ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 24),
          Text('No orders yet', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          Text('Your orders will appear here', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.orderDetails,
          arguments: order.id,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order.orderNumber, style: AppTextStyles.titleSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Helpers.getStatusColor(
                        order.status,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        color: Helpers.getStatusColor(order.status),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Date', style: AppTextStyles.bodySmall),
                      Text(
                        Helpers.formatDate(order.createdAt),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Items', style: AppTextStyles.bodySmall),
                      Text(
                        '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: AppTextStyles.bodySmall),
                      Text(
                        Helpers.formatCurrency(order.total),
                        style: AppTextStyles.priceSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
