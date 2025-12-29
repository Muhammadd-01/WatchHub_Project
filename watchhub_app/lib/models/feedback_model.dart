// =============================================================================
// FILE: feedback_model.dart
// PURPOSE: Feedback data model for WatchHub
// DESCRIPTION: Represents user feedback submitted through the app.
//              Feedback is stored at feedbacks/{feedbackId}
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents user feedback submitted through the app
///
/// Stored in Firestore at: feedbacks/{feedbackId}
///
/// Feedback is linked to users via the userId field (Firebase Auth UID).
class FeedbackModel {
  /// Unique feedback identifier
  final String id;

  /// User's Firebase Auth UID
  final String userId;

  /// User's email (for follow-up)
  final String userEmail;

  /// User's name
  final String userName;

  /// Feedback subject/category
  final String subject;

  /// Feedback message
  final String message;

  /// Feedback type (suggestion, bug, complaint, other)
  final String type;

  /// Submission timestamp
  final DateTime createdAt;

  /// Whether the feedback has been read by admin
  final bool isRead;

  /// Whether the feedback has been responded to
  final bool isResolved;

  /// Admin response (if any)
  final String? response;

  /// Response timestamp
  final DateTime? respondedAt;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.subject,
    required this.message,
    this.type = 'general',
    required this.createdAt,
    this.isRead = false,
    this.isResolved = false,
    this.response,
    this.respondedAt,
  });

  // ===========================================================================
  // FIRESTORE SERIALIZATION
  // ===========================================================================

  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FeedbackModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      subject: data['subject'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'general',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      isResolved: data['isResolved'] ?? false,
      response: data['response'],
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userName: map['userName'] ?? '',
      subject: map['subject'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'general',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] as DateTime?) ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      isResolved: map['isResolved'] ?? false,
      response: map['response'],
      respondedAt: map['respondedAt'] is Timestamp
          ? (map['respondedAt'] as Timestamp).toDate()
          : map['respondedAt'] as DateTime?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'subject': subject,
      'message': message,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'isResolved': isResolved,
      'response': response,
      'respondedAt': respondedAt != null
          ? Timestamp.fromDate(respondedAt!)
          : null,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'subject': subject,
      'message': message,
      'type': type,
      'createdAt': createdAt,
      'isRead': isRead,
      'isResolved': isResolved,
      'response': response,
      'respondedAt': respondedAt,
    };
  }

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  FeedbackModel copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? userName,
    String? subject,
    String? message,
    String? type,
    DateTime? createdAt,
    bool? isRead,
    bool? isResolved,
    String? response,
    DateTime? respondedAt,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isResolved: isResolved ?? this.isResolved,
      response: response ?? this.response,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Status text
  String get status {
    if (isResolved) return 'Resolved';
    if (isRead) return 'Under Review';
    return 'Pending';
  }

  /// Type display text
  String get typeDisplayText {
    switch (type) {
      case 'suggestion':
        return 'Suggestion';
      case 'bug':
        return 'Bug Report';
      case 'complaint':
        return 'Complaint';
      case 'question':
        return 'Question';
      default:
        return 'General';
    }
  }

  // ===========================================================================
  // STATIC FEEDBACK TYPES
  // ===========================================================================

  static const List<String> feedbackTypes = [
    'general',
    'suggestion',
    'bug',
    'complaint',
    'question',
  ];

  static const Map<String, String> feedbackTypeLabels = {
    'general': 'General Feedback',
    'suggestion': 'Suggestion',
    'bug': 'Bug Report',
    'complaint': 'Complaint',
    'question': 'Question',
  };

  // ===========================================================================
  // EQUALITY & STRING
  // ===========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedbackModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FeedbackModel(id: $id, subject: $subject, type: $type)';
  }
}
