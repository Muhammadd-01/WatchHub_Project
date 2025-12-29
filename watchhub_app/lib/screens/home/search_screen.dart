// =============================================================================
// FILE: search_screen.dart
// PURPOSE: Search screen for WatchHub
// DESCRIPTION: Premium search UI with real-time search and results.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/custom_text_field.dart';
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
    context.read<ProductProvider>().searchProducts(query);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<ProductProvider>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        title: Text('Search', style: AppTextStyles.appBarTitle),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchTextField(
              controller: _searchController,
              hint: 'Search luxury watches...',
              onChanged: _onSearch,
              onClear: _clearSearch,
              autofocus: false,
            ),
          ),

          // Content
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                if (_searchController.text.isEmpty) {
                  return _buildSuggestions();
                }

                if (provider.isLoading) {
                  return _buildLoading();
                }

                if (provider.searchResults.isEmpty) {
                  return _buildNoResults();
                }

                return _buildResults(provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                backgroundColor: AppColors.cardBackground,
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
                backgroundColor: AppColors.cardBackground,
                side: BorderSide(color: AppColors.cardBorder),
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

          const SizedBox(height: 32),

          // Recent searches placeholder
          Text('Trending Searches', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          ...['Submariner', 'Speedmaster', 'Nautilus', 'Royal Oak'].map(
            (term) => ListTile(
              leading: const Icon(
                Icons.trending_up_rounded,
                color: AppColors.primaryGold,
              ),
              title: Text(term, style: AppTextStyles.bodyMedium),
              onTap: () {
                _searchController.text = term;
                _onSearch(term);
              },
              contentPadding: EdgeInsets.zero,
            ),
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
