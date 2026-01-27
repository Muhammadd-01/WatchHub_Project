// =============================================================================
// FILE: orders_list_screen.dart
// PURPOSE: List all orders with full status management
// DESCRIPTION: Displays orders in a sortable data table with status actions.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/admin_helpers.dart';
import '../../widgets/admin_scaffold.dart';
import '../../providers/admin_order_provider.dart';
import '../../widgets/animated_reload_button.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOrderProvider>().fetchOrders();
    });
  }

  // All possible order statuses (including legacy 'approved' for backwards compatibility)
  static const List<String> _allStatuses = [
    'pending',
    'approved',
    'processing',
    'shipped',
    'completed',
    'cancelled',
  ];

  // Normalize status to ensure it exists in the list
  String _normalizeStatus(String? status) {
    final s = status?.toLowerCase() ?? 'pending';
    if (_allStatuses.contains(s)) return s;
    // Map old statuses to new ones
    if (s == 'delivered') return 'completed';
    return 'pending'; // Default fallback
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Orders',
      actions: [
        AnimatedReloadButton(
          onPressed: () {
            context.read<AdminOrderProvider>().fetchOrders();
          },
        ),
      ],
      body: Consumer<AdminOrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold));
          }
          if (provider.errorMessage != null) {
            return Center(
                child: Text(provider.errorMessage!,
                    style: const TextStyle(color: AppColors.error)));
          }
          if (provider.orders.isEmpty) {
            return Center(
                child:
                    Text('No orders found', style: AppTextStyles.titleMedium));
          }

          // Responsive layout - cards for mobile, data table for desktop
          final isMobile = MediaQuery.of(context).size.width < 600;

          if (isMobile) {
            // Mobile card layout
            return ListView.builder(
              itemCount: provider.orders.length,
              padding: const EdgeInsets.only(bottom: 16),
              itemBuilder: (context, index) {
                final order = provider.orders[index];
                final date = order['createdAt'] != null
                    ? (order['createdAt'] as Timestamp).toDate()
                    : DateTime.now();
                final currentStatus =
                    _normalizeStatus(order['status'] as String?);
                final items = (order['items'] as List?)?.length ?? 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: AppColors.cardBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order ID and Date row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '#${order['id'].toString().substring(0, 6)}',
                              style: AppTextStyles.titleSmall,
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy').format(date),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Customer and Items
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                order['userId'] ?? 'Guest',
                                style: AppTextStyles.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '$items items',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Total and Status row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${(order['totalAmount'] ?? 0).toStringAsFixed(2)}',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.primaryGold,
                              ),
                            ),
                            _buildStatusBadge(currentStatus),
                          ],
                        ),
                        if (currentStatus != 'completed' &&
                            currentStatus != 'cancelled') ...[
                          const SizedBox(height: 12),
                          const Divider(color: AppColors.divider),
                          // Status dropdown
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Update Status:',
                                  style: AppTextStyles.bodySmall),
                              _buildStatusDropdown(order, currentStatus),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }

          // Desktop data table
          return Theme(
            data: Theme.of(context).copyWith(
              cardColor: AppColors.cardBackground,
              dividerColor: AppColors.divider,
            ),
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 1000,
              headingRowColor: WidgetStateColor.resolveWith(
                  (states) => AppColors.surfaceColor),
              columns: const [
                DataColumn2(label: Text('Order ID'), fixedWidth: 100),
                DataColumn2(label: Text('Date'), size: ColumnSize.S),
                DataColumn2(label: Text('Customer'), size: ColumnSize.M),
                DataColumn2(label: Text('Total'), size: ColumnSize.S),
                DataColumn2(label: Text('Status'), size: ColumnSize.S),
                DataColumn2(label: Text('Items'), size: ColumnSize.S),
                DataColumn2(label: Text('Actions'), fixedWidth: 150),
              ],
              rows: provider.orders.map((order) {
                final date = order['createdAt'] != null
                    ? (order['createdAt'] as Timestamp).toDate()
                    : DateTime.now();
                final currentStatus =
                    _normalizeStatus(order['status'] as String?);

                return DataRow(
                  cells: [
                    DataCell(Text('#${order['id'].toString().substring(0, 6)}',
                        style: AppTextStyles.bodyMedium)),
                    DataCell(Text(DateFormat('MM/dd/yy').format(date),
                        style: AppTextStyles.bodyMedium)),
                    DataCell(Text(order['userId'] ?? 'Guest',
                        style: AppTextStyles.bodyMedium)),
                    DataCell(Text(
                        '\$${(order['totalAmount'] ?? 0).toStringAsFixed(2)}',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.primaryGold))),
                    DataCell(_buildStatusBadge(currentStatus)),
                    DataCell(Text(
                        '${(order['items'] as List?)?.length ?? 0} items',
                        style: AppTextStyles.bodyMedium)),
                    DataCell(_buildStatusDropdown(order, currentStatus)),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusDropdown(
      Map<String, dynamic> order, String currentStatus) {
    // Don't allow changes for completed or cancelled orders
    if (currentStatus == 'completed' || currentStatus == 'cancelled') {
      return _buildFinalStatusText(currentStatus);
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: currentStatus,
        isDense: true,
        icon: const Icon(Icons.arrow_drop_down,
            color: AppColors.primaryGold, size: 20),
        items: _allStatuses.map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(
              _getStatusLabel(status),
              style: TextStyle(
                color: _getStatusColor(status),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        onChanged: (newStatus) {
          if (newStatus != null && newStatus != currentStatus) {
            _confirmUpdateStatus(context, order, newStatus);
          }
        },
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return AppColors.info;
      case 'cancelled':
        return AppColors.error;
      case 'pending':
      default:
        return AppColors.warning;
    }
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getStatusLabel(status).toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }

  Widget _buildFinalStatusText(String status) {
    final color = _getStatusColor(status);
    return Text(
      _getStatusLabel(status),
      style: AppTextStyles.bodyMedium.copyWith(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _confirmUpdateStatus(
      BuildContext context, Map<String, dynamic> order, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Update Order Status?',
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(
            'Change order #${order['id'].toString().substring(0, 6)} status to "${_getStatusLabel(newStatus)}"?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<AdminOrderProvider>().updateOrderStatus(
                    order['id'], newStatus,
                    userId: order['userId']);
                if (context.mounted) {
                  AdminHelpers.showSuccessSnackbar(context,
                      'Order status updated to ${_getStatusLabel(newStatus)}');
                }
              } catch (e) {
                if (context.mounted) {
                  AdminHelpers.showErrorSnackbar(
                      context, 'Failed to update status');
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: _getStatusColor(newStatus),
            ),
            child: Text('Update to ${_getStatusLabel(newStatus)}'),
          ),
        ],
      ),
    );
  }
}
