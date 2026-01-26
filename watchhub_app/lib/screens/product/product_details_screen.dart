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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    Container(color: Theme.of(context).cardColor),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).cardColor,
                  child: Icon(Icons.watch_rounded,
                      size: 64, color: Theme.of(context).disabledColor),
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
                    colors: [
                      Colors.transparent,
                      Theme.of(context).scaffoldBackgroundColor
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: BackButton(
          color: Theme.of(context).iconTheme.color,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Consumer<WishlistProvider>(
          builder: (context, wishlistProvider, _) {
            final isInWishlist = wishlistProvider.isInWishlist(product.id);
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_outline,
                  color: isInWishlist
                      ? AppColors.error
                      : Theme.of(context).iconTheme.color,
                ),
                onPressed: () => _toggleWishlist(product),
              ),
            );
          },
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.share_outlined,
                color: Theme.of(context).iconTheme.color),
            onPressed: () {
              // Share functionality
            },
          ),
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
            style: AppTextStyles.brandName.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ).animate().fadeIn().slideX(begin: -0.1),

          const SizedBox(height: 8),

          // Name
          Text(
            product.name,
            style: AppTextStyles.headlineMedium.copyWith(
              color: Theme.of(context).textTheme.headlineMedium?.color,
            ),
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
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          // Price
          Row(
            children: [
              Text(
                Helpers.formatCurrency(product.price),
                style: AppTextStyles.priceLarge.copyWith(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              if (product.isOnSale) ...[
                const SizedBox(width: 12),
                Text(
                  Helpers.formatCurrency(product.originalPrice!),
                  style: AppTextStyles.bodyLarge.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: Theme.of(context).disabledColor,
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
          Text('Description',
              style: AppTextStyles.titleMedium.copyWith(
                color: Theme.of(context).textTheme.titleMedium?.color,
              )),
          const SizedBox(height: 8),
          Text(product.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              )),
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
          Text('Specifications',
              style: AppTextStyles.titleMedium.copyWith(
                color: Theme.of(context).textTheme.titleMedium?.color,
              )),
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
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Text(
                        entry.value.toString(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
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
              Text('Reviews',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  )),
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
                    color: Theme.of(context).primaryColor,
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
                        color: Theme.of(context).primaryColor,
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
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
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
            child: ElevatedButton.icon(
              onPressed: () {
                final authProvider = context.read<AuthProvider>();
                if (!authProvider.isAuthenticated) {
                  Navigator.pushNamed(context, AppRoutes.login);
                  return;
                }
                Navigator.pushNamed(context, AppRoutes.writeReview,
                    arguments: product.id);
              },
              icon: const Icon(Icons.rate_review_rounded),
              label: const Text('Write a Community Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
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
          Text(rating,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              )),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor:
                    Theme.of(context).disabledColor.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
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
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Use vertical layout for narrow screens
            final isNarrow = constraints.maxWidth < 360;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quantity and buttons row (or column for narrow screens)
                if (isNarrow) ...[
                  // Quantity selector on its own row for narrow screens
                  _buildQuantitySelector(product),
                  const SizedBox(height: 12),
                  // Buttons stacked
                  _buildAddToCartButton(product),
                  const SizedBox(height: 8),
                  _buildBuyNowButton(product),
                ] else ...[
                  // Normal horizontal layout
                  Row(
                    children: [
                      // Quantity selector
                      _buildQuantitySelector(product),
                      const SizedBox(width: 12),
                      // Buttons
                      Expanded(child: _buildAddToCartButton(product)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildBuyNowButton(product)),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove, color: Theme.of(context).iconTheme.color),
            onPressed: _decrementQuantity,
            iconSize: 20,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('$_quantity',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                )),
          ),
          IconButton(
            icon: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
            onPressed: () => _incrementQuantity(product),
            iconSize: 20,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(ProductModel product) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return LoadingButton(
          onPressed: product.isInStock ? () => _addToCart(product) : null,
          isLoading: cartProvider.isLoading,
          text: 'Add to Cart',
          icon: Icons.shopping_cart_outlined,
          outlined: true,
          height: 48,
        );
      },
    );
  }

  Widget _buildBuyNowButton(ProductModel product) {
    return LoadingButton(
      onPressed: product.isInStock
          ? () {
              final authProvider = context.read<AuthProvider>();
              if (!authProvider.isAuthenticated) {
                Navigator.pushNamed(context, AppRoutes.login);
                return;
              }
              Navigator.pushNamed(
                context,
                AppRoutes.checkout,
                arguments: {
                  'product': product,
                  'quantity': _quantity,
                },
              );
            }
          : null,
      text: 'Buy Now',
      icon: Icons.flash_on_rounded,
      height: 48,
    );
  }
}
