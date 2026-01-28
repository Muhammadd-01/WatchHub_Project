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

class WishlistsScreen extends StatelessWidget {
  const WishlistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'User Wishlists',
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        // Use collectionGroup without orderBy to avoid index requirement
        // Sort client-side after fetching
        stream: FirebaseFirestore.instance
            .collectionGroup('items')
            .snapshots()
            .map((snapshot) {
          final docs = snapshot.docs.toList();
          docs.sort((a, b) {
            final aTime =
                (a.data()['addedAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
            final bTime =
                (b.data()['addedAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
            return bTime.compareTo(aTime);
          });
          return docs;
        }),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading wishlists: ${snapshot.error}',
                  style: TextStyle(color: AppColors.error)),
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
                  Icon(Icons.favorite_border,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('No wishlist items', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Text(
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
              // Extract userId from the document path: wishlists/{userId}/items/{productId}
              final pathParts = doc.reference.path.split('/');
              final userId = pathParts.length >= 2 ? pathParts[1] : 'Unknown';
              return _buildWishlistCard(context, data, userId);
            },
          );
        },
      ),
    );
  }

  Widget _buildWishlistCard(
      BuildContext context, Map<String, dynamic> data, String userId) {
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
          return Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
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
        final userEmail = userData?['email'] ?? '';
        final productName = productData?['name'] ?? 'Unknown Product';
        final productBrand = productData?['brand'] ?? '';
        final productImage = productData?['imageUrl'] ?? '';
        final productStock = productData?['stock'] ?? 0;
        final isOutOfStock = productStock <= 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
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

              // Product and user info
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
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          userName,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        if (userEmail.isNotEmpty) ...[
                          Text(
                            ' • $userEmail',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.favorite, color: AppColors.error, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
