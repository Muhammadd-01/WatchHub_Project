// =============================================================================
// FILE: active_carts_screen.dart
// PURPOSE: View Active Carts
// DESCRIPTION: Lists users who have items in their cart.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/admin_scaffold.dart';
import '../../providers/admin_cart_provider.dart';

class ActiveCartsScreen extends StatefulWidget {
  const ActiveCartsScreen({super.key});

  @override
  State<ActiveCartsScreen> createState() => _ActiveCartsScreenState();
}

class _ActiveCartsScreenState extends State<ActiveCartsScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedUids = {};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCartProvider>().fetchActiveCarts();
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedUids.clear();
    });
  }

  void _toggleSelection(String uid) {
    setState(() {
      if (_selectedUids.contains(uid)) {
        _selectedUids.remove(uid);
      } else {
        _selectedUids.add(uid);
      }
      if (_selectedUids.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _selectAll(List<Map<String, dynamic>> carts) {
    setState(() {
      if (_selectedUids.length == carts.length) {
        _selectedUids.clear();
        _isSelectionMode = false;
      } else {
        _selectedUids.clear();
        for (var cart in carts) {
          _selectedUids.add(cart['uid']);
        }
      }
    });
  }

  Future<void> _clearSelected() async {
    if (_selectedUids.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Clear Selected Carts',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
            'Are you sure you want to clear ${_selectedUids.length} carts? This will remove all items from these users\' shopping carts.',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear Carts'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = context.read<AdminCartProvider>();
      int successCount = 0;
      for (final uid in _selectedUids.toList()) {
        final success = await provider.clearUserCart(uid);
        if (success) successCount++;
      }
      setState(() {
        _selectedUids.clear();
        _isSelectionMode = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cleared $successCount cart(s)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: _isSelectionMode
          ? '${_selectedUids.length} Selected'
          : 'Active Carts',
      actions: [
        if (_isSelectionMode) ...[
          Consumer<AdminCartProvider>(
            builder: (context, provider, _) => IconButton(
              onPressed: () => _selectAll(provider.activeCarts),
              icon: Icon(
                _selectedUids.length == provider.activeCarts.length
                    ? Icons.deselect
                    : Icons.select_all,
                size: 22,
              ),
              tooltip: _selectedUids.length == provider.activeCarts.length
                  ? 'Deselect All'
                  : 'Select All',
              color: AppColors.primaryGold,
            ),
          ),
          IconButton(
            onPressed: _selectedUids.isEmpty ? null : _clearSelected,
            icon: const Icon(Icons.delete_sweep, size: 22),
            tooltip: 'Clear Selected Carts',
            color: _selectedUids.isEmpty
                ? AppColors.textSecondary
                : AppColors.error,
          ),
          IconButton(
            onPressed: _toggleSelectionMode,
            icon: const Icon(Icons.close, size: 22),
            tooltip: 'Cancel',
            color: AppColors.error,
          ),
        ] else ...[
          IconButton(
            onPressed: _toggleSelectionMode,
            icon: const Icon(Icons.checklist, size: 20),
            tooltip: 'Select Multiple',
            color: AppColors.textPrimary,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryGold),
            onPressed: () =>
                context.read<AdminCartProvider>().fetchActiveCarts(),
          ),
        ],
        const SizedBox(width: 16),
      ],
      body: Consumer<AdminCartProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading)
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold));

          if (provider.activeCarts.isEmpty) {
            return const Center(child: Text('No active carts found.'));
          }

          return ListView.separated(
            itemCount: provider.activeCarts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final cart = provider.activeCarts[index];
              final items = cart['items'] as List<Map<String, dynamic>>;
              final isSelected = _selectedUids.contains(cart['uid']);

              return GestureDetector(
                onLongPress: () {
                  if (!_isSelectionMode) {
                    _toggleSelectionMode();
                    _toggleSelection(cart['uid']);
                  }
                },
                onTap: _isSelectionMode
                    ? () => _toggleSelection(cart['uid'])
                    : null,
                child: Card(
                  color: isSelected
                      ? AppColors.primaryGold.withOpacity(0.1)
                      : AppColors.cardBackground,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryGold
                            : Colors.transparent,
                        width: isSelected ? 2 : 0),
                  ),
                  child: Row(
                    children: [
                      if (_isSelectionMode)
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggleSelection(cart['uid']),
                            activeColor: AppColors.primaryGold,
                          ),
                        ),
                      Expanded(
                        child: ExpansionTile(
                          collapsedIconColor: AppColors.primaryGold,
                          iconColor: AppColors.primaryGold,
                          title: Text(
                            '${cart['userName']} (${cart['userEmail']})',
                            style: AppTextStyles.titleMedium
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${cart['itemCount']} items in cart',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.textSecondary)),
                          trailing: !_isSelectionMode
                              ? IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor:
                                            AppColors.cardBackground,
                                        title: const Text('Clear Cart'),
                                        content: const Text(
                                            'Clear this user\'s cart?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel')),
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Clear',
                                                  style: TextStyle(
                                                      color: AppColors.error))),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await provider.clearUserCart(cart['uid']);
                                    }
                                  },
                                )
                              : null,
                          children: items.map((item) {
                            return ListTile(
                              leading: const Icon(Icons.shopping_cart_outlined,
                                  color: AppColors.textSecondary),
                              title: Text(item['productName']),
                              subtitle: Text('Qty: ${item['quantity']}'),
                              trailing: Text('\$${item['price']}',
                                  style: AppTextStyles.bodyMedium),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
