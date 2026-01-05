// =============================================================================
// FILE: user_model.dart
// PURPOSE: User data model for WatchHub
// DESCRIPTION: Represents a user in the application. The document ID in
//              Firestore is the Firebase Auth UID, ensuring consistent
//              user identification across all services.
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing a WatchHub user
///
/// CRITICAL: The `uid` field MUST match the Firebase Authentication UID.
/// This ensures consistent user identification across:
/// - Authentication state
/// - Firestore user documents
/// - Cart (carts/{uid})
/// - Wishlist (wishlists/{uid})
/// - Orders
/// - Reviews
/// - Feedback
class UserModel {
  /// Firebase Authentication UID - Primary identifier
  /// This is used as the document ID in Firestore: users/{uid}
  final String uid;

  /// User's full name
  final String name;

  /// User's email address (from Firebase Auth)
  final String email;

  /// User's phone number (optional)
  final String? phone;

  /// User's address (optional)
  final String? address;

  /// Supabase URL for profile image (optional)
  /// This is a public URL pointing to the image in Supabase Storage
  final String? profileImageUrl;

  /// Whether push notifications are enabled
  final bool pushNotificationsEnabled;

  /// Whether order update notifications are enabled
  final bool orderUpdatesEnabled;

  /// Account creation timestamp
  final DateTime createdAt;

  /// Last profile update timestamp
  final DateTime? updatedAt;

  /// Creates a new UserModel instance
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.profileImageUrl,
    this.pushNotificationsEnabled = true,
    this.orderUpdatesEnabled = true,
    required this.createdAt,
    this.updatedAt,
  });

  // ===========================================================================
  // FIRESTORE SERIALIZATION
  // ===========================================================================

  /// Creates a UserModel from a Firestore document snapshot
  ///
  /// This factory handles the conversion from Firestore data types
  /// (like Timestamp) to Dart types (like DateTime).
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      // Use document ID as UID (they should match)
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      address: data['address'],
      profileImageUrl: data['profileImageUrl'],
      pushNotificationsEnabled: data['pushNotificationsEnabled'] ?? true,
      orderUpdatesEnabled: data['orderUpdatesEnabled'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Creates a UserModel from a Map (useful for testing or local data)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      address: map['address'],
      profileImageUrl: map['profileImageUrl'],
      pushNotificationsEnabled: map['pushNotificationsEnabled'] ?? true,
      orderUpdatesEnabled: map['orderUpdatesEnabled'] ?? true,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] as DateTime?) ?? DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : map['updatedAt'] as DateTime?,
    );
  }

  /// Converts the UserModel to a Map for Firestore storage
  ///
  /// Note: The UID is stored in the document for easy access,
  /// even though it's also the document ID.
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'orderUpdatesEnabled': orderUpdatesEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Converts the UserModel to a Map (generic)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'orderUpdatesEnabled': orderUpdatesEnabled,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  /// Creates a copy of this UserModel with the given fields replaced
  ///
  /// This is useful for updating specific fields while keeping others.
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImageUrl,
    bool? pushNotificationsEnabled,
    bool? orderUpdatesEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      orderUpdatesEnabled: orderUpdatesEnabled ?? this.orderUpdatesEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Returns the user's initials (e.g., "John Doe" → "JD")
  String get initials {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Returns the user's first name
  String get firstName {
    if (name.isEmpty) return '';
    return name.trim().split(' ').first;
  }

  /// Checks if the user has a profile image
  bool get hasProfileImage {
    return profileImageUrl != null && profileImageUrl!.isNotEmpty;
  }

  /// Checks if the user has a phone number
  bool get hasPhone {
    return phone != null && phone!.isNotEmpty;
  }

  // ===========================================================================
  // EQUALITY & STRING
  // ===========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email)';
  }
}
