// =============================================================================
// FILE: orders_list_screen.dart
// PURPOSE: List all orders
// DESCRIPTION: Displays orders in a sortable data table.
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

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Orders',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.primaryGold),
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

          return Theme(
            data: Theme.of(context).copyWith(
              cardColor: AppColors.cardBackground,
              dividerColor: AppColors.divider,
            ),
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 900,
              headingRowColor: WidgetStateColor.resolveWith(
                  (states) => AppColors.surfaceColor),
              columns: const [
                DataColumn2(label: Text('Order ID'), fixedWidth: 100),
                DataColumn2(label: Text('Date'), size: ColumnSize.S),
                DataColumn2(label: Text('Customer'), size: ColumnSize.M),
                DataColumn2(label: Text('Total'), size: ColumnSize.S),
                DataColumn2(label: Text('Status'), size: ColumnSize.S),
                DataColumn2(label: Text('Items'), size: ColumnSize.S),
                DataColumn2(label: Text('Actions'), fixedWidth: 100),
              ],
              rows: provider.orders.map((order) {
                final date = order['createdAt'] != null
                    ? (order['createdAt'] as Timestamp).toDate()
                    : DateTime.now();

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
                    DataCell(_buildStatusBadge(order['status'] ?? 'pending')),
                    DataCell(Text(
                        '${(order['items'] as List?)?.length ?? 0} items',
                        style: AppTextStyles.bodyMedium)),
                    DataCell(
                      (order['status'] ?? 'pending') == 'pending'
                          ? DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: null,
                                isDense: true,
                                hint: const Text('Action',
                                    style: TextStyle(fontSize: 12)),
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: AppColors.primaryGold, size: 20),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'approved',
                                    child: Text('Approve',
                                        style: TextStyle(
                                            color: AppColors.success,
                                            fontSize: 13)),
                                  ),
                                  DropdownMenuItem(
                                    value: 'cancelled',
                                    child: Text('Decline',
                                        style: TextStyle(
                                            color: AppColors.error,
                                            fontSize: 13)),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    _confirmUpdateStatus(context, order, val);
                                  }
                                },
                              ),
                            )
                          : _buildStatusText(order['status'] ?? 'pending'),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        color = AppColors.success;
        break;
      case 'processing':
      case 'shipped':
        color = AppColors.info;
        break;
      case 'cancelled':
        color = AppColors.error;
        break;
      default:
        color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }

  void _confirmUpdateStatus(
      BuildContext context, Map<String, dynamic> order, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('${newStatus.toUpperCase()} Order?',
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(
            'Are you sure you want to mark order #${order['id'].toString().substring(0, 6)} as $newStatus?',
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
                  AdminHelpers.showSuccessSnackbar(
                      context, 'Order marked as $newStatus');
                }
              } catch (e) {
                if (context.mounted) {
                  AdminHelpers.showErrorSnackbar(
                      context, 'Failed to update status');
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: newStatus == 'cancelled'
                  ? AppColors.error
                  : AppColors.success,
            ),
            child: Text(newStatus == 'cancelled' ? 'Decline' : 'Approve'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
      case 'delivered':
        color = AppColors.success;
        label = 'Approved';
        break;
      case 'cancelled':
        color = AppColors.error;
        label = 'Declined';
        break;
      default:
        color = AppColors.textSecondary;
        label = status.toUpperCase();
    }
    return Text(
      label,
      style: AppTextStyles.bodyMedium
          .copyWith(color: color, fontWeight: FontWeight.bold),
    );
  }
}
