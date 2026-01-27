// =============================================================================
// FILE: search_screen.dart
// PURPOSE: Product search screen
// DESCRIPTION: Allows users to search for products by name or brand.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_text_styles.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/home/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _searchResults = [];
  bool _isSearchExpanded = false;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final productProvider = context.read<ProductProvider>();
    // Ensure products are loaded
    if (productProvider.products.isEmpty) {
      productProvider.refresh();
    }

    final results = productProvider.products.where((product) {
      final titleLower = product.name.toLowerCase();
      final brandLower = product.brand.toLowerCase();
      final queryLower = query.toLowerCase();
      return titleLower.contains(queryLower) || brandLower.contains(queryLower);
    }).toList();

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      context.read<SearchProvider>().addSearch(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutQuint,
          switchOutCurve: Curves.easeInQuint,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _isSearchExpanded
              ? Container(
                  key: const ValueKey('search_field'),
                  height: 45,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search watches...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                      prefixIcon: Icon(Icons.search,
                          color: Theme.of(context).primaryColor),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.cancel_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: _performSearch,
                    onSubmitted: _onSearchSubmitted,
                  ),
                )
              : Text(
                  'Search',
                  key: const ValueKey('search_title'),
                  style: AppTextStyles.appBarTitle.copyWith(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchExpanded ? Icons.close_rounded : Icons.search_rounded,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              setState(() {
                if (_isSearchExpanded) {
                  _isSearchExpanded = false;
                  _searchController.clear();
                  _performSearch('');
                } else {
                  _isSearchExpanded = true;
                }
              });
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _getBodyContent(),
    );
  }

  Widget _getBodyContent() {
    if (_isSearching) {
      return Center(
        key: const ValueKey('searching'),
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      );
    }

    // Get products from provider
    final productProvider = context.watch<ProductProvider>();
    final allProducts = productProvider.products;

    // Determine which products to show
    List<ProductModel> displayProducts;
    if (_searchController.text.isEmpty) {
      // Show all products when no search query
      displayProducts = allProducts;
    } else if (_searchResults.isEmpty) {
      // Show no results message
      return Center(
        key: const ValueKey('no_results'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 64, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text(
              'No results found for "${_searchController.text}"',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      );
    } else {
      // Show search results
      displayProducts = _searchResults;
    }

    // Show loading if products are still loading
    if (displayProducts.isEmpty && productProvider.isLoading) {
      return Center(
        key: const ValueKey('loading'),
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      );
    }

    // Show empty state if no products available
    if (displayProducts.isEmpty) {
      return Center(
        key: const ValueKey('empty'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.watch_off,
                size: 64, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text(
              'No products available',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      key: ValueKey(
          'products_${_searchController.text.isEmpty ? "all" : "search"}'),
      children: [
        // Recent searches chips (only when search field is expanded but empty)
        if (_isSearchExpanded && _searchController.text.isEmpty)
          _buildRecentSearchesChips(),

        // Products grid
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: GridView.builder(
              key: ValueKey(
                  'grid_${displayProducts.length}_${_searchController.text}'),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: displayProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(product: displayProducts[index])
                    .animate()
                    .fadeIn(delay: (50 * (index % 10)).ms, duration: 300.ms)
                    .slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSearchesChips() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        final searches = searchProvider.recentSearches;

        if (searches.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => searchProvider.clearHistory(),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: searches.take(5).map((query) {
                  return ActionChip(
                    label: Text(query, style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      _searchController.text = query;
                      _performSearch(query);
                    },
                    backgroundColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
