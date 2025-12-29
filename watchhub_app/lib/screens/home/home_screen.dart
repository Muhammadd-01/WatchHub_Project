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
import '../../core/utils/helpers.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product_model.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/home/product_card.dart';
import '../../widgets/home/category_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: AppColors.primaryGold,
        backgroundColor: theme.cardTheme.color,
        onRefresh: () async {
          await context.read<ProductProvider>().refresh();
        },
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildHeroBanner()),
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
        IconButton(
          icon:
              Icon(Icons.notifications_outlined, color: theme.iconTheme.color),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardBackground, AppColors.surfaceColor],
        ),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1587836374828-4dbafa94cf0e?w=800',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LUXURY',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primaryGold,
                    letterSpacing: 4,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                const SizedBox(height: 8),
                Text(
                  'Timepieces',
                  style: AppTextStyles.displaySmall,
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
                const SizedBox(height: 4),
                Text(
                  'Collection',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: AppColors.primaryGold,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Explore Now'),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Categories', style: AppTextStyles.titleLarge),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: AppConstants.watchCategories.length,
            itemBuilder: (context, index) {
              final category = AppConstants.watchCategories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CategoryChip(
                  label: category,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.products,
                      arguments: {'title': category, 'category': category},
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildFeaturedSection() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        final featured = productProvider.featuredProducts;

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
              height: 280,
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
              height: 280,
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

  Widget _buildBrandsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Premium Brands', style: AppTextStyles.titleLarge),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AppConstants.watchBrands.map((brand) {
              return GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
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
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }
}
