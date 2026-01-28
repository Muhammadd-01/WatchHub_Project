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
  bool _isSelectionMode = false;
  final Set<String> _selectedOrderIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOrderProvider>().fetchOrders();
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedOrderIds.clear();
    });
  }

  void _toggleOrderSelection(String id) {
    setState(() {
      if (_selectedOrderIds.contains(id)) {
        _selectedOrderIds.remove(id);
      } else {
        _selectedOrderIds.add(id);
      }
    });
  }

  void _selectAll(List<Map<String, dynamic>> orders) {
    setState(() {
      if (_selectedOrderIds.length == orders.length) {
        _selectedOrderIds.clear();
      } else {
        _selectedOrderIds.clear();
        for (var order in orders) {
          _selectedOrderIds.add(order['id'] as String);
        }
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedOrderIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Delete ${_selectedOrderIds.length} order(s)?',
            style: AppTextStyles.titleMedium),
        content: Text(
          'This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final provider = context.read<AdminOrderProvider>();
      for (final id in _selectedOrderIds) {
        await provider.deleteOrder(id);
      }
      setState(() {
        _isSelectionMode = false;
        _selectedOrderIds.clear();
      });
      if (mounted) {
        AdminHelpers.showSuccessSnackbar(context, 'Orders deleted');
      }
    }
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
        // Selection mode toggle
        IconButton(
          icon: Icon(
            _isSelectionMode ? Icons.close : Icons.checklist,
            color: _isSelectionMode ? AppColors.error : AppColors.textPrimary,
            size: 20,
          ),
          tooltip: _isSelectionMode ? 'Cancel Selection' : 'Select Multiple',
          onPressed: _toggleSelectionMode,
        ),
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

          return Column(
            children: [
              // Selection action bar
              if (_isSelectionMode)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: AppColors.surfaceColor,
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _selectAll(provider.orders),
                        icon: Icon(
                          _selectedOrderIds.length == provider.orders.length
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 20,
                        ),
                        label: Text(
                          _selectedOrderIds.length == provider.orders.length
                              ? 'Deselect All'
                              : 'Select All',
                        ),
                      ),
                      const Spacer(),
                      if (_selectedOrderIds.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: _deleteSelected,
                          icon: const Icon(Icons.delete, size: 18),
                          label: Text('Delete (${_selectedOrderIds.length})'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              // Content
              Expanded(
                child: isMobile
                    ? ListView.builder(
                        itemCount: provider.orders.length,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemBuilder: (context, index) {
                          final order = provider.orders[index];
                          final orderId = order['id'] as String;
                          final date = order['createdAt'] != null
                              ? (order['createdAt'] as Timestamp).toDate()
                              : DateTime.now();
                          final currentStatus =
                              _normalizeStatus(order['status'] as String?);
                          final items = (order['items'] as List?)?.length ?? 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: _isSelectionMode &&
                                    _selectedOrderIds.contains(orderId)
                                ? AppColors.primaryGold.withOpacity(0.1)
                                : AppColors.cardBackground,
                            child: InkWell(
                              onTap: _isSelectionMode
                                  ? () => _toggleOrderSelection(orderId)
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Checkbox for selection mode
                                    if (_isSelectionMode)
                                      Checkbox(
                                        value:
                                            _selectedOrderIds.contains(orderId),
                                        onChanged: (_) =>
                                            _toggleOrderSelection(orderId),
                                        activeColor: AppColors.primaryGold,
                                      ),
                                    // Order details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '#${orderId.substring(0, 6)}',
                                                style: AppTextStyles.titleSmall,
                                              ),
                                              Text(
                                                DateFormat('MMM dd, yyyy')
                                                    .format(date),
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  order['userId'] ?? 'Guest',
                                                  style:
                                                      AppTextStyles.bodyMedium,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                '$items items',
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '\$${(order['totalAmount'] ?? 0).toStringAsFixed(2)}',
                                                style: AppTextStyles.titleMedium
                                                    .copyWith(
                                                  color: AppColors.primaryGold,
                                                ),
                                              ),
                                              _buildStatusBadge(currentStatus),
                                            ],
                                          ),
                                          if (!_isSelectionMode &&
                                              currentStatus != 'completed' &&
                                              currentStatus != 'cancelled') ...[
                                            const SizedBox(height: 12),
                                            const Divider(
                                                color: AppColors.divider),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('Update Status:',
                                                    style: AppTextStyles
                                                        .bodySmall),
                                                _buildStatusDropdown(
                                                    order, currentStatus),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Theme(
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
                          columns: [
                            if (_isSelectionMode)
                              const DataColumn2(
                                  label: Text(''), fixedWidth: 50),
                            const DataColumn2(
                                label: Text('Order ID'), fixedWidth: 100),
                            const DataColumn2(
                                label: Text('Date'), size: ColumnSize.S),
                            const DataColumn2(
                                label: Text('Customer'), size: ColumnSize.M),
                            const DataColumn2(
                                label: Text('Total'), size: ColumnSize.S),
                            const DataColumn2(
                                label: Text('Status'), size: ColumnSize.S),
                            const DataColumn2(
                                label: Text('Items'), size: ColumnSize.S),
                            const DataColumn2(
                                label: Text('Actions'), fixedWidth: 150),
                          ],
                          rows: provider.orders.map((order) {
                            final orderId = order['id'] as String;
                            final date = order['createdAt'] != null
                                ? (order['createdAt'] as Timestamp).toDate()
                                : DateTime.now();
                            final currentStatus =
                                _normalizeStatus(order['status'] as String?);

                            return DataRow(
                              selected: _selectedOrderIds.contains(orderId),
                              color: _selectedOrderIds.contains(orderId)
                                  ? WidgetStatePropertyAll(
                                      AppColors.primaryGold.withOpacity(0.1))
                                  : null,
                              cells: [
                                if (_isSelectionMode)
                                  DataCell(
                                    Checkbox(
                                      value:
                                          _selectedOrderIds.contains(orderId),
                                      onChanged: (_) =>
                                          _toggleOrderSelection(orderId),
                                      activeColor: AppColors.primaryGold,
                                    ),
                                  ),
                                DataCell(Text('#${orderId.substring(0, 6)}',
                                    style: AppTextStyles.bodyMedium)),
                                DataCell(Text(
                                    DateFormat('MM/dd/yy').format(date),
                                    style: AppTextStyles.bodyMedium)),
                                DataCell(Text(order['userId'] ?? 'Guest',
                                    style: AppTextStyles.bodyMedium)),
                                DataCell(Text(
                                    '\$${(order['totalAmount'] ?? 0).toStringAsFixed(2)}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primaryGold))),
                                DataCell(_buildStatusBadge(currentStatus)),
                                DataCell(Text(
                                    '${(order['items'] as List?)?.length ?? 0} items',
                                    style: AppTextStyles.bodyMedium)),
                                DataCell(
                                    _buildStatusDropdown(order, currentStatus)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
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
