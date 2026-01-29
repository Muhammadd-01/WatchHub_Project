// =============================================================================
// FILE: home_screen.dart
// PURPOSE: Premium home screen for WatchHub
// DESCRIPTION: Features hero banner, categories, featured products, new arrivals.
// =============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../models/product_model.dart';
import '../../widgets/common/cart_badge.dart';
import '../../widgets/home/auto_looping_product_card.dart';
import '../../widgets/common/notification_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Simple one-time data fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Only fetch once when first visiting the screen
      final productProvider = context.read<ProductProvider>();
      final categoryProvider = context.read<CategoryProvider>();

      if (!productProvider.hasProducts) {
        productProvider.refresh();
        productProvider.loadExclusiveProducts();
      }
      if (categoryProvider.categories.isEmpty) {
        categoryProvider.refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: AppColors.primaryGold,
        backgroundColor: theme.cardTheme.color,
        onRefresh: () async {
          await Future.wait([
            context.read<ProductProvider>().refresh(),
            context.read<CategoryProvider>().refresh(),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildHeroBanner()),
            const SliverToBoxAdapter(child: _ErrorBanner()),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(child: _buildFeaturedSection()),
            SliverToBoxAdapter(child: _buildExclusiveSection()),
            SliverToBoxAdapter(child: _buildNewArrivalsSection()),
            SliverToBoxAdapter(child: _buildBrandsSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final theme = Theme.of(context);
    return SliverAppBar(
      floating: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      title: Row(
        children: [
          // WatchHub Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/watchhub_logo.png',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Text('WatchHub',
              style: AppTextStyles.appBarTitle
                  .copyWith(color: theme.textTheme.titleLarge?.color)),
        ],
      ),
      actions: [
        const CartBadge(),
        const NotificationBadge(),
      ],
    );
  }

  Widget _buildHeroBanner() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GoldGlassContainer(
        borderRadius: 24,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 220),
          child: Stack(
            children: [
              // Background image with overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl:
                            'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=800',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Container(
                          color: theme.cardTheme.color,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.black.withOpacity(0.2),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // Allow dynamic height
                  children: [
                    Text(
                      'PREMIUM EDITION',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primaryGold,
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideX(begin: -0.2),
                    const SizedBox(height: 8),
                    // Use FittedBox to prevent text level overflow and wrapping issues
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Exclusive',
                        style: AppTextStyles.displaySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 600.ms)
                        .slideX(begin: -0.2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Timepieces',
                        style: AppTextStyles.displaySmall.copyWith(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 600.ms)
                        .slideX(begin: -0.2),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.products,
                          arguments: {'title': 'All Watches'},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: AppColors.primaryGold.withOpacity(0.5),
                      ),
                      child: const Text('EXPLORE COLLECTION'),
                    ).animate().fadeIn(delay: 800.ms, duration: 600.ms).scale(
                        begin: const Offset(0.8, 0.8),
                        curve: Curves.easeOutBack),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }

  Widget _buildCategories() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        final categories = categoryProvider.categories;

        if (categoryProvider.isLoading && categories.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Experience Elegance',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primaryGold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Curated Categories',
                  style: AppTextStyles.headlineSmall),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 42,
              child: _AutoScrollingCategories(categories: categories),
            ),
            const SizedBox(height: 32),
          ],
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1);
      },
    );
  }

  Widget _buildFeaturedSection() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        final featured = productProvider.featuredProducts;
        final isLoading = productProvider.isFeaturedLoading;

        if (isLoading && featured.isEmpty) {
          return _buildSectionLoading('Featured');
        }

        if (featured.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Featured', style: AppTextStyles.titleLarge),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.products,
                        arguments: {'title': 'Featured Watches'},
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
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 320,
                child: Builder(builder: (context) {
                  // Split products into two lists
                  final list1 = <ProductModel>[];
                  final list2 = <ProductModel>[];

                  for (var i = 0; i < featured.length; i++) {
                    if (i % 2 == 0) {
                      list1.add(featured[i]);
                    } else {
                      list2.add(featured[i]);
                    }
                  }

                  // If only one product, list2 will remain empty and we handle it in the UI

                  return Row(
                    children: [
                      Expanded(
                        child: AutoLoopingProductCard(
                          products: list1,
                          interval: const Duration(seconds: 5),
                          height: 300,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (list2.isNotEmpty)
                        Expanded(
                          child: AutoLoopingProductCard(
                            products: list2,
                            interval: const Duration(seconds: 4),
                            height: 300,
                          ),
                        )
                      else
                        const Spacer(), // Keeps the first card half-screen width
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildExclusiveSection() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        final exclusive = productProvider.exclusiveProducts;
        final isLoading = productProvider.isExclusiveLoading;

        if (isLoading && exclusive.isEmpty) {
          return _buildSectionLoading('Exclusive');
        }

        if (exclusive.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('Exclusive', style: AppTextStyles.titleLarge),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '★ TOP',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.scaffoldBackground,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.products,
                        arguments: {'title': 'Exclusive Collection'},
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
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 320,
                child: Builder(builder: (context) {
                  // Split products into two lists
                  final list1 = <ProductModel>[];
                  final list2 = <ProductModel>[];

                  for (var i = 0; i < exclusive.length; i++) {
                    if (i % 2 == 0) {
                      list1.add(exclusive[i]);
                    } else {
                      list2.add(exclusive[i]);
                    }
                  }

                  // If only one product, list2 will remain empty and we handle it in the UI

                  return Row(
                    children: [
                      Expanded(
                        child: AutoLoopingProductCard(
                          products: list1,
                          interval: const Duration(seconds: 5),
                          height: 300,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (list2.isNotEmpty)
                        Expanded(
                          child: AutoLoopingProductCard(
                            products: list2,
                            interval: const Duration(seconds: 7),
                            height: 300,
                          ),
                        )
                      else
                        const Spacer(), // Keeps the first card half-screen width
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildNewArrivalsSection() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        final newArrivals = productProvider.newArrivals;
        final isLoading = productProvider.isNewArrivalsLoading;

        if (isLoading && newArrivals.isEmpty) {
          return _buildSectionLoading('New Arrivals');
        }

        if (newArrivals.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('New Arrivals', style: AppTextStyles.titleLarge),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'NEW',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.scaffoldBackground,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.products,
                        arguments: {'title': 'New Arrivals'},
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
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 320,
                child: Builder(builder: (context) {
                  // Split products into two lists
                  final list1 = <ProductModel>[];
                  final list2 = <ProductModel>[];

                  for (var i = 0; i < newArrivals.length; i++) {
                    if (i % 2 == 0) {
                      list1.add(newArrivals[i]);
                    } else {
                      list2.add(newArrivals[i]);
                    }
                  }

                  // Handle single product case - show single card on the left
                  if (newArrivals.length == 1) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: (MediaQuery.of(context).size.width - 48) /
                            2, // Half width adjusted for padding
                        child: AutoLoopingProductCard(
                          products: list1,
                          interval: const Duration(seconds: 6),
                          height: 300,
                        ),
                      ),
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: AutoLoopingProductCard(
                          products: list1,
                          interval: const Duration(seconds: 6),
                          height: 300,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AutoLoopingProductCard(
                          products: list2,
                          interval: const Duration(seconds: 4),
                          height: 300,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildSectionLoading(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: AppTextStyles.titleLarge),
        ),
        const SizedBox(
          height: 280,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryGold),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBrandsSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'World Renowned',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primaryGold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Premium Brands', style: AppTextStyles.headlineSmall),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('brands')
                .orderBy('name')
                .snapshots(),
            builder: (context, snapshot) {
              // Show shimmer while loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryGold),
                );
              }

              final brands = snapshot.data?.docs ?? [];

              // Fallback to constants if no brands in DB
              if (brands.isEmpty) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: AppConstants.watchBrands.map((brand) {
                    return _buildBrandChip(brand, null, theme);
                  }).toList(),
                );
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: brands.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'] as String? ?? '';
                  final logoUrl = data['logoUrl'] as String?;
                  return _buildBrandChip(name, logoUrl, theme);
                }).toList(),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildBrandChip(String brand, String? logoUrl, ThemeData theme) {
    return GlassContainer(
      borderRadius: 12,
      opacity: 0.05,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.products,
            arguments: {'title': brand, 'brand': brand},
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (logoUrl != null && logoUrl.isNotEmpty) ...[
              CachedNetworkImage(
                imageUrl: logoUrl,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              brand.toUpperCase(),
              style: AppTextStyles.labelLarge.copyWith(
                color: theme.textTheme.titleMedium?.color?.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer2<ProductProvider, CategoryProvider>(
      builder: (context, productProvider, categoryProvider, _) {
        final error =
            productProvider.errorMessage ?? categoryProvider.errorMessage;
        if (error == null) return const SizedBox.shrink();

        final isIndexError =
            error.contains('index') || error.contains('FAILED_PRECONDITION');

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    isIndexError
                        ? Icons.settings_input_component
                        : Icons.error_outline,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isIndexError
                          ? 'Action Required: Enable Indexes'
                          : 'Loading Error',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
              if (isIndexError) ...[
                const SizedBox(height: 8),
                Text(
                  'Your products are hidden because Firestore indexes are still building. This usually takes 3-5 minutes after you click the links in Firebase.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  context.read<ProductProvider>().refresh();
                  context.read<CategoryProvider>().refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error.withOpacity(0.1),
                  foregroundColor: theme.colorScheme.error,
                  elevation: 0,
                ),
                child: const Text('Retry Loading Data'),
              ),
            ],
          ),
        ).animate().fadeIn().shake(hz: 4, duration: 500.ms);
      },
    );
  }
}

/// Auto-scrolling categories widget that loops continuously
class _AutoScrollingCategories extends StatefulWidget {
  final List<dynamic> categories;

  const _AutoScrollingCategories({required this.categories});

  @override
  State<_AutoScrollingCategories> createState() =>
      _AutoScrollingCategoriesState();
}

class _AutoScrollingCategoriesState extends State<_AutoScrollingCategories> {
  late ScrollController _scrollController;
  double _scrollPosition = 0;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollPosition += 0.5; // Speed of scroll

      // Reset to beginning when reaching the end
      if (_scrollController.position.maxScrollExtent > 0 &&
          _scrollPosition >= _scrollController.position.maxScrollExtent) {
        _scrollPosition = 0;
        _scrollController.jumpTo(0);
      } else if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollPosition);
      }
    });
  }

  void _stopAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    // Deduplicate categories then triple for seamless loop effect
    final uniqueCategories = widget.categories.toSet().toList();
    final loopedCategories = [
      ...uniqueCategories,
      ...uniqueCategories,
      ...uniqueCategories,
    ];

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Pause auto-scroll when user is manually scrolling
        if (notification is ScrollStartNotification) {
          _stopAutoScroll();
        } else if (notification is ScrollEndNotification) {
          _scrollPosition = _scrollController.offset;
          _startAutoScroll();
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: loopedCategories.length,
        itemBuilder: (context, index) {
          final category = loopedCategories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.products,
                  arguments: {
                    'title': category.name,
                    'category': category.name,
                  },
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGold.withOpacity(0.15),
                      AppColors.primaryGold.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryGold.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  category.name,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
