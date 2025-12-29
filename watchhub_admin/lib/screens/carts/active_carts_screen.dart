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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCartProvider>().fetchActiveCarts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Active Carts',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.primaryGold),
          onPressed: () => context.read<AdminCartProvider>().fetchActiveCarts(),
        ),
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

              return Card(
                color: AppColors.cardBackground,
                elevation: 2,
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
              );
            },
          );
        },
      ),
    );
  }
}
