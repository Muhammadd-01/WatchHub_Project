// =============================================================================
// FILE: order_details_screen.dart
// PURPOSE: Order details screen for WatchHub
// DESCRIPTION: Shows detailed order information with cancel option.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isCancelling = false;

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

  Future<void> _cancelOrder() async {
    if (_order == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Cancel Order',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Keep Order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, Cancel Order'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isCancelling = true);

    try {
      // Update order status to cancelled
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      // Restore product stock for each item
      for (final item in _order!.items) {
        final productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(item.productId)
            .get();

        if (productDoc.exists) {
          final currentStock = productDoc.data()?['stock'] ?? 0;
          await FirebaseFirestore.instance
              .collection('products')
              .doc(item.productId)
              .update({
            'stock': currentStock + item.quantity,
          });
        }
      }

      // Send notification to admin panel
      await FirebaseFirestore.instance.collection('admin_notifications').add({
        'type': 'order_cancelled',
        'title': 'Order Cancelled: ${_order!.orderNumber}',
        'message': 'A user cancelled their order',
        'orderId': widget.orderId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Reload order to reflect new status
      await _loadOrder();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order cancelled successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel order: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  bool get _canCancel {
    if (_order == null) return false;
    final status = _order!.status.toLowerCase();
    return status == 'pending' || status == 'processing';
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

          // Cancel order button (only for pending/processing orders)
          if (_canCancel) ...[
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isCancelling ? null : _cancelOrder,
                icon: _isCancelling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.error,
                        ),
                      )
                    : const Icon(Icons.cancel_outlined),
                label: Text(_isCancelling ? 'Cancelling...' : 'Cancel Order'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],

          // Cancelled message
          if (_order!.status.toLowerCase() == 'cancelled') ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel, color: AppColors.error),
                  SizedBox(width: 8),
                  Text(
                    'This order has been cancelled',
                    style: TextStyle(
                        color: AppColors.error, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
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
