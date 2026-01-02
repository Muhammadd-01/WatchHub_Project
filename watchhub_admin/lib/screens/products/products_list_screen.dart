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
import '../../widgets/reviews_dialog.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch products on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Products',
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            // Navigate to Add Product (Use same route with no arguments)
            // Or create a dedicated Add Screen. For now, we'll assume a dialog or new screen.
            // Let's create a placeholder route or widget for editing.
            _showAddEditProductDialog(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Product'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGold,
            foregroundColor: AppColors.scaffoldBackground,
          ),
        ),
        const SizedBox(width: 16),
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
    if (p != null) _category = p['category'] ?? 'Men';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isUploading = false;

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
              if (_selectedImages.isNotEmpty)
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
                              _selectedImages[index]
                                  .path, // For web/desktop this path works or use bytes
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
                          const InputDecoration(labelText: 'Product Name'),
                      style: const TextStyle(color: AppColors.textPrimary),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _brandCtrl,
                      decoration: const InputDecoration(labelText: 'Brand'),
                      style: const TextStyle(color: AppColors.textPrimary),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
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
                          labelText: 'Price', prefixText: '\$ '),
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                      ],
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      decoration: const InputDecoration(labelText: 'Stock'),
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: AppColors.surfaceColor,
                decoration: const InputDecoration(labelText: 'Category'),
                style: const TextStyle(color: AppColors.textPrimary),
                items: ['Men', 'Women', 'Unisex', 'Smart', 'Luxury']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 3,
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

    bool success;
    if (widget.product != null) {
      // Update
      success = await provider.updateProduct(id: widget.product!['id'], data: {
        'name': name,
        'brand': brand,
        'price': price,
        'stock': stock,
        'description': desc,
        'category': _category,
      });
      // Handle image updates separately if needed, but for now we focused on creating with images
    } else {
      success = await provider.addProduct(
        name: name,
        brand: brand,
        price: price,
        stock: stock,
        description: desc,
        category: _category,
        images: _selectedImages,
        specs: {},
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
