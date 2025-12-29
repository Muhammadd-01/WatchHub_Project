// =============================================================================
// FILE: order_details_screen.dart
// PURPOSE: Order details screen for WatchHub
// DESCRIPTION: Shows detailed order information.
// =============================================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/helpers.dart';
import '../../services/firestore_crud_service.dart';
import '../../models/order_model.dart';
import '../../widgets/common/glass_container.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final FirestoreCrudService _firestoreService = FirestoreCrudService();
  OrderModel? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);

    try {
      _order = await _firestoreService.getOrder(widget.orderId);
    } catch (e) {
      debugPrint('Error loading order: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        title: Text('Order Details', style: AppTextStyles.appBarTitle),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGold,
                ),
              ),
            )
          : _order == null
          ? _buildNotFound()
          : _buildOrderDetails(),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('Order not found', style: AppTextStyles.titleLarge),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_order!.orderNumber, style: AppTextStyles.titleLarge),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Helpers.getStatusColor(
                          _order!.status,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _order!.status.toUpperCase(),
                        style: TextStyle(
                          color: Helpers.getStatusColor(_order!.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Placed on ${Helpers.formatDate(_order!.createdAt)}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Items
          Text('Items', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          ..._order!.items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product?.name ?? 'Product',
                          style: AppTextStyles.titleSmall,
                        ),
                        Text(
                          'Qty: ${item.quantity}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    Helpers.formatCurrency(item.subtotal),
                    style: AppTextStyles.priceSmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Shipping address
          if (_order!.shippingAddress != null) ...[
            Text('Shipping Address', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _order!.shippingAddress!.fullName,
                    style: AppTextStyles.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _order!.shippingAddress!.formatted,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Order summary
          Text('Order Summary', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryRow('Subtotal', _order!.subtotal),
                _buildSummaryRow('Shipping', _order!.shippingCost),
                _buildSummaryRow('Tax', _order!.taxAmount),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: AppTextStyles.titleMedium),
                    Text(
                      Helpers.formatCurrency(_order!.total),
                      style: AppTextStyles.priceLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(Helpers.formatCurrency(amount), style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
