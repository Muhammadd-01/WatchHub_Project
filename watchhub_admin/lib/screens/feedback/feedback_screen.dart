// =============================================================================
// FILE: feedback_screen.dart
// PURPOSE: View User Feedback
// DESCRIPTION: List user feedback/reviews.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/admin_scaffold.dart';
import '../../providers/admin_feedback_provider.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminFeedbackProvider>().fetchFeedbacks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Feedback',
      body: Consumer<AdminFeedbackProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading)
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold));

          if (provider.feedbacks.isEmpty) {
            return const Center(child: Text('No feedback received yet.'));
          }

          return ListView.separated(
            itemCount: provider.feedbacks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final fb = provider.feedbacks[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceColor,
                    child: Icon(Icons.comment, color: AppColors.primaryGold),
                  ),
                  title: Text(fb['userName'] ?? 'Anonymous',
                      style: AppTextStyles.titleSmall),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(fb['message'] ?? fb['comment'] ?? '',
                          style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 4),
                      if (fb['rating'] != null)
                        Row(
                          children: List.generate(
                              5,
                              (i) => Icon(
                                    i < (fb['rating'] as num)
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: AppColors.primaryGold,
                                  )),
                        ),
                    ],
                  ),
                  trailing: Text(
                    fb['createdAt'] != null
                        ? fb['createdAt'].toDate().toString().substring(0, 10)
                        : '',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
