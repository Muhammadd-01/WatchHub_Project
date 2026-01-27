// =============================================================================
// FILE: products_list_screen.dart
// PURPOSE: List all products
// DESCRIPTION: Displays products in a data table with actions.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/admin_helpers.dart';
import '../../widgets/admin_scaffold.dart';
import '../../providers/admin_product_provider.dart';
import '../../providers/admin_category_provider.dart';
import '../../widgets/reviews_dialog.dart';
import '../../widgets/animated_reload_button.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    // Fetch products on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProductProvider>().fetchProducts();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      // Exit selection mode if nothing selected
      if (_selectedIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _selectAll(List<Map<String, dynamic>> products) {
    setState(() {
      if (_selectedIds.length == products.length) {
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedIds.clear();
        for (var p in products) {
          _selectedIds.add(p['id']);
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
            'Are you sure you want to delete ${_selectedIds.length} products?',
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
      final provider = context.read<AdminProductProvider>();
      int successCount = 0;
      for (final id in _selectedIds.toList()) {
        final success = await provider.deleteProduct(id);
        if (success) successCount++;
      }
      setState(() {
        _selectedIds.clear();
        _isSelectionMode = false;
      });
      if (mounted) {
        AdminHelpers.showSuccessSnackbar(
            context, '$successCount products deleted');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: _isSelectionMode ? '${_selectedIds.length} Selected' : 'Products',
      actions: [
        if (_isSelectionMode) ...[
          // Select all button - shown immediately in selection mode
          Consumer<AdminProductProvider>(
            builder: (context, provider, _) => IconButton(
              onPressed: () => _selectAll(provider.products),
              icon: Icon(
                _selectedIds.length == provider.products.length
                    ? Icons.deselect
                    : Icons.select_all,
                size: 22,
              ),
              tooltip: _selectedIds.length == provider.products.length
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
              context.read<AdminProductProvider>().fetchProducts();
            },
          ),
          const SizedBox(width: 4),
          ElevatedButton.icon(
            onPressed: () {
              _showAddEditProductDialog(context);
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.scaffoldBackground,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
        const SizedBox(width: 8),
      ],
      body: Consumer<AdminProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold));
          }

          if (provider.errorMessage != null) {
            return Center(
                child: Text(provider.errorMessage!,
                    style: const TextStyle(color: AppColors.error)));
          }

          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text('No products found', style: AppTextStyles.titleMedium),
                ],
              ),
            );
          }

          // Responsive layout - cards for mobile, data table for desktop
          final isMobile = MediaQuery.of(context).size.width < 600;

          if (isMobile) {
            // Mobile card layout
            return ListView.builder(
              itemCount: provider.products.length,
              padding: const EdgeInsets.only(bottom: 16),
              itemBuilder: (context, index) {
                final product = provider.products[index];
                final images = product['images'] as List<dynamic>?;
                final imageUrl = (images != null && images.isNotEmpty)
                    ? images.first as String
                    : null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: _selectedIds.contains(product['id'])
                      ? AppColors.primaryGold.withValues(alpha: 0.1)
                      : AppColors.cardBackground,
                  child: InkWell(
                    onLongPress: () {
                      setState(() {
                        _isSelectionMode = true;
                        _toggleSelection(product['id']);
                      });
                    },
                    onTap: _isSelectionMode
                        ? () => _toggleSelection(product['id'])
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Checkbox in selection mode
                          if (_isSelectionMode)
                            Checkbox(
                              value: _selectedIds.contains(product['id']),
                              onChanged: (_) => _toggleSelection(product['id']),
                              activeColor: AppColors.primaryGold,
                            ),
                          // Product image
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.surfaceColor,
                            ),
                            child: imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => const Center(
                                          child: Icon(Icons.image,
                                              size: 24,
                                              color: AppColors.textTertiary)),
                                      errorWidget: (_, __, ___) => const Icon(
                                          Icons.broken_image,
                                          size: 24),
                                    ),
                                  )
                                : const Icon(Icons.image_not_supported,
                                    size: 24, color: AppColors.textTertiary),
                          ),
                          const SizedBox(width: 12),
                          // Product info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'] ?? 'Unknown',
                                  style: AppTextStyles.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product['brand'] ?? '-',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '\$${(product['price'] ?? 0)}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primaryGold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (product['stock'] ?? 0) > 0
                                            ? AppColors.success.withOpacity(0.1)
                                            : AppColors.error.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Stock: ${product['stock'] ?? 0}',
                                        style:
                                            AppTextStyles.labelSmall.copyWith(
                                          color: (product['stock'] ?? 0) > 0
                                              ? AppColors.success
                                              : AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Actions
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  _showAddEditProductDialog(context,
                                      product: product);
                                  break;
                                case 'reviews':
                                  _showReviewsDialog(context, product['id'],
                                      product['name'] ?? 'Product');
                                  break;
                                case 'delete':
                                  _confirmDelete(
                                      context, product['id'], product['name']);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                  value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(
                                  value: 'reviews', child: Text('Reviews')),
                              const PopupMenuItem(
                                  value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          // Desktop data table
          return Theme(
            data: Theme.of(context).copyWith(
              cardColor: AppColors.cardBackground,
              dividerColor: AppColors.divider,
            ),
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 800, // Ensure horizontal scrolling on small screens
              headingRowColor: WidgetStateColor.resolveWith(
                  (states) => AppColors.surfaceColor),
              columns: const [
                DataColumn2(label: Text('Image'), fixedWidth: 80),
                DataColumn2(label: Text('Name'), size: ColumnSize.L),
                DataColumn2(label: Text('Brand'), size: ColumnSize.S),
                DataColumn2(label: Text('Price'), size: ColumnSize.S),
                DataColumn2(label: Text('Stock'), size: ColumnSize.S),
                DataColumn2(label: Text('Category'), size: ColumnSize.M),
                DataColumn2(label: Text('Actions'), fixedWidth: 100),
              ],
              rows: provider.products.map((product) {
                final images = product['images'] as List<dynamic>?;
                final imageUrl = (images != null && images.isNotEmpty)
                    ? images.first as String
                    : null;

                return DataRow(
                  cells: [
                    DataCell(
                      Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.surfaceColor,
                        ),
                        child: imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const Center(
                                      child: Icon(Icons.image,
                                          size: 20,
                                          color: AppColors.textTertiary)),
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.broken_image, size: 20),
                                ),
                              )
                            : const Icon(Icons.image_not_supported,
                                size: 20, color: AppColors.textTertiary),
                      ),
                    ),
                    DataCell(Text(product['name'] ?? 'Unknown',
                        style: AppTextStyles.bodyMedium)),
                    DataCell(Text(product['brand'] ?? '-',
                        style: AppTextStyles.bodyMedium)),
                    DataCell(Text('\$${(product['price'] ?? 0).toString()}',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.primaryGold))),
                    DataCell(Text('${product['stock'] ?? 0}',
                        style: AppTextStyles.bodyMedium)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: AppColors.primaryGold.withOpacity(0.3)),
                        ),
                        child: Text(
                          product['category'] ?? 'Uncategorized',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.primaryGold),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                size: 20, color: AppColors.info),
                            onPressed: () => _showAddEditProductDialog(context,
                                product: product),
                            tooltip: 'Edit',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.reviews_outlined,
                                size: 20, color: AppColors.primaryGold),
                            onPressed: () => _showReviewsDialog(context,
                                product['id'], product['name'] ?? 'Product'),
                            tooltip: 'Reviews',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                size: 20, color: AppColors.error),
                            onPressed: () => _confirmDelete(
                                context, product['id'], product['name']),
                            tooltip: 'Delete',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, String productId, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Confirm Delete',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Are you sure you want to delete "$productName"?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<AdminProductProvider>()
                  .deleteProduct(productId);
              if (mounted) {
                if (mounted) {
                  if (success) {
                    AdminHelpers.showSuccessSnackbar(
                        context, 'Product deleted');
                  } else {
                    AdminHelpers.showErrorSnackbar(
                        context, 'Failed to delete product');
                  }
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddEditProductDialog(BuildContext context,
      {Map<String, dynamic>? product}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.cardBackground,
        insetPadding: const EdgeInsets.all(24),
        child: AddEditProductDialog(product: product),
      ),
    );
  }

  void _showReviewsDialog(
      BuildContext context, String productId, String productName) {
    showDialog(
      context: context,
      builder: (context) => ReviewsDialog(
        productId: productId,
        productName: productName,
      ),
    );
  }
}

