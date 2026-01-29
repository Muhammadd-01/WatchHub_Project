// =============================================================================
// FILE: faq_model.dart
// PURPOSE: Data model for FAQs in WatchHub
// DESCRIPTION: Represents an FAQ entry with question and answer.
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// FAQ model
class FAQModel {
  final String id;
  final String question;
  final String answer;
  final int order;

  FAQModel({
    required this.id,
    required this.question,
    required this.answer,
    this.order = 0,
  });

  /// Creates an FAQModel from Firestore document
  factory FAQModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FAQModel(
      id: doc.id,
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      order: data['order'] ?? 0,
    );
  }

  /// Converts FAQModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'order': order,
    };
  }
}
