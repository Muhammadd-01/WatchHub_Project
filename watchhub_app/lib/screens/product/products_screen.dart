// =============================================================================
// FILE: products_screen.dart
// PURPOSE: Products listing screen for WatchHub
// DESCRIPTION: Full product catalog with filtering and sorting options.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/product_provider.dart';
import '../../widgets/home/product_card.dart';
import '../../widgets/home/category_chip.dart';

class ProductsScreen extends StatefulWidget {
  final String title;
  final String? brand;
  final String? category;

  const ProductsScreen({
    super.key,
    required this.title,
    this.brand,
    this.category,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid "setState() or markNeedsBuild() called during build"
    // error when providers notify listeners (due to filter updates) during initialization.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    final provider = context.read<ProductProvider>();

    if (widget.brand != null) {
      provider.setBrandFilter(widget.brand);
    }
    if (widget.category != null) {
      provider.setCategoryFilter(widget.category);
    }

    await provider.loadProducts();
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildSortSheet(),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        title: Text(widget.title, style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Sort bar
          _buildSortBar(),

          // Products grid
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGold,
                      ),
                    ),
                  );
                }

                if (provider.products.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  color: AppColors.primaryGold,
                  onRefresh: _loadProducts,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.60,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: provider.products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: provider.products[index],
                      ).animate().fadeIn(delay: (50 * index).ms);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${provider.products.length} watches',
                style: AppTextStyles.bodySmall,
              ),
              TextButton.icon(
                onPressed: _showSortSheet,
                icon: const Icon(Icons.sort_rounded, size: 18),
                label: Text(_getSortLabel(_sortBy)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortSheet() {
    final sortOptions = [
      {'value': 'newest', 'label': 'Newest First'},
      {'value': 'price_asc', 'label': 'Price: Low to High'},
      {'value': 'price_desc', 'label': 'Price: High to Low'},
      {'value': 'rating', 'label': 'Highest Rated'},
      {'value': 'name', 'label': 'Name A-Z'},
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort By', style: AppTextStyles.titleLarge),
          const SizedBox(height: 16),
          ...sortOptions.map((option) {
            final isSelected = _sortBy == option['value'];
            return ListTile(
              title: Text(
                option['label']!,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isSelected ? AppColors.primaryGold : null,
                ),
              ),
              trailing: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.primaryGold,
                    )
                  : null,
              onTap: () {
                setState(() => _sortBy = option['value']!);
                context.read<ProductProvider>().setSortBy(option['value']!);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Consumer<ProductProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filters', style: AppTextStyles.titleLarge),
                      TextButton(
                        onPressed: () {
                          provider.clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        // Brands
                        Text('Brands', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppConstants.watchBrands.map((brand) {
                            final isSelected = provider.selectedBrand == brand;
                            return CategoryChip(
                              label: brand,
                              isSelected: isSelected,
                              onTap: () {
                                provider.setBrandFilter(
                                  isSelected ? null : brand,
                                );
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Categories
                        Text('Categories', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppConstants.watchCategories.map((cat) {
                            final isSelected = provider.selectedCategory == cat;
                            return CategoryChip(
                              label: cat,
                              isSelected: isSelected,
                              onTap: () {
                                provider.setCategoryFilter(
                                  isSelected ? null : cat,
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.watch_off_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text('No watches found', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text('Try adjusting your filters', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              context.read<ProductProvider>().clearFilters();
              _loadProducts();
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'price_asc':
        return 'Price ↑';
      case 'price_desc':
        return 'Price ↓';
      case 'rating':
        return 'Rating';
      case 'name':
        return 'Name';
      default:
        return 'Newest';
    }
  }
}
