// =============================================================================
// FILE: wishlists_screen.dart
// PURPOSE: Admin Wishlists Screen
// DESCRIPTION: Shows all users' wishlist items with product and user details.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/admin_scaffold.dart';

class WishlistsScreen extends StatefulWidget {
  const WishlistsScreen({super.key});

  @override
  State<WishlistsScreen> createState() => _WishlistsScreenState();
}

class _WishlistsScreenState extends State<WishlistsScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String path) {
    setState(() {
      if (_selectedIds.contains(path)) {
        _selectedIds.remove(path);
      } else {
        _selectedIds.add(path);
      }
      if (_selectedIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _selectAll(List<QueryDocumentSnapshot> items) {
    setState(() {
      if (_selectedIds.length == items.length) {
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedIds.clear();
        for (var doc in items) {
          _selectedIds.add(doc.reference.path);
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
            'Are you sure you want to remove ${_selectedIds.length} items from wishlists?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final batch = FirebaseFirestore.instance.batch();
      for (final path in _selectedIds) {
        batch.delete(FirebaseFirestore.instance.doc(path));
      }
      await batch.commit();
      setState(() {
        _selectedIds.clear();
        _isSelectionMode = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Items removed from wishlists')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: _isSelectionMode
          ? '${_selectedIds.length} Selected'
          : 'User Wishlists',
      actions: [
        if (_isSelectionMode) ...[
          StreamBuilder<List<QueryDocumentSnapshot>>(
            stream: FirebaseFirestore.instance
                .collectionGroup('items')
                .snapshots()
                .map((snapshot) {
              return snapshot.docs
                  .where((doc) => doc.reference.path.contains('wishlists'))
                  .toList();
            }),
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              return IconButton(
                onPressed: () => _selectAll(items),
                icon: Icon(
                  _selectedIds.length == items.length
                      ? Icons.deselect
                      : Icons.select_all,
                  size: 22,
                ),
                tooltip: _selectedIds.length == items.length
                    ? 'Deselect All'
                    : 'Select All',
                color: AppColors.primaryGold,
              );
            },
          ),
          IconButton(
            onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
            icon: const Icon(Icons.delete_sweep, size: 22),
            tooltip: 'Delete Selected',
            color: _selectedIds.isEmpty
                ? AppColors.textSecondary
                : AppColors.error,
          ),
          IconButton(
            onPressed: _toggleSelectionMode,
            icon: const Icon(Icons.close, size: 22),
            tooltip: 'Cancel',
            color: AppColors.error,
          ),
        ] else ...[
          IconButton(
            onPressed: _toggleSelectionMode,
            icon: const Icon(Icons.checklist, size: 20),
            tooltip: 'Select Multiple',
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
        ],
      ],
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: FirebaseFirestore.instance
            .collectionGroup('items')
            .snapshots()
            .map((snapshot) {
          final docs = snapshot.docs
              .where((doc) => doc.reference.path.contains('wishlists'))
              .toList();
          docs.sort((a, b) {
            final aData = a.data();
            final bData = b.data();
            final aTime = aData['addedAt'] as Timestamp?;
            final bTime = bData['addedAt'] as Timestamp?;
            return (bTime ?? Timestamp.now())
                .compareTo(aTime ?? Timestamp.now());
          });
          return docs;
        }),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading wishlists: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.error)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            );
          }

          final wishlists = snapshot.data ?? [];

          if (wishlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('No wishlist items', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  const Text(
                    'Users have not added items to wishlists yet',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wishlists.length,
            itemBuilder: (context, index) {
              final doc = wishlists[index];
              final data = doc.data() as Map<String, dynamic>;
              final path = doc.reference.path;
              final isSelected = _selectedIds.contains(path);

              final pathParts = path.split('/');
              final userId = pathParts.length >= 2 ? pathParts[1] : 'Unknown';

              return GestureDetector(
                onLongPress: () {
                  if (!_isSelectionMode) {
                    _toggleSelectionMode();
                    _toggleSelection(path);
                  }
                },
                onTap: _isSelectionMode ? () => _toggleSelection(path) : null,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGold.withOpacity(0.1)
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGold
                          : AppColors.cardBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_isSelectionMode)
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggleSelection(path),
                            activeColor: AppColors.primaryGold,
                          ),
                        ),
                      Expanded(
                        child:
                            _buildWishlistContent(context, data, userId, path),
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

  Widget _buildWishlistContent(BuildContext context, Map<String, dynamic> data,
      String userId, String path) {
    final productId = data['productId'] ?? '';
    final addedAt = data['addedAt'] as Timestamp?;
    final dateStr = addedAt != null
        ? DateFormat('MMM dd, yyyy').format(addedAt.toDate())
        : 'Unknown';

    return FutureBuilder<List<DocumentSnapshot>>(
      future: Future.wait([
        FirebaseFirestore.instance.collection('users').doc(userId).get(),
        FirebaseFirestore.instance.collection('products').doc(productId).get(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 60,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryGold,
              ),
            ),
          );
        }

        final userData = snapshot.data![0].data() as Map<String, dynamic>?;
        final productData = snapshot.data![1].data() as Map<String, dynamic>?;

        final userName = userData?['name'] ?? 'Unknown User';
        final productName = productData?['name'] ?? 'Unknown Product';
        final productBrand = productData?['brand'] ?? '';
        final productImage = productData?['imageUrl'] ?? '';
        final productStock = productData?['stock'] ?? 0;
        final isOutOfStock = productStock <= 0;

        return Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: productImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: productImage,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 60,
                        height: 60,
                        color: AppColors.surfaceColor,
                        child: const Icon(Icons.watch,
                            color: AppColors.textTertiary),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: AppColors.surfaceColor,
                        child: const Icon(Icons.watch,
                            color: AppColors.textTertiary),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: AppColors.surfaceColor,
                      child: const Icon(Icons.watch,
                          color: AppColors.textTertiary),
                    ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          productName,
                          style: AppTextStyles.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isOutOfStock)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'OUT OF STOCK',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (productBrand.isNotEmpty)
                    Text(
                      productBrand.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Date & Delete
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!_isSelectionMode)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    onPressed: () => _deleteItem(path),
                  )
                else
                  const Icon(Icons.favorite, color: AppColors.error, size: 20),
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(String path) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Wishlist Item?'),
        content: const Text('Are you sure you want to remove this item?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance.doc(path).delete();
    }
  }
}
