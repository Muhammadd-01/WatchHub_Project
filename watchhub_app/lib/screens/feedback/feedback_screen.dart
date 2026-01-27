// =============================================================================
// FILE: feedback_screen.dart
// PURPOSE: Feedback screen for WatchHub
// DESCRIPTION: Allows users to submit feedback about the app.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_crud_service.dart';
import '../../models/feedback_model.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_button.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final FirestoreCrudService _firestoreService = FirestoreCrudService();

  String _selectedType = 'general';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _feedbackTypes = [
    {
      'value': 'general',
      'label': 'General Feedback',
      'icon': Icons.chat_outlined,
    },
    {
      'value': 'bug',
      'label': 'Report a Bug',
      'icon': Icons.bug_report_outlined,
    },
    {
      'value': 'feature',
      'label': 'Feature Request',
      'icon': Icons.lightbulb_outline,
    },
    {
      'value': 'complaint',
      'label': 'Complaint',
      'icon': Icons.warning_amber_outlined,
    },
    {'value': 'other', 'label': 'Other', 'icon': Icons.more_horiz},
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      final feedback = FeedbackModel(
        id: '',
        userId: authProvider.uid!,
        userEmail: authProvider.user?.email ?? '',
        type: _selectedType,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
        createdAt: DateTime.now(),
        userName: authProvider.user?.name ?? 'User',
      );

      await _firestoreService.submitFeedback(feedback);

      if (mounted) {
        Helpers.showSuccessSnackbar(
          context,
          'Thank you! Your feedback has been submitted.',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      if (mounted) {
        Helpers.showErrorSnackbar(context, 'Failed to submit feedback');
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Send Feedback',
            style: AppTextStyles.appBarTitle.copyWith(
              color: Theme.of(context).textTheme.titleLarge?.color,
            )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro text
              Text('We value your feedback!',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  )),
              const SizedBox(height: 8),
              Text(
                'Help us improve WatchHub by sharing your thoughts, reporting issues, or suggesting new features.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 24),

              // Feedback type
              Text('Feedback Type',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  )),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _feedbackTypes.map((type) {
                  final isSelected = _selectedType == type['value'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type['value']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type['icon'] as IconData,
                            size: 18,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            type['label'] as String,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Form
              GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _subjectController,
                      label: 'Subject',
                      hint: 'Brief summary of your feedback',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a subject';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _messageController,
                      label: 'Message',
                      hint: 'Describe your feedback in detail...',
                      maxLines: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your message';
                        }
                        if (value.length < 20) {
                          return 'Message must be at least 20 characters';
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
                onPressed: _submitFeedback,
                isLoading: _isLoading,
                text: 'Submit Feedback',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
