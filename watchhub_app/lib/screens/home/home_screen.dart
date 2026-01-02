// =============================================================================
// FILE: home_screen.dart
// PURPOSE: Premium home screen for WatchHub
// DESCRIPTION: Features hero banner, categories, featured products, new arrivals.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/home/product_card.dart';
import '../../widgets/home/category_chip.dart';
import '../../widgets/common/cart_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductProvider>().refresh();
        context.read<CategoryProvider>().refresh();
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.goldGradient,
            ),
            child: Icon(
              Icons.watch_rounded,
              size: 20,
              color: theme.colorScheme
                  .onPrimary, // Dynamic icon color inside gold? actually gold gradient is static, so icon should probably stay static or be dynamic. Let's keep it contrasty. If gradient is gold, icon should probably be dark or light depending on gold. Gold is bright. Dark icon is safe. Or Theme background.
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
        IconButton(
          icon:
              Icon(Icons.notifications_outlined, color: theme.iconTheme.color),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.notifications);
          },
        ),
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
                        foregroundColor: Colors.black,
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
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CategoryChip(
                      label: category.name,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.products,
                          arguments: {
                            'title': category.name,
                            'category': category.name
                          },
                        );
                      },
                    ),
                  );
                },
              ),
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
            SizedBox(
              height: 320,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: featured.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ProductCard(
                      product: featured[index],
                      width: 180,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (100 * index).ms)
                      .slideX(begin: 0.2);
                },
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
            SizedBox(
              height: 320,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: newArrivals.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ProductCard(
                      product: newArrivals[index],
                      width: 180,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (100 * index).ms)
                      .slideX(begin: 0.2);
                },
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
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AppConstants.watchBrands.map((brand) {
              return GlassContainer(
                borderRadius: 12,
                opacity: 0.05,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.products,
                      arguments: {'title': brand, 'brand': brand},
                    );
                  },
                  child: Text(
                    brand,
                    style: AppTextStyles.labelLarge.copyWith(
                      color:
                          theme.textTheme.titleMedium?.color?.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.1);
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
