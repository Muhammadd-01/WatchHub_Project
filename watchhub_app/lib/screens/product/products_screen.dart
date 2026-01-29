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
      await provider.loadProductsByBrand(widget.brand!);
      return;
    }
    if (widget.category != null) {
      await provider.loadProductsByCategory(widget.category!);
      return;
    }

    await Future.wait([
      provider.loadProducts(),
      provider.loadFilters(),
    ]);
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(widget.title,
            style: AppTextStyles.appBarTitle.copyWith(
              color: Theme.of(context).textTheme.titleLarge?.color,
            )),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded,
                color: Theme.of(context).iconTheme.color),
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
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  );
                }

                if (provider.products.isEmpty) {
                  return _buildEmptyState();
                }

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: RefreshIndicator(
                    key: ValueKey(
                        '${provider.products.length}_${_sortBy}_${provider.selectedBrands.length}'),
                    color: Theme.of(context).primaryColor,
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
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              TextButton.icon(
                onPressed: _showSortSheet,
                icon: Icon(Icons.sort_rounded,
                    size: 18, color: Theme.of(context).primaryColor),
                label: Text(_getSortLabel(_sortBy),
                    style: TextStyle(color: Theme.of(context).primaryColor)),
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

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort By',
              style: AppTextStyles.titleLarge.copyWith(
                color: Theme.of(context).textTheme.titleLarge?.color,
              )),
          const SizedBox(height: 16),
          ...sortOptions.map((option) {
            final isSelected = _sortBy == option['value'];
            return ListTile(
              title: Text(
                option['label']!,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      color: Theme.of(context).primaryColor,
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
    final provider = context.read<ProductProvider>();
    List<String> tempSelectedBrands = List.from(provider.selectedBrands);
    List<String> tempSelectedCategories =
        List.from(provider.selectedCategories);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filters',
                          style: AppTextStyles.titleLarge.copyWith(
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          )),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            tempSelectedBrands.clear();
                            tempSelectedCategories.clear();
                          });
                        },
                        child: Text('Clear All',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor)),
                      ),
                    ],
                  ),
                  Divider(color: Theme.of(context).dividerColor),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        // Brands
                        Text('Brands',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color,
                            )),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: provider.availableBrands.map((brand) {
                            final isSelected =
                                tempSelectedBrands.contains(brand);
                            return CategoryChip(
                              label: brand,
                              isSelected: isSelected,
                              onTap: () {
                                setSheetState(() {
                                  if (isSelected) {
                                    tempSelectedBrands.remove(brand);
                                  } else {
                                    tempSelectedBrands.add(brand);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Categories
                        Text('Categories',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color,
                            )),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: provider.availableCategories.map((cat) {
                            final isSelected =
                                tempSelectedCategories.contains(cat);
                            return CategoryChip(
                              label: cat,
                              isSelected: isSelected,
                              onTap: () {
                                setSheetState(() {
                                  if (isSelected) {
                                    tempSelectedCategories.remove(cat);
                                  } else {
                                    tempSelectedCategories.add(cat);
                                  }
                                });
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
                      onPressed: () {
                        provider.updateFilters(
                          brands: tempSelectedBrands,
                          categories: tempSelectedCategories,
                        );
                        Navigator.pop(context);
                      },
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
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text('No watches found',
              style: AppTextStyles.titleMedium.copyWith(
                color: Theme.of(context).textTheme.titleMedium?.color,
              )),
          const SizedBox(height: 8),
          Text('Try adjusting your filters',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              )),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              context.read<ProductProvider>().clearFilters();
              _loadProducts();
            },
            child: Text('Clear Filters',
                style: TextStyle(color: Theme.of(context).primaryColor)),
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
