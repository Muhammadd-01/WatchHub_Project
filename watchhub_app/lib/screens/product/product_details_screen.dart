// =============================================================================
// FILE: product_details_screen.dart
// PURPOSE: Product details screen for WatchHub
// DESCRIPTION: Full product information with images, specs, reviews, add to cart.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product_model.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/loading_button.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid "setState() or markNeedsBuild() called during build"
    // error when providers notify listeners (update selected product) during initialization.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProduct();
    });
  }

  Future<void> _loadProduct() async {
    await context.read<ProductProvider>().getProduct(widget.productId);
  }

  void _incrementQuantity(ProductModel product) {
    if (_quantity < product.stock) {
      setState(() => _quantity++);
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Future<void> _addToCart(ProductModel product) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    final cartProvider = context.read<CartProvider>();
    final success = await cartProvider.addToCart(
      authProvider.uid!,
      product,
      quantity: _quantity,
    );

    if (success && mounted) {
      Helpers.showSuccessSnackbar(context, '${product.name} added to cart');
    }
  }

  Future<void> _toggleWishlist(ProductModel product) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    final wishlistProvider = context.read<WishlistProvider>();
    await wishlistProvider.toggleWishlist(authProvider.uid!, product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final product = provider.selectedProduct;

          if (product == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGold,
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(product),
              SliverToBoxAdapter(child: _buildProductInfo(product)),
              SliverToBoxAdapter(child: _buildSpecifications(product)),
              SliverToBoxAdapter(child: _buildReviewsSection(product)),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final product = provider.selectedProduct;
          if (product == null) return const SizedBox.shrink();
          return _buildBottomBar(product);
        },
      ),
    );
  }

  Widget _buildAppBar(ProductModel product) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: AppColors.scaffoldBackground,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'product_${product.id}',
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: AppColors.cardBackground),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.cardBackground,
                  child: const Icon(Icons.watch_rounded, size: 64),
                ),
              ),
            ),
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppColors.scaffoldBackground],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Consumer<WishlistProvider>(
          builder: (context, wishlistProvider, _) {
            final isInWishlist = wishlistProvider.isInWishlist(product.id);
            return IconButton(
              icon: Icon(
                isInWishlist ? Icons.favorite : Icons.favorite_outline,
                color: isInWishlist ? AppColors.error : null,
              ),
              onPressed: () => _toggleWishlist(product),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () {
            // Share functionality
          },
        ),
      ],
    );
  }

  Widget _buildProductInfo(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          Text(
            product.brand.toUpperCase(),
            style: AppTextStyles.brandName,
          ).animate().fadeIn().slideX(begin: -0.1),

          const SizedBox(height: 8),

          // Name
          Text(
            product.name,
            style: AppTextStyles.headlineMedium,
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

          const SizedBox(height: 16),

          // Rating
          Row(
            children: [
              ...List.generate(5, (index) {
                final filled = index < product.rating.floor();
                final halfFilled = index == product.rating.floor() &&
                    product.rating % 1 >= 0.5;
                return Icon(
                  filled
                      ? Icons.star_rounded
                      : halfFilled
                          ? Icons.star_half_rounded
                          : Icons.star_outline_rounded,
                  color: AppColors.ratingColor,
                  size: 20,
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${product.rating} (${product.reviewCount} reviews)',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          // Price
          Row(
            children: [
              Text(
                Helpers.formatCurrency(product.price),
                style: AppTextStyles.priceLarge,
              ),
              if (product.isOnSale) ...[
                const SizedBox(width: 12),
                Text(
                  Helpers.formatCurrency(product.originalPrice!),
                  style: AppTextStyles.bodyLarge.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-${product.discountPercentage}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 8),

          // Stock status
          Row(
            children: [
              Icon(
                product.isInStock ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: product.isInStock ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                product.isInStock
                    ? '${product.stock} in stock'
                    : 'Out of stock',
                style: AppTextStyles.bodySmall.copyWith(
                  color:
                      product.isInStock ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Description
          Text('Description', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(product.description, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildSpecifications(ProductModel product) {
    if (product.specifications.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Specifications', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: product.specifications.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        entry.value.toString(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildReviewsSection(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reviews', style: AppTextStyles.titleMedium),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.reviews,
                    arguments: product.id,
                  );
                },
                child: Text(
                  'See All',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: AppTextStyles.displaySmall.copyWith(
                        color: AppColors.primaryGold,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < product.rating.floor()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: AppColors.ratingColor,
                          size: 16,
                        );
                      }),
                    ),
                    Text(
                      '${product.reviewCount} reviews',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBar('5', 0.7),
                      _buildRatingBar('4', 0.15),
                      _buildRatingBar('3', 0.1),
                      _buildRatingBar('2', 0.03),
                      _buildRatingBar('1', 0.02),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final authProvider = context.read<AuthProvider>();
                if (!authProvider.isAuthenticated) {
                  Navigator.pushNamed(context, AppRoutes.login);
                  return;
                }
                Navigator.pushNamed(context, AppRoutes.writeReview,
                    arguments: product.id);
              },
              icon: const Icon(Icons.rate_review_outlined,
                  color: AppColors.primaryGold),
              label: const Text('Write a Review',
                  style: TextStyle(color: AppColors.primaryGold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGold),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildRatingBar(String rating, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(rating, style: AppTextStyles.bodySmall),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.cardBackground,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGold,
                ),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _decrementQuantity,
                    iconSize: 20,
                  ),
                  Text('$_quantity', style: AppTextStyles.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _incrementQuantity(product),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Add to cart button
            Expanded(
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, _) {
                  return LoadingButton(
                    onPressed:
                        product.isInStock ? () => _addToCart(product) : null,
                    isLoading: cartProvider.isLoading,
                    text: product.isInStock ? 'Add to Cart' : 'Out of Stock',
                    icon: Icons.shopping_bag_outlined,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
