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
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminFeedbackProvider>().fetchFeedbacks();
    });
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

  void _selectAll(List<Map<String, dynamic>> feedbacks) {
    setState(() {
      if (_selectedIds.length == feedbacks.length) {
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedIds.clear();
        for (var fb in feedbacks) {
          _selectedIds.add(fb['id']);
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
            'Are you sure you want to delete ${_selectedIds.length} feedback entries?',
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
      final provider = context.read<AdminFeedbackProvider>();
      int successCount = 0;
      for (final id in _selectedIds.toList()) {
        final success = await provider.deleteFeedback(id);
        if (success) successCount++;
      }
      setState(() {
        _selectedIds.clear();
        _isSelectionMode = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$successCount entries deleted')),
        );
      }
    }
  }

  Future<void> _markSelectedAsResolved() async {
    if (_selectedIds.isEmpty) return;

    final provider = context.read<AdminFeedbackProvider>();
    int successCount = 0;
    for (final id in _selectedIds.toList()) {
      final success = await provider.resolveFeedback(id);
      if (success) successCount++;
    }
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$successCount entries marked as resolved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: _isSelectionMode ? '${_selectedIds.length} Selected' : 'Feedback',
      actions: [
        if (_isSelectionMode) ...[
          Consumer<AdminFeedbackProvider>(
            builder: (context, provider, _) => IconButton(
              onPressed: () => _selectAll(provider.feedbacks),
              icon: Icon(
                _selectedIds.length == provider.feedbacks.length
                    ? Icons.deselect
                    : Icons.select_all,
                size: 22,
              ),
              tooltip: _selectedIds.length == provider.feedbacks.length
                  ? 'Deselect All'
                  : 'Select All',
              color: AppColors.primaryGold,
            ),
          ),
          IconButton(
            onPressed: _selectedIds.isEmpty ? null : _markSelectedAsResolved,
            icon: const Icon(Icons.check_circle_outline, size: 22),
            tooltip: 'Mark Selected as Resolved',
            color: _selectedIds.isEmpty
                ? AppColors.textSecondary
                : AppColors.success,
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
          IconButton(
            onPressed: () =>
                context.read<AdminFeedbackProvider>().fetchFeedbacks(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ],
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
              final isSelected = _selectedIds.contains(fb['id']);
              return GestureDetector(
                onLongPress: () {
                  if (!_isSelectionMode) {
                    _toggleSelectionMode();
                    _toggleSelection(fb['id']);
                  }
                },
                onTap:
                    _isSelectionMode ? () => _toggleSelection(fb['id']) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGold.withOpacity(0.1)
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isSelected
                            ? AppColors.primaryGold
                            : AppColors.divider,
                        width: isSelected ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      if (_isSelectionMode)
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggleSelection(fb['id']),
                            activeColor: AppColors.primaryGold,
                          ),
                        ),
                      Expanded(
                        child: ExpansionTile(
                          leading: !isSelected
                              ? const CircleAvatar(
                                  backgroundColor: AppColors.surfaceColor,
                                  child: Icon(Icons.comment,
                                      color: AppColors.primaryGold),
                                )
                              : null,
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
                                        style: AppTextStyles.titleSmall
                                            .copyWith(
                                                color: AppColors.primaryGold,
                                                fontSize: 14)),
                                    const SizedBox(height: 8),
                                  ],
                                  if (fb['type'] != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGold
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        fb['type'].toString().toUpperCase(),
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                                color: AppColors.primaryGold),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Sent on: ${fb['createdAt'] != null ? fb['createdAt'].toDate().toString().substring(0, 16) : 'Unknown'}',
                                        style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.textSecondary),
                                      ),
                                      if (fb['isResolved'] == true)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.success
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'RESOLVED',
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                                    color: AppColors.success),
                                          ),
                                        )
                                      else if (!_isSelectionMode)
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
                                            backgroundColor:
                                                AppColors.primaryGold,
                                            foregroundColor:
                                                AppColors.scaffoldBackground,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: const Text('Mark Resolved',
                                              style: TextStyle(fontSize: 12)),
                                        ),
                                    ],
                                  ),
                                  if (!_isSelectionMode) ...[
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: () async {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor:
                                                  AppColors.cardBackground,
                                              title:
                                                  const Text('Delete Feedback'),
                                              content:
                                                  const Text('Are you sure?'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, false),
                                                    child:
                                                        const Text('Cancel')),
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, true),
                                                    child: const Text('Delete',
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .error))),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await provider
                                                .deleteFeedback(fb['id']);
                                          }
                                        },
                                        icon: const Icon(Icons.delete_outline,
                                            size: 16, color: AppColors.error),
                                        label: const Text('Delete',
                                            style: TextStyle(
                                                color: AppColors.error,
                                                fontSize: 12)),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
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
}
