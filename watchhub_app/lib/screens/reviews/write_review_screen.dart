// =============================================================================
// FILE: write_review_screen.dart
// PURPOSE: Write review screen for WatchHub
// DESCRIPTION: Allows users to submit product reviews with ratings.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_crud_service.dart';
import '../../models/review_model.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_button.dart';
import '../../services/admin_notification_service.dart';

class WriteReviewScreen extends StatefulWidget {
  final String productId;

  const WriteReviewScreen({super.key, required this.productId});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  final FirestoreCrudService _firestoreService = FirestoreCrudService();

  double _rating = 5.0;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      Helpers.showErrorSnackbar(context, 'Please select a rating');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      final review = ReviewModel(
        id: '',
        productId: widget.productId,
        userId: authProvider.uid!,
        userName: authProvider.user?.name ?? 'Anonymous',
        rating: _rating,
        title: _titleController.text.trim(),
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _firestoreService.addReview(review);

      // Notify admin panel
      // Get product name for notification
      final product = await _firestoreService.getProduct(widget.productId);
      await AdminNotificationService.notifyReview(
        userName: review.userName,
        productName: product?.name ?? 'Product',
        rating: review.rating.toInt(),
        comment: review.comment,
      );

      if (mounted) {
        Helpers.showSuccessSnackbar(context, 'Review submitted successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error submitting review: $e');
      if (mounted) {
        Helpers.showErrorSnackbar(context, 'Failed to submit review');
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        title: Text('Write Review', style: AppTextStyles.appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating
              Text('Your Rating', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              Center(
                child: RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 40,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star_rounded,
                    color: AppColors.ratingColor,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() => _rating = rating);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _getRatingText(_rating),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Review form
              GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _titleController,
                      label: 'Review Title (Optional)',
                      hint: 'Summarize your review',
                      maxLines: 1,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _commentController,
                      label: 'Your Review',
                      hint: 'Share your experience with this product...',
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please write your review';
                        }
                        if (value.length < 10) {
                          return 'Review must be at least 10 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              LoadingButton(
                onPressed: _submitReview,
                isLoading: _isLoading,
                text: 'Submit Review',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 5) return 'Excellent!';
    if (rating >= 4) return 'Very Good';
    if (rating >= 3) return 'Good';
    if (rating >= 2) return 'Fair';
    return 'Poor';
  }
}
