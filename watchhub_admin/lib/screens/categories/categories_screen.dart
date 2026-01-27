// =============================================================================
// FILE: categories_screen.dart
// PURPOSE: Manage Product Categories
// DESCRIPTION: Add and delete categories with multi-select support.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/admin_helpers.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/animated_reload_button.dart';
import '../../providers/admin_category_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _controller = TextEditingController();
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCategoryProvider>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      if (_selectedIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _selectAll(List<Map<String, dynamic>> categories) {
    setState(() {
      if (_selectedIds.length == categories.length) {
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedIds.clear();
        for (var c in categories) {
          _selectedIds.add(c['id']);
        }
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Selected',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
            'Are you sure you want to delete ${_selectedIds.length} categories?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = context.read<AdminCategoryProvider>();
      int successCount = 0;
      for (final id in _selectedIds.toList()) {
        final success = await provider.deleteCategory(id);
        if (success) successCount++;
      }
      setState(() {
        _selectedIds.clear();
        _isSelectionMode = false;
      });
      if (mounted) {
        AdminHelpers.showSuccessSnackbar(
            context, '$successCount categories deleted');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title:
          _isSelectionMode ? '${_selectedIds.length} Selected' : 'Categories',
      actions: [
        if (_isSelectionMode) ...[
          // Select all button - shown immediately in selection mode
          Consumer<AdminCategoryProvider>(
            builder: (context, provider, _) => IconButton(
              onPressed: () => _selectAll(provider.categories),
              icon: Icon(
                _selectedIds.length == provider.categories.length
                    ? Icons.deselect
                    : Icons.select_all,
                size: 22,
              ),
              tooltip: _selectedIds.length == provider.categories.length
                  ? 'Deselect All'
                  : 'Select All',
              color: AppColors.primaryGold,
            ),
          ),
          // Delete selected button
          IconButton(
            onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
            icon: const Icon(Icons.delete_sweep, size: 22),
            tooltip: 'Delete Selected',
            color: _selectedIds.isEmpty
                ? AppColors.textSecondary
                : AppColors.error,
          ),
          // Cancel selection
          IconButton(
            onPressed: () {
              setState(() {
                _isSelectionMode = false;
                _selectedIds.clear();
              });
            },
            icon: const Icon(Icons.close, size: 22),
            tooltip: 'Cancel',
            color: AppColors.error,
          ),
        ] else ...[
          // Selection mode toggle
          IconButton(
            onPressed: () {
              setState(() {
                _isSelectionMode = true;
              });
            },
            icon: const Icon(Icons.checklist, size: 22),
            tooltip: 'Select Multiple',
            color: AppColors.textSecondary,
          ),
          AnimatedReloadButton(
            onPressed: () {
              context.read<AdminCategoryProvider>().fetchCategories();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle,
                color: AppColors.primaryGold, size: 26),
            onPressed: _showAddDialog,
            tooltip: 'Add Category',
          ),
        ],
        const SizedBox(width: 8),
      ],
      body: Consumer<AdminCategoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold));
          }

          if (provider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.category_outlined,
                      size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text('No categories found', style: AppTextStyles.titleMedium),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final cat = provider.categories[index];
              final isSelected = _selectedIds.contains(cat['id']);

              return GestureDetector(
                onLongPress: () {
                  setState(() {
                    _isSelectionMode = true;
                    _toggleSelection(cat['id']);
                  });
                },
                onTap:
                    _isSelectionMode ? () => _toggleSelection(cat['id']) : null,
                child: Card(
                  color: isSelected
                      ? AppColors.primaryGold.withValues(alpha: 0.2)
                      : AppColors.cardBackground,
                  elevation: 4,
                  child: Stack(
                    children: [
                      // Checkbox in selection mode
                      if (_isSelectionMode)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggleSelection(cat['id']),
                            activeColor: AppColors.primaryGold,
                          ),
                        ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            cat['name'] ?? '',
                            style: AppTextStyles.titleMedium
                                .copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      if (!_isSelectionMode)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.delete,
                                size: 20, color: AppColors.error),
                            onPressed: () =>
                                _deleteCategory(cat['id'], cat['name']),
                          ),
                        ),
                    ],
                  ),
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
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'Enter category name...',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (_controller.text.trim().isEmpty) {
                AdminHelpers.showErrorSnackbar(
                    context, 'Category name is required');
                return;
              }
              await context
                  .read<AdminCategoryProvider>()
                  .addCategory(_controller.text.trim());
              _controller.clear();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(String id, String? name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Category',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
            'Are you sure you want to delete "${name ?? 'this category'}"?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<AdminCategoryProvider>().deleteCategory(id);
    }
  }
}
