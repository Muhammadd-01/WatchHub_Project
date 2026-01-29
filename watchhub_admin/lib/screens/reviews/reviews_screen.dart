// =============================================================================
// FILE: reviews_screen.dart
// PURPOSE: Admin Reviews Management Screen
// DESCRIPTION: Shows all product reviews and allows admin to reply.
// =============================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/admin_helpers.dart';
import '../../widgets/admin_scaffold.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  String? _error;
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _fetchAllReviews();
  }

  Future<void> _fetchAllReviews() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch all reviews without orderBy to avoid index requirement on web
      final reviewsSnapshot = await _firestore.collectionGroup('reviews').get();

      if (reviewsSnapshot.docs.isEmpty) {
        if (!mounted) return;
        setState(() {
          _reviews = [];
          _isLoading = false;
        });
        return;
      }

      // Get unique product IDs
      final productIds = <String>{};
      for (final doc in reviewsSnapshot.docs) {
        final parentId = doc.reference.parent.parent?.id;
        if (parentId != null) productIds.add(parentId);
      }

      // Fetch products in batches of 10 (Firestore whereIn limit)
      final productsMap = <String, Map<String, dynamic>>{};
      final idsList = productIds.toList();
      for (var i = 0; i < idsList.length; i += 10) {
        final batchIds = idsList.skip(i).take(10).toList();
        final batch = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();
        for (final doc in batch.docs) {
          productsMap[doc.id] = doc.data();
        }
      }

      // Build reviews list
      final allReviews = <Map<String, dynamic>>[];
      for (final reviewDoc in reviewsSnapshot.docs) {
        final data = Map<String, dynamic>.from(reviewDoc.data());
        final productId = reviewDoc.reference.parent.parent?.id ?? '';

        data['id'] = reviewDoc.id;
        data['productId'] = productId;
        data['productName'] =
            productsMap[productId]?['name'] ?? 'Unknown Product';

        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
        } else {
          data['createdAt'] = DateTime(2000);
        }
        allReviews.add(data);
      }

      // Sort client-side by date
      allReviews.sort((a, b) {
        final dateA = a['createdAt'] as DateTime;
        final dateB = b['createdAt'] as DateTime;
        return dateB.compareTo(dateA);
      });

      if (!mounted) return;
      setState(() {
        _reviews = allReviews;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load reviews: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedIds.clear();
    });
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

  void _selectAll() {
    setState(() {
      if (_selectedIds.length == _reviews.length) {
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedIds.clear();
        for (var review in _reviews) {
          _selectedIds.add(review['id']);
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
            'Are you sure you want to delete ${_selectedIds.length} reviews? This action cannot be undone.',
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
      int successCount = 0;
      for (final id in _selectedIds.toList()) {
        final review = _reviews.firstWhere((r) => r['id'] == id);
        try {
          await _firestore
              .collection('products')
              .doc(review['productId'])
              .collection('reviews')
              .doc(id)
              .delete();
          successCount++;
        } catch (e) {
          debugPrint('Error deleting review $id: $e');
        }
      }

      setState(() {
        _selectedIds.clear();
        _isSelectionMode = false;
      });
      if (mounted) {
        AdminHelpers.showSuccessSnackbar(
            context, '$successCount reviews deleted');
        _fetchAllReviews();
      }
    }
  }

  Future<void> _deleteReview(Map<String, dynamic> review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Review',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to delete this review?',
            style: TextStyle(color: AppColors.textSecondary)),
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

    if (confirm == true) {
      try {
        await _firestore
            .collection('products')
            .doc(review['productId'])
            .collection('reviews')
            .doc(review['id'])
            .delete();
        if (mounted) {
          AdminHelpers.showSuccessSnackbar(context, 'Review deleted');
          _fetchAllReviews();
        }
      } catch (e) {
        if (mounted) {
          AdminHelpers.showErrorSnackbar(context, 'Failed to delete review');
        }
      }
    }
  }

  Future<void> _replyToReview(Map<String, dynamic> review) async {
    final controller = TextEditingController(
      text: review['adminReply'] as String? ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Reply to Review',
            style: TextStyle(color: AppColors.textPrimary)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Original review
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(review['userName'] ?? 'Anonymous',
                            style: AppTextStyles.labelLarge),
                        const Spacer(),
                        _buildRatingStars(
                            (review['rating'] as num?)?.toDouble() ?? 0),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(review['comment'] ?? '',
                        style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Reply input
              TextField(
                controller: controller,
                maxLines: 4,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Your Reply',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'Write your response...',
                  hintStyle: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.5)),
                  filled: true,
                  fillColor: AppColors.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryGold),
            child: const Text('Save Reply'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        // Save the reply
        await _firestore
            .collection('products')
            .doc(review['productId'])
            .collection('reviews')
            .doc(review['id'])
            .update({
          'adminReply': result,
          'adminReplyAt': FieldValue.serverTimestamp(),
        });

        // Send notification to the user
        final userId = review['userId'] as String?;
        if (userId != null && userId.isNotEmpty) {
          // In-app notification
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .add({
            'title': 'Reply to Your Review',
            'message':
                'WatchHub has replied to your review on ${review['productName']}',
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
            'type': 'review_reply',
            'productId': review['productId'],
          });

          // Push notification via OneSignal
          await _sendPushNotification(
            userId,
            'Reply to Your Review',
            'WatchHub has replied to your review on ${review['productName']}',
            review['productId'] as String?,
          );
        }

        AdminHelpers.showSuccessSnackbar(context, 'Reply saved successfully');
        _fetchAllReviews();
      } catch (e) {
        AdminHelpers.showErrorSnackbar(context, 'Failed to save reply');
      }
    }
  }

  /// Send push notification via OneSignal
  Future<void> _sendPushNotification(
      String uid, String title, String body, String? productId) async {
    try {
      // 1. Get User's OneSignal ID
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final playerId = userDoc.data()?['oneSignalPlayerId'];

      if (playerId == null) {
        debugPrint('ReviewsScreen: OneSignal Player ID not found for $uid');
        return;
      }

      // 2. Get API Keys from .env
      final appId = dotenv.env['ONESIGNAL_APP_ID'];
      final restApiKey = dotenv.env['ONESIGNAL_REST_API_KEY'];

      if (appId == null || restApiKey == null) {
        debugPrint('ReviewsScreen: OneSignal keys not configured');
        return;
      }

      // 3. Send Request to OneSignal REST API
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $restApiKey',
        },
        body: jsonEncode({
          'app_id': appId,
          'include_player_ids': [playerId],
          'headings': {'en': title},
          'contents': {'en': body},
          'data': {'type': 'review_reply', 'productId': productId},
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('ReviewsScreen: OneSignal Push sent successfully');
      } else {
        debugPrint('ReviewsScreen: OneSignal Push failed - ${response.body}');
      }
    } catch (e) {
      debugPrint('ReviewsScreen: Error sending push - $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: _isSelectionMode ? '${_selectedIds.length} Selected' : 'Reviews',
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            onPressed: _selectAll,
            icon: Icon(
              _selectedIds.length == _reviews.length
                  ? Icons.deselect
                  : Icons.select_all,
              size: 22,
            ),
            tooltip: _selectedIds.length == _reviews.length
                ? 'Deselect All'
                : 'Select All',
            color: AppColors.primaryGold,
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
            icon: const Icon(Icons.checklist, size: 22),
            tooltip: 'Select Multiple',
            color: AppColors.textSecondary,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryGold),
            onPressed: _fetchAllReviews,
          ),
        ],
      ],
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold));
    }

    if (_error != null) {
      return Center(
          child: Text(_error!, style: const TextStyle(color: AppColors.error)));
    }

    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined,
                size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No reviews yet', style: AppTextStyles.titleMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        final isSelected = _selectedIds.contains(review['id']);
        return GestureDetector(
          onLongPress: () {
            if (!_isSelectionMode) {
              _toggleSelectionMode();
              _toggleSelection(review['id']);
            }
          },
          onTap: _isSelectionMode ? () => _toggleSelection(review['id']) : null,
          child: _buildReviewCard(review, isSelected),
        );
      },
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, bool isSelected) {
    final date = review['createdAt'] as DateTime?;
    final hasReply = (review['adminReply'] as String?)?.isNotEmpty ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryGold.withOpacity(0.1)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryGold : AppColors.divider,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isSelectionMode)
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 2),
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleSelection(review['id']),
                activeColor: AppColors.primaryGold,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Product name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review['productName'] ?? 'Unknown Product',
                            style: AppTextStyles.titleSmall
                                .copyWith(color: AppColors.primaryGold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'by ${review['userName'] ?? 'Anonymous'}',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    // Rating
                    _buildRatingStars(
                        (review['rating'] as num?)?.toDouble() ?? 0),
                  ],
                ),
                const SizedBox(height: 12),

                // Comment
                Text(
                  review['comment'] ?? '',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 8),

                // Date
                Text(
                  date != null
                      ? DateFormat('MMM d, yyyy').format(date)
                      : 'Unknown date',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary),
                ),

                // Admin reply
                if (hasReply) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.primaryGold.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.reply,
                            color: AppColors.primaryGold, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Admin Reply',
                                  style: AppTextStyles.labelSmall
                                      .copyWith(color: AppColors.primaryGold)),
                              const SizedBox(height: 4),
                              Text(review['adminReply'],
                                  style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Actions
                if (!_isSelectionMode) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _deleteReview(review),
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: AppColors.error),
                        label: const Text('Delete',
                            style: TextStyle(color: AppColors.error)),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _replyToReview(review),
                        icon: Icon(
                          hasReply ? Icons.edit : Icons.reply,
                          size: 18,
                          color: AppColors.primaryGold,
                        ),
                        label: Text(
                          hasReply ? 'Edit Reply' : 'Reply',
                          style: const TextStyle(color: AppColors.primaryGold),
                        ),
                      ),
                    ],
                  ),
                ], // if (!_isSelectionMode) ...[
              ], // Column children
            ), // Column
          ), // Expanded
        ], // Row (main) children
      ), // Row (main)
    ); // Container
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: AppColors.primaryGold, size: 16);
        } else if (index < rating) {
          return const Icon(Icons.star_half,
              color: AppColors.primaryGold, size: 16);
        } else {
          return Icon(Icons.star_border,
              color: AppColors.primaryGold.withOpacity(0.3), size: 16);
        }
      }),
    );
  }
}
