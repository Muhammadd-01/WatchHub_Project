// =============================================================================
// FILE: categories_screen.dart
// PURPOSE: Manage Product Categories
// DESCRIPTION: Add and delete categories.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/admin_scaffold.dart';
import '../../providers/admin_category_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCategoryProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Categories',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle,
              color: AppColors.primaryGold, size: 30),
          onPressed: _showAddDialog,
          tooltip: 'Add Category',
        ),
        const SizedBox(width: 16),
      ],
      body: Consumer<AdminCategoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading)
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold));

          if (provider.categories.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final cat = provider.categories[index];
              return Card(
                color: AppColors.cardBackground,
                elevation: 4,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        cat['name'] ?? '',
                        style: AppTextStyles.titleMedium
                            .copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.delete,
                            size: 20, color: AppColors.error),
                        onPressed: () => _deleteCategory(cat['id']),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Add Category',
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: _controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (_controller.text.isNotEmpty) {
                await context
                    .read<AdminCategoryProvider>()
                    .addCategory(_controller.text.trim());
                _controller.clear();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(String id) async {
    // Confirmation
    await context.read<AdminCategoryProvider>().deleteCategory(id);
  }
}
