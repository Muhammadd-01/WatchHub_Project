// =============================================================================
// FILE: review_model.dart
// PURPOSE: Review data model for WatchHub
// DESCRIPTION: Represents a product review with rating and comment.
//              Reviews are stored at products/{productId}/reviews/{reviewId}
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a product review
///
/// Stored in Firestore at: products/{productId}/reviews/{reviewId}
///
/// Reviews are linked to users via the userId field (Firebase Auth UID).
/// Only authenticated users can create reviews.
class ReviewModel {
  /// Unique review identifier
  final String id;

  /// Product ID this review belongs to
  final String productId;

  /// Reviewer's Firebase Auth UID
  final String userId;

  /// Reviewer's display name
  final String userName;

  /// Reviewer's profile image URL (optional)
  final String? userImageUrl;

  /// Rating (1-5 stars)
  final double rating;

  /// Review title
  final String title;

  /// Review comment
  final String comment;

  /// Creation date
  final DateTime createdAt;

  /// Whether the review has been edited
  final bool isEdited;

  /// Last edit date
  final DateTime? editedAt;

  /// Number of helpful votes
  final int helpfulCount;

  /// Admin reply to the review
  final String? adminReply;

  /// When admin replied
  final DateTime? adminReplyAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.rating,
    this.title = '',
    required this.comment,
    required this.createdAt,
    this.isEdited = false,
    this.editedAt,
    this.helpfulCount = 0,
    this.adminReply,
    this.adminReplyAt,
  });

  // ===========================================================================
  // FIRESTORE SERIALIZATION
  // ===========================================================================

  factory ReviewModel.fromFirestore(DocumentSnapshot doc, String productId) {
    final data = doc.data() as Map<String, dynamic>;

    return ReviewModel(
      id: doc.id,
      productId: productId,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userImageUrl: data['userImageUrl'],
      rating: (data['rating'] ?? 0).toDouble(),
      title: data['title'] ?? '',
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isEdited: data['isEdited'] ?? false,
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
      helpfulCount: data['helpfulCount'] ?? 0,
      adminReply: data['adminReply'],
      adminReplyAt: (data['adminReplyAt'] as Timestamp?)?.toDate(),
    );
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      userImageUrl: map['userImageUrl'],
      rating: (map['rating'] ?? 0).toDouble(),
      title: map['title'] ?? '',
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] as DateTime?) ?? DateTime.now(),
      isEdited: map['isEdited'] ?? false,
      editedAt: map['editedAt'] is Timestamp
          ? (map['editedAt'] as Timestamp).toDate()
          : map['editedAt'] as DateTime?,
      helpfulCount: map['helpfulCount'] ?? 0,
      adminReply: map['adminReply'],
      adminReplyAt: map['adminReplyAt'] is Timestamp
          ? (map['adminReplyAt'] as Timestamp).toDate()
          : map['adminReplyAt'] as DateTime?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'rating': rating,
      'title': title,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'helpfulCount': helpfulCount,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'rating': rating,
      'title': title,
      'comment': comment,
      'createdAt': createdAt,
      'isEdited': isEdited,
      'editedAt': editedAt,
      'helpfulCount': helpfulCount,
    };
  }

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  ReviewModel copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    String? userImageUrl,
    double? rating,
    String? title,
    String? comment,
    DateTime? createdAt,
    bool? isEdited,
    DateTime? editedAt,
    int? helpfulCount,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      helpfulCount: helpfulCount ?? this.helpfulCount,
    );
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Rating as integer stars (rounded)
  int get ratingStars => rating.round();

  /// Whether the review was made by a specific user
  bool isBy(String uid) => userId == uid;

  /// User initials for avatar fallback
  String get userInitials {
    if (userName.isEmpty) return '?';
    final parts = userName.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Rating text
  String get ratingText {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 4.0) return 'Very Good';
    if (rating >= 3.5) return 'Good';
    if (rating >= 3.0) return 'Average';
    if (rating >= 2.0) return 'Fair';
    return 'Poor';
  }

  /// Whether the user purchased the product (placeholder)
  bool get isVerifiedPurchase => false; // Implement Logic later

  // ===========================================================================
  // EQUALITY & STRING
  // ===========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReviewModel(id: $id, rating: $rating, userName: $userName)';
  }
}
