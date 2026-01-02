// =============================================================================
// FILE: wishlist_screen.dart
// PURPOSE: Wishlist screen for WatchHub
// DESCRIPTION: Displays saved wishlist items with move to cart option.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/wishlist_model.dart';
import '../../widgets/common/loading_button.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Wishlist',
            style: AppTextStyles.appBarTitle.copyWith(
              color: Theme.of(context).textTheme.titleLarge?.color,
            )),
        centerTitle: true,
      ),
      body: Consumer2<WishlistProvider, AuthProvider>(
        builder: (context, wishlistProvider, authProvider, _) {
          if (!authProvider.isAuthenticated) {
            return _buildLoginPrompt(context);
          }

          if (wishlistProvider.isEmpty) {
            return _buildEmptyWishlist(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wishlistProvider.items.length,
            itemBuilder: (context, index) {
              final item = wishlistProvider.items[index];
              return _WishlistItemCard(
                item: item,
                uid: authProvider.uid!,
              ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
            },
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
              Icons.favorite_outline,
              size: 80,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 24),
            Text('Sign in to view wishlist',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                )),
            const SizedBox(height: 8),
            Text(
              'Save your favorite watches for later',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
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

  Widget _buildEmptyWishlist(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 80,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 24),
            Text('Your wishlist is empty',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                )),
            const SizedBox(height: 8),
            Text(
              'Save watches you love by tapping the heart icon',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            LoadingButton(onPressed: () {}, text: 'Browse Watches', width: 200),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}

class _WishlistItemCard extends StatelessWidget {
  final WishlistItemModel item;
  final String uid;

  const _WishlistItemCard({required this.item, required this.uid});

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
        context.read<WishlistProvider>().removeFromWishlist(
              uid,
              item.productId,
            );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.productDetails,
            arguments: item.productId,
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
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
                    color: Theme.of(context).cardColor,
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: Theme.of(context).cardColor,
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
                        style: AppTextStyles.titleSmall.copyWith(
                          color: Theme.of(context).textTheme.titleSmall?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Helpers.formatCurrency(product.price),
                        style: AppTextStyles.priceSmall,
                      ),
                    ] else ...[
                      Text('Loading...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          )),
                    ],
                  ],
                ),
              ),
              // Actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    onPressed: () async {
                      final success = await context
                          .read<WishlistProvider>()
                          .moveToCart(uid, item.productId);
                      if (success && context.mounted) {
                        Helpers.showSuccessSnackbar(context, 'Moved to cart');
                      }
                    },
                    tooltip: 'Move to cart',
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.primaryGold,
                      backgroundColor: AppColors.primaryGold.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () {
                      context.read<WishlistProvider>().removeFromWishlist(
                            uid,
                            item.productId,
                          );
                    },
                    tooltip: 'Remove',
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
