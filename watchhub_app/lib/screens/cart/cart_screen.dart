// =============================================================================
// FILE: cart_screen.dart
// PURPOSE: Shopping cart screen for WatchHub
// DESCRIPTION: Displays cart items with quantity controls and checkout.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/cart_model.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/loading_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        title: Text('My Cart', style: AppTextStyles.appBarTitle),
        automaticallyImplyLeading: false,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              if (cartProvider.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _showClearCartDialog(context),
                child: Text(
                  'Clear All',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer2<CartProvider, AuthProvider>(
        builder: (context, cartProvider, authProvider, _) {
          if (!authProvider.isAuthenticated) {
            return _buildLoginPrompt(context);
          }

          if (cartProvider.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return _CartItemCard(item: item, uid: authProvider.uid!)
                        .animate()
                        .fadeIn(delay: (50 * index).ms)
                        .slideX(begin: 0.1);
                  },
                ),
              ),
              _buildOrderSummary(context, cartProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 24),
            Text('Sign in to view cart', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Your cart items will be saved across devices',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            LoadingButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              text: 'Sign In',
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 24),
            Text('Your cart is empty', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Start adding luxury timepieces to your collection',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            LoadingButton(onPressed: () {}, text: 'Browse Watches', width: 200),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary rows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: AppTextStyles.bodyMedium),
                Text(
                  Helpers.formatCurrency(cartProvider.totalPrice),
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shipping', style: AppTextStyles.bodyMedium),
                Text(
                  'Free',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTextStyles.titleMedium),
                Text(
                  Helpers.formatCurrency(cartProvider.totalPrice),
                  style: AppTextStyles.priceLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Checkout button
            LoadingButton(
              onPressed: cartProvider.allItemsAvailable
                  ? () {
                      // Navigate to checkout
                      Helpers.showInfoSnackbar(
                        context,
                        'Checkout coming soon!',
                      );
                    }
                  : null,
              text: 'Proceed to Checkout',
              icon: Icons.lock_outline,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Clear Cart?', style: AppTextStyles.titleLarge),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              context.read<CartProvider>().clearCart(authProvider.uid!);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final String uid;

  const _CartItemCard({required this.item, required this.uid});

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Dismissible(
      key: Key(item.productId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<CartProvider>().removeFromCart(uid, item.productId);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: product?.imageUrl ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: AppColors.surfaceColor,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: AppColors.surfaceColor,
                  child: const Icon(Icons.watch_rounded),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product != null) ...[
                    Text(
                      product.brand.toUpperCase(),
                      style: AppTextStyles.brandName.copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      style: AppTextStyles.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else ...[
                    Text('Loading...', style: AppTextStyles.bodyMedium),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    Helpers.formatCurrency(item.subtotal),
                    style: AppTextStyles.priceSmall,
                  ),
                ],
              ),
            ),
            // Quantity controls
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () async {
                    final provider = context.read<CartProvider>();
                    final success = await provider.incrementQuantity(
                      uid,
                      item.productId,
                    );
                    if (!success && context.mounted) {
                      Helpers.showErrorSnackbar(
                        context,
                        provider.errorMessage ?? 'Cannot increase quantity',
                      );
                    }
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${item.quantity}',
                    style: AppTextStyles.titleSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove, size: 20),
                  onPressed: () {
                    context.read<CartProvider>().decrementQuantity(
                          uid,
                          item.productId,
                        );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
