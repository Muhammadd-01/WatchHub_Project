// =============================================================================
// FILE: product_model.dart
// PURPOSE: Product data model for WatchHub
// DESCRIPTION: Represents a luxury watch product with all its attributes
//              including brand, specifications, pricing, and Supabase image URL.
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// Product model representing a luxury watch in WatchHub
///
/// Stored in Firestore at: products/{productId}
///
/// Images are stored in Supabase Storage and referenced via URL.
class ProductModel {
  /// Unique product identifier
  final String id;

  /// Watch model name (e.g., "Submariner Date")
  final String name;

  /// Watch brand (e.g., "Rolex", "Omega")
  final String brand;

  /// Detailed product description
  final String description;

  /// Price in USD
  final double price;

  /// Original price for showing discounts (optional)
  final double? originalPrice;

  /// Main product image URL from Supabase Storage
  final String imageUrl;

  /// Additional product images from Supabase (optional)
  final List<String>? additionalImages;

  /// Product category (e.g., "Luxury", "Sport", "Classic")
  final String category;

  /// Available stock quantity
  final int stock;

  /// Watch specifications (case size, movement, etc.)
  final Map<String, dynamic> specifications;

  /// Average rating (1-5)
  final double rating;

  /// Total number of reviews
  final int reviewCount;

  /// Whether the product is featured on home screen
  final bool isFeatured;

  /// Whether the product is new arrival
  final bool isNewArrival;

  /// Product creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Creates a new ProductModel instance
  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.additionalImages,
    required this.category,
    required this.stock,
    required this.specifications,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isFeatured = false,
    this.isNewArrival = false,
    required this.createdAt,
    this.updatedAt,
  });

  // ===========================================================================
  // FIRESTORE SERIALIZATION
  // ===========================================================================

  /// Creates a ProductModel from a Firestore document snapshot
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      originalPrice: data['originalPrice']?.toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      additionalImages: data['additionalImages'] != null
          ? List<String>.from(data['additionalImages'])
          : null,
      category: data['category'] ?? '',
      stock: data['stock'] ?? 0,
      specifications: Map<String, dynamic>.from(data['specifications'] ?? {}),
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isFeatured: data['isFeatured'] ?? false,
      isNewArrival: data['isNewArrival'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Creates a ProductModel from a Map
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: map['originalPrice']?.toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      additionalImages: map['additionalImages'] != null
          ? List<String>.from(map['additionalImages'])
          : null,
      category: map['category'] ?? '',
      stock: map['stock'] ?? 0,
      specifications: Map<String, dynamic>.from(map['specifications'] ?? {}),
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isFeatured: map['isFeatured'] ?? false,
      isNewArrival: map['isNewArrival'] ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] as DateTime?) ?? DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : map['updatedAt'] as DateTime?,
    );
  }

  /// Converts the ProductModel to a Map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'brand': brand,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'additionalImages': additionalImages,
      'category': category,
      'stock': stock,
      'specifications': specifications,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'isNewArrival': isNewArrival,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Converts to Map (generic)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'additionalImages': additionalImages,
      'category': category,
      'stock': stock,
      'specifications': specifications,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'isNewArrival': isNewArrival,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  ProductModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? description,
    double? price,
    double? originalPrice,
    String? imageUrl,
    List<String>? additionalImages,
    String? category,
    int? stock,
    Map<String, dynamic>? specifications,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    bool? isNewArrival,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      additionalImages: additionalImages ?? this.additionalImages,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      specifications: specifications ?? this.specifications,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isNewArrival: isNewArrival ?? this.isNewArrival,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Whether the product is in stock
  bool get isInStock => stock > 0;

  /// Whether the product is on sale (has original price higher than current)
  bool get isOnSale => originalPrice != null && originalPrice! > price;

  /// Discount percentage if on sale
  int get discountPercentage {
    if (!isOnSale) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  /// Full product name with brand
  String get fullName => '$brand $name';

  /// Rating text (e.g., "4.5 (120 reviews)")
  String get ratingText {
    if (reviewCount == 0) return 'No reviews';
    return '$rating ($reviewCount ${reviewCount == 1 ? 'review' : 'reviews'})';
  }

  /// Stock status text
  String get stockStatus {
    if (stock == 0) return 'Out of Stock';
    if (stock <= 3) return 'Only $stock left';
    return 'In Stock';
  }

  /// All images including main and additional
  List<String> get allImages {
    return [imageUrl, ...?additionalImages];
  }

  // ===========================================================================
  // EQUALITY & STRING
  // ===========================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $fullName, price: $price)';
  }
}
