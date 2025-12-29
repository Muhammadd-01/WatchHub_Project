// =============================================================================
// FILE: order_model.dart
// PURPOSE: Order data model for WatchHub
// DESCRIPTION: Represents a customer order with items, shipping info, and status.
//              Orders are stored at orders/{orderId} and linked via userId (UID).
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_model.dart';

/// Shipping address for an order
class ShippingAddress {
  final String fullName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phone;

  ShippingAddress({
    required this.fullName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phone,
  });

  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      fullName: map['fullName'] ?? '',
      addressLine1: map['addressLine1'] ?? '',
      addressLine2: map['addressLine2'],
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      postalCode: map['postalCode'] ?? '',
      country: map['country'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
    };
  }

  /// Formatted address string
  String get formatted {
    final lines = [
      fullName,
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      '$city, $state $postalCode',
      country,
    ];
    return lines.join('\n');
  }

  /// Single line address
  String get singleLine {
    return '$addressLine1, $city, $state $postalCode';
  }
}

/// Order model representing a customer purchase
///
/// Stored in Firestore at: orders/{orderId}
///
/// Orders are linked to users via the userId field (Firebase Auth UID).
class OrderModel {
  /// Unique order identifier
  final String id;

  /// User's Firebase Auth UID
  final String userId;

  /// Order number for display (e.g., "WH-2025-001234")
  final String orderNumber;

  /// Items in the order
  final List<CartItemModel> items;

  /// Subtotal (items only)
  final double subtotal;

  /// Shipping cost
  final double shippingCost;

  /// Tax amount
  final double tax;

  /// Total order amount
  final double totalAmount;

  /// Order status
  final String status;

  /// Shipping address
  final ShippingAddress shippingAddress;

  /// Payment method used
  final String paymentMethod;

  /// Optional order notes
  final String? notes;

  /// Order creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Estimated delivery date
  final DateTime? estimatedDelivery;

  OrderModel({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    this.shippingCost = 0,
    this.tax = 0,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.estimatedDelivery,
  });

  // ===========================================================================
  // FIRESTORE SERIALIZATION
  // ===========================================================================

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      orderNumber: data['orderNumber'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map(
                (item) => CartItemModel.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      shippingCost: (data['shippingCost'] ?? 0).toDouble(),
      tax: (data['tax'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      shippingAddress: ShippingAddress.fromMap(data['shippingAddress'] ?? {}),
      paymentMethod: data['paymentMethod'] ?? '',
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      estimatedDelivery: (data['estimatedDelivery'] as Timestamp?)?.toDate(),
    );
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      orderNumber: map['orderNumber'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map(
                (item) => CartItemModel.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      shippingCost: (map['shippingCost'] ?? 0).toDouble(),
      tax: (map['tax'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      shippingAddress: ShippingAddress.fromMap(map['shippingAddress'] ?? {}),
      paymentMethod: map['paymentMethod'] ?? '',
      notes: map['notes'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] as DateTime?) ?? DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : map['updatedAt'] as DateTime?,
      estimatedDelivery: map['estimatedDelivery'] is Timestamp
          ? (map['estimatedDelivery'] as Timestamp).toDate()
          : map['estimatedDelivery'] as DateTime?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'orderNumber': orderNumber,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'tax': tax,
      'totalAmount': totalAmount,
      'status': status,
      'shippingAddress': shippingAddress.toMap(),
      'paymentMethod': paymentMethod,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'estimatedDelivery': estimatedDelivery != null
          ? Timestamp.fromDate(estimatedDelivery!)
          : null,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'orderNumber': orderNumber,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'tax': tax,
      'totalAmount': totalAmount,
      'status': status,
      'shippingAddress': shippingAddress.toMap(),
      'paymentMethod': paymentMethod,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'estimatedDelivery': estimatedDelivery,
    };
  }

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  OrderModel copyWith({
    String? id,
    String? userId,
    String? orderNumber,
    List<CartItemModel>? items,
    double? subtotal,
    double? shippingCost,
    double? tax,
    double? totalAmount,
    String? status,
    ShippingAddress? shippingAddress,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? estimatedDelivery,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      tax: tax ?? this.tax,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
    );
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Total number of items in order
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Whether order can be cancelled
  bool get canCancel {
    return status == 'pending' || status == 'confirmed';
  }

  /// Whether order is complete
  bool get isComplete {
    return status == 'delivered' || status == 'cancelled';
  }

  /// Whether order is in progress
  bool get isInProgress {
    return !isComplete;
  }

  /// Status display text
  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // ===========================================================================
  // EQUALITY & STRING
  // ===========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Total order amount (alias for totalAmount)
  double get total => totalAmount;

  /// Tax amount (alias for tax)
  double get taxAmount => tax;

  @override
  String toString() {
    return 'OrderModel(id: $id, orderNumber: $orderNumber, status: $status)';
  }
}
