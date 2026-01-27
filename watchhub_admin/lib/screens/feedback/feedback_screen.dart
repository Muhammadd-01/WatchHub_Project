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
                child: ExpansionTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceColor,
                    child: Icon(Icons.comment, color: AppColors.primaryGold),
                  ),
                  title: Text(fb['userName'] ?? 'Anonymous',
                      style: AppTextStyles.titleSmall
                          .copyWith(color: AppColors.textPrimary)),
                  subtitle: Text(fb['userEmail'] ?? 'No email',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                  childrenPadding: const EdgeInsets.all(16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (fb['subject'] != null) ...[
                            Text('Subject: ${fb['subject']}',
                                style: AppTextStyles.titleSmall.copyWith(
                                    color: AppColors.primaryGold,
                                    fontSize: 14)),
                            const SizedBox(height: 8),
                          ],
                          if (fb['type'] != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                fb['type'].toString().toUpperCase(),
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: AppColors.primaryGold),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(fb['message'] ?? fb['comment'] ?? '',
                              style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sent on: ${fb['createdAt'] != null ? fb['createdAt'].toDate().toString().substring(0, 16) : 'Unknown'}',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                              if (fb['isResolved'] == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'RESOLVED',
                                    style: AppTextStyles.labelSmall
                                        .copyWith(color: AppColors.success),
                                  ),
                                )
                              else
                                ElevatedButton(
                                  onPressed: () async {
                                    final success = await context
                                        .read<AdminFeedbackProvider>()
                                        .resolveFeedback(fb['id']);
                                    if (success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Feedback marked as resolved')));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGold,
                                    foregroundColor:
                                        AppColors.scaffoldBackground,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('Mark Resolved',
                                      style: TextStyle(fontSize: 12)),
                                ),
                            ],
                          ),
                        ],
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
}
