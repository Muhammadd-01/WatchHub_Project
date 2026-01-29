// =============================================================================
// FILE: faqs_screen.dart
// PURPOSE: FAQ Management Screen for Admin Panel
// DESCRIPTION: Allows admin to add, edit, and delete FAQs.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/animated_reload_button.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  Future<void> _addOrEditFaq(
      {String? id, String? question, String? answer, int? order}) async {
    final questionController = TextEditingController(text: question);
    final answerController = TextEditingController(text: answer);
    final orderController =
        TextEditingController(text: order?.toString() ?? '0');

    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text(id == null ? 'Add FAQ' : 'Edit FAQ',
              style: AppTextStyles.titleLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(labelText: 'Question'),
                  enabled: !isSaving,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: answerController,
                  decoration: const InputDecoration(labelText: 'Answer'),
                  enabled: !isSaving,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: orderController,
                  decoration: const InputDecoration(labelText: 'Display Order'),
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (questionController.text.isEmpty ||
                          answerController.text.isEmpty) return;

                      setDialogState(() => isSaving = true);

                      try {
                        final data = {
                          'question': questionController.text,
                          'answer': answerController.text,
                          'order': int.tryParse(orderController.text) ?? 0,
                          'updatedAt': FieldValue.serverTimestamp(),
                        };

                        if (id == null) {
                          data['createdAt'] = FieldValue.serverTimestamp();
                          await _firestore.collection('faqs').add(data);
                        } else {
                          await _firestore
                              .collection('faqs')
                              .doc(id)
                              .update(data);
                        }

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('FAQ saved successfully')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          setDialogState(() => isSaving = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
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

  void _selectAll(List<QueryDocumentSnapshot> faqs) {
    setState(() {
      if (_selectedIds.length == faqs.length) {
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedIds.clear();
        for (var doc in faqs) {
          _selectedIds.add(doc.id);
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
            'Are you sure you want to delete ${_selectedIds.length} FAQs?',
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
      final batch = _firestore.batch();
      for (final id in _selectedIds) {
        batch.delete(_firestore.collection('faqs').doc(id));
      }
      await batch.commit();
      setState(() {
        _selectedIds.clear();
        _isSelectionMode = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('FAQs deleted')),
        );
      }
    }
  }

  Future<void> _deleteFaq(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete FAQ?'),
        content: const Text('Are you sure you want to delete this FAQ?'),
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
      await _firestore.collection('faqs').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: _isSelectionMode
          ? '${_selectedIds.length} Selected'
          : 'FAQ Management',
      actions: [
        if (_isSelectionMode) ...[
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('faqs').orderBy('order').snapshots(),
            builder: (context, snapshot) {
              final faqs = snapshot.data?.docs ?? [];
              return IconButton(
                onPressed: () => _selectAll(faqs),
                icon: Icon(
                  _selectedIds.length == faqs.length
                      ? Icons.deselect
                      : Icons.select_all,
                  size: 22,
                ),
                tooltip: _selectedIds.length == faqs.length
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
          AnimatedReloadButton(onPressed: () async => setState(() {})),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _addOrEditFaq(),
            icon: const Icon(Icons.add),
            label: const Text('Add FAQ'),
          ),
        ],
        const SizedBox(width: 16),
      ],
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('faqs').orderBy('order').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No FAQs found. Add some to get started!'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isSelected = _selectedIds.contains(doc.id);

              return GestureDetector(
                onLongPress: () {
                  if (!_isSelectionMode) {
                    _toggleSelectionMode();
                    _toggleSelection(doc.id);
                  }
                },
                onTap: _isSelectionMode ? () => _toggleSelection(doc.id) : null,
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isSelected
                      ? AppColors.primaryGold.withOpacity(0.1)
                      : AppColors.cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
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
                            onChanged: (_) => _toggleSelection(doc.id),
                            activeColor: AppColors.primaryGold,
                          ),
                        ),
                      Expanded(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(data['question'] ?? '',
                              style: AppTextStyles.titleMedium),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(data['answer'] ?? '',
                                style: AppTextStyles.bodyMedium),
                          ),
                          trailing: !_isSelectionMode
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          color: AppColors.primaryGold),
                                      onPressed: () => _addOrEditFaq(
                                        id: doc.id,
                                        question: data['question'],
                                        answer: data['answer'],
                                        order: data['order'],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () => _deleteFaq(doc.id),
                                    ),
                                  ],
                                )
                              : null,
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
