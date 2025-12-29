// =============================================================================
// FILE: category_screen.dart
// PURPOSE: Category/filtered products screen for WatchHub
// DESCRIPTION: Displays products filtered by brand or category.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/product_provider.dart';
import '../../widgets/home/product_card.dart';

class CategoryScreen extends StatefulWidget {
  final String title;
  final String? brand;
  final String? category;

  const CategoryScreen({
    super.key,
    required this.title,
    this.brand,
    this.category,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final provider = context.read<ProductProvider>();

    if (widget.brand != null) {
      await provider.loadProductsByBrand(widget.brand!);
    } else if (widget.category != null) {
      await provider.loadProductsByCategory(widget.category!);
    } else {
      await provider.loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        title: Text(widget.title, style: AppTextStyles.appBarTitle),
      ),
      body: Consumer<ProductProvider>(
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
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryGold,
            onRefresh: _loadProducts,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: provider.products[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
