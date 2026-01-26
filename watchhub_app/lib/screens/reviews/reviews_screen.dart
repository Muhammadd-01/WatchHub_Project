// =============================================================================
// FILE: reviews_screen.dart
// PURPOSE: Product reviews screen for WatchHub
// DESCRIPTION: Displays product reviews with sorting options.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';
import '../../services/firestore_crud_service.dart';
import '../../models/review_model.dart';

class ReviewsScreen extends StatefulWidget {
  final String productId;

  const ReviewsScreen({super.key, required this.productId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final FirestoreCrudService _firestoreService = FirestoreCrudService();
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);

    try {
      _reviews = await _firestoreService.getReviews(
        widget.productId,
        sortBy: _sortBy,
      );
    } catch (e) {
      debugPrint('Error loading reviews: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _markHelpful(ReviewModel review) async {
    try {
      await _firestoreService.incrementHelpfulCount(
        widget.productId,
        review.id,
      );
    } catch (e) {
      debugPrint('Error marking helpful: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Reviews',
            style: AppTextStyles.appBarTitle.copyWith(
              color: Theme.of(context).textTheme.titleLarge?.color,
            )),
        leading: const BackButton(),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: (value) {
              setState(() => _sortBy = value);
              _loadReviews();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'newest', child: Text('Newest First')),
              const PopupMenuItem(
                value: 'rating_high',
                child: Text('Highest Rated'),
              ),
              const PopupMenuItem(
                value: 'rating_low',
                child: Text('Lowest Rated'),
              ),
              const PopupMenuItem(
                value: 'helpful',
                child: Text('Most Helpful'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            )
          : _reviews.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    return _ReviewCard(
                      review: review,
                      productId: widget.productId,
                      onHelpful: () => _markHelpful(review),
                    ).animate().fadeIn(delay: (50 * index).ms);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.writeReview,
            arguments: widget.productId,
          );
        },
        backgroundColor: AppColors.primaryGold,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.edit_rounded),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: AppTextStyles.titleLarge.copyWith(
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to review this product',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.writeReview,
                arguments: widget.productId,
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Write a Review'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final ReviewModel review;
  final String productId;
  final VoidCallback onHelpful;

  const _ReviewCard({
    required this.review,
    required this.productId,
    required this.onHelpful,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _hasVotedHelpful = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGold.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    widget.review.userName.isNotEmpty
                        ? widget.review.userName[0].toUpperCase()
                        : 'U',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.review.userName,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    Text(
                      Helpers.formatRelativeTime(widget.review.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.review.isVerifiedPurchase)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Verified',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Rating
          RatingBarIndicator(
            rating: widget.review.rating,
            itemBuilder: (context, _) =>
                const Icon(Icons.star_rounded, color: AppColors.ratingColor),
            itemSize: 18,
          ),

          // Title
          if (widget.review.title.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              widget.review.title,
              style: AppTextStyles.titleSmall.copyWith(
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ],

          // Comment
          const SizedBox(height: 8),
          Text(
            widget.review.comment,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),

          // Admin Reply
          if (widget.review.adminReply != null &&
              widget.review.adminReply!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.store,
                          color: AppColors.primaryGold, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'WatchHub Response',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.review.adminReply!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Helpful
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: _hasVotedHelpful
                    ? null
                    : () {
                        setState(() => _hasVotedHelpful = true);
                        widget.onHelpful();
                      },
                icon: Icon(
                  _hasVotedHelpful ? Icons.thumb_up : Icons.thumb_up_outlined,
                  size: 16,
                  color: _hasVotedHelpful ? AppColors.primaryGold : null,
                ),
                label: Text(
                    'Helpful (${widget.review.helpfulCount + (_hasVotedHelpful ? 1 : 0)})'),
                style: TextButton.styleFrom(
                  foregroundColor: _hasVotedHelpful
                      ? AppColors.primaryGold
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