// Simple Dialog Implementation for Add/Edit
// In a complex app, this would be a full screen.
class AddEditProductDialog extends StatefulWidget {
  final Map<String, dynamic>? product;

  const AddEditProductDialog({super.key, this.product});

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _specsCtrl;
  String _category = 'Men'; // Default

  // TODO: Add Image Picker logic in the dialog for full implementation

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?['name']);
    _brandCtrl = TextEditingController(text: p?['brand']);
    _priceCtrl = TextEditingController(text: p?['price']?.toString());
    _descCtrl = TextEditingController(text: p?['description']);
    _stockCtrl = TextEditingController(text: p?['stock']?.toString());
    _specsCtrl = TextEditingController(
        text: p?['specifications'] != null
            ? (p!['specifications'] as Map)
                .entries
                .map((e) => '${e.key}: ${e.value}')
                .join('\n')
            : '');
    if (p != null) _category = p['category'] ?? 'Men';

    // Fetch categories if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = context.read<AdminCategoryProvider>();
      if (categoryProvider.categories.isEmpty) {
        categoryProvider.fetchCategories();
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _stockCtrl.dispose();
    _specsCtrl.dispose();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<String> _existingImages = []; // URLs of existing images
  bool _isUploading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize existing images from product data
    if (widget.product != null && _existingImages.isEmpty) {
      final images = widget.product!['images'] as List<dynamic>?;
      if (images != null) {
        _existingImages = images.cast<String>().toList();
      }
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted)
        AdminHelpers.showErrorSnackbar(context, 'Error picking images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Container(
      width: 600,
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit Product' : 'Add New Product',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: 24),
              // Image Picker UI
              Text('Product Images', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              // Show existing images (from URLs)
              if (_existingImages.isNotEmpty) ...[
                Text('Current Images',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Container(
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _existingImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: _existingImages[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[800]),
                              errorWidget: (_, __, ___) => Container(
                                  width: 100, height: 100, color: Colors.grey),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _removeExistingImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
              // Show new images (from picker)
              if (_selectedImages.isNotEmpty) ...[
                Text('New Images',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Container(
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _selectedImages[index].path,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  width: 100, height: 100, color: Colors.grey),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Images'),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Product Name *'),
                      style: const TextStyle(color: AppColors.textPrimary),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Product name is required';
                        }
                        if (v.trim().length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _brandCtrl,
                      decoration: const InputDecoration(labelText: 'Brand *'),
                      style: const TextStyle(color: AppColors.textPrimary),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Brand is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Price *', prefixText: '\$ '),
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Price is required';
                        }
                        final price = double.tryParse(v);
                        if (price == null || price <= 0) {
                          return 'Enter a valid price greater than 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      decoration: const InputDecoration(labelText: 'Stock *'),
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Stock is required';
                        }
                        final stock = int.tryParse(v);
                        if (stock == null || stock < 0) {
                          return 'Enter a valid stock quantity';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<AdminCategoryProvider>(
                builder: (context, categoryProvider, _) {
                  final categories = categoryProvider.categories
                      .map((c) => c['name'] as String)
                      .toList();

                  // Ensure _category exists in the list, if not add it or pick first
                  if (categories.isNotEmpty &&
                      !categories.contains(_category)) {
                    _category = categories.first;
                  }

                  return DropdownButtonFormField<String>(
                    value: categories.contains(_category) ? _category : null,
                    dropdownColor: AppColors.surfaceColor,
                    menuMaxHeight: 300,
                    decoration: const InputDecoration(labelText: 'Category'),
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Description with template button
              Row(
                children: [
                  Text('Description', style: AppTextStyles.labelMedium),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      _descCtrl.text =
                          '''A stunning luxury timepiece that combines elegant design with exceptional craftsmanship. This watch features a premium quality build with attention to every detail.

Key Features:
• Swiss-made automatic movement
• Scratch-resistant sapphire crystal
• Premium leather/stainless steel strap
• Luminous hands and hour markers
• Date display at 3 o'clock position

Perfect for both formal occasions and everyday wear, this watch is a statement of refined taste and sophisticated style.''';
                      setState(() {});
                    },
                    icon: const Icon(Icons.auto_fix_high, size: 16),
                    label: const Text('Use Template'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryGold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter product description...',
                ),
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              // Specifications with template button
              Row(
                children: [
                  Text('Specifications', style: AppTextStyles.labelMedium),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      _specsCtrl.text = '''Movement: Automatic
Case Material: Stainless Steel
Case Size: 42mm
Dial Color: Black
Strap Material: Genuine Leather
Water Resistance: 100m (10 ATM)
Crystal: Sapphire
Power Reserve: 40 hours
Warranty: 2 Years International''';
                      setState(() {});
                    },
                    icon: const Icon(Icons.auto_fix_high, size: 16),
                    label: const Text('Use Template'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryGold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _specsCtrl,
                decoration: const InputDecoration(
                  hintText:
                      'Movement: Automatic\nCase Size: 42mm\nWater Resistance: 100m',
                  hintStyle: TextStyle(fontSize: 12),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 6,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _save,
                    child: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(isEdit ? 'Update' : 'Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    final provider = context.read<AdminProductProvider>();
    final name = _nameCtrl.text;
    final brand = _brandCtrl.text;
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final stock = int.tryParse(_stockCtrl.text) ?? 0;
    final desc = _descCtrl.text;

    // Parse specifications from text input
    final specsMap = <String, String>{};
    if (_specsCtrl.text.isNotEmpty) {
      for (var line in _specsCtrl.text.split('\n')) {
        final parts = line.split(':');
        if (parts.length == 2) {
          specsMap[parts[0].trim()] = parts[1].trim();
        }
      }
    }

    bool success;
    if (widget.product != null) {
      // Update - include existing images array and any new images
      success = await provider.updateProduct(
        id: widget.product!['id'],
        data: {
          'name': name,
          'brand': brand,
          'price': price,
          'stock': stock,
          'description': desc,
          'category': _category,
          'specifications': specsMap,
          'images':
              _existingImages, // Pass existing (possibly modified) images list
        },
        newImages: _selectedImages.isNotEmpty ? _selectedImages : null,
      );
    } else {
      success = await provider.addProduct(
        name: name,
        brand: brand,
        price: price,
        stock: stock,
        description: desc,
        category: _category,
        images: _selectedImages,
        specs: specsMap,
      );
    }

    if (mounted) {
      setState(() => _isUploading = false);
      if (success) {
        Navigator.pop(context);
        AdminHelpers.showSuccessSnackbar(context,
            widget.product != null ? 'Product updated' : 'Product created');
      } else {
        AdminHelpers.showErrorSnackbar(context, 'Operation failed');
      }
    }
  }
}
