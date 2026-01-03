// =============================================================================
// FILE: search_screen.dart
// PURPOSE: Search screen for WatchHub with magnifier icon and recent searches
// DESCRIPTION: Premium search UI with expandable search bar and search history.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/product_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/home/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<SearchProvider>().addSearch(query);
      context.read<ProductProvider>().searchProducts(query);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<ProductProvider>().clearSearch();
    context.read<SearchProvider>().setSearchExpanded(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<SearchProvider>(
          builder: (context, searchProvider, _) {
            return Column(
              children: [
                // Header with magnifier/search bar
                _buildSearchHeader(theme, searchProvider),

                // Content
                Expanded(
                  child: Consumer<ProductProvider>(
                    builder: (context, productProvider, _) {
                      if (_searchController.text.isEmpty) {
                        return _buildRecentSearches(searchProvider);
                      }

                      if (productProvider.isLoading) {
                        return _buildLoading();
                      }

                      if (productProvider.searchResults.isEmpty) {
                        return _buildNoResults();
                      }

                      return _buildResults(productProvider);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchHeader(ThemeData theme, SearchProvider searchProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
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
        child: searchProvider.isSearchExpanded
            ? _buildExpandedSearchBar(theme, searchProvider)
            : _buildCollapsedSearchBar(theme, searchProvider),
      ),
    );
  }

  Widget _buildCollapsedSearchBar(
      ThemeData theme, SearchProvider searchProvider) {
    return Row(
      key: const ValueKey('collapsed'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Search Watches',
          style: AppTextStyles.titleLarge.copyWith(
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.search,
            color: AppColors.primaryGold,
            size: 28,
          ),
          onPressed: () {
            searchProvider.setSearchExpanded(true);
            _focusNode.requestFocus();
          },
        ),
      ],
    );
  }

  Widget _buildExpandedSearchBar(
      ThemeData theme, SearchProvider searchProvider) {
    return Row(
      key: const ValueKey('expanded'),
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Search luxury watches...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
              filled: true,
              fillColor: theme.cardColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.primaryGold),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primaryGold, width: 2),
              ),
            ),
            onChanged: _onSearch,
            onSubmitted: _onSearch,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: _clearSearch,
        ),
      ],
    );
  }

  Widget _buildRecentSearches(SearchProvider searchProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (searchProvider.recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Searches', style: AppTextStyles.titleMedium),
                TextButton(
                  onPressed: () => searchProvider.clearHistory(),
                  child: Text(
                    'Clear All',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...searchProvider.recentSearches.map((search) {
              return ListTile(
                leading: const Icon(
                  Icons.history,
                  color: AppColors.textSecondary,
                ),
                title: Text(search, style: AppTextStyles.bodyMedium),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => searchProvider.removeSearch(search),
                ),
                onTap: () {
                  _searchController.text = search;
                  _onSearch(search);
                },
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 32),
          ],

          // Popular brands
          Text('Popular Brands', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.watchBrands.map((brand) {
              return ActionChip(
                label: Text(brand),
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primaryGold,
                ),
                backgroundColor: Theme.of(context).cardColor,
                side: BorderSide(color: AppColors.primaryGold.withOpacity(0.3)),
                onPressed: () {
                  _searchController.text = brand;
                  _onSearch(brand);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Categories
          Text('Categories', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.watchCategories.map((category) {
              return ActionChip(
                label: Text(category),
                labelStyle: AppTextStyles.labelMedium,
                backgroundColor: Theme.of(context).cardColor,
                side: BorderSide(color: Theme.of(context).dividerColor),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.products,
                    arguments: {'title': category, 'category': category},
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text('No watches found', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Try searching for a different term',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildResults(ProductProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${provider.searchResults.length} results found',
            style: AppTextStyles.bodySmall,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.60,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: provider.searchResults.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: provider.searchResults[index],
              ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1);
            },
          ),
        ),
      ],
    );
  }
}
