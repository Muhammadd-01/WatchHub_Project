// =============================================================================
// FILE: app_constants.dart
// PURPOSE: Central location for all application constants
// DESCRIPTION: Contains API keys, collection names, asset paths, and other
//              static values used throughout the application.
// =============================================================================

/// Application-wide constants for WatchHub
///
/// This class contains all static configuration values to ensure
/// consistency across the application and easy maintenance.
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ===========================================================================
  // APP INFO
  // ===========================================================================

  /// Application name displayed in UI
  static const String appName = 'WatchHub';

  /// Application tagline for branding
  static const String appTagline = 'Luxury Timepieces';

  /// Current app version
  static const String appVersion = '1.0.0';

  // ===========================================================================
  // FIRESTORE COLLECTION NAMES
  // ===========================================================================
  // These constants ensure consistent collection naming across all services

  /// Users collection - stores user profiles
  /// Document ID = Firebase Auth UID
  static const String usersCollection = 'users';

  /// Products collection - stores all watch products
  static const String productsCollection = 'products';

  /// Carts collection - stores user carts
  /// Document ID = Firebase Auth UID
  static const String cartsCollection = 'carts';

  /// Cart items subcollection name
  static const String cartItemsSubcollection = 'items';

  /// Wishlists collection - stores user wishlists
  /// Document ID = Firebase Auth UID
  static const String wishlistsCollection = 'wishlists';

  /// Wishlist items subcollection name
  static const String wishlistItemsSubcollection = 'items';

  /// Orders collection - stores all orders
  static const String ordersCollection = 'orders';

  /// Reviews subcollection under products
  static const String reviewsSubcollection = 'reviews';

  /// Feedbacks collection - stores user feedback
  static const String feedbacksCollection = 'feedbacks';

  /// Categories collection - stores product categories
  static const String categoriesCollection = 'categories';

  /// Brands collection - stores watch brands
  static const String brandsCollection = 'brands';

  /// FAQs collection - stores question and answers
  static const String faqsCollection = 'faqs';

  // ===========================================================================
  // SUPABASE STORAGE BUCKETS
  // ===========================================================================

  /// Bucket name for product images
  static const String productImagesBucket = 'product-images';

  /// Bucket name for user profile images
  static const String profileImagesBucket = 'profile-images';

  // ===========================================================================
  // WATCH BRANDS
  // ===========================================================================

  /// List of premium watch brands
  static const List<String> watchBrands = [
    'Rolex',
    'Omega',
    'Patek Philippe',
    'Audemars Piguet',
    'Cartier',
    'Tag Heuer',
    'Breitling',
    'IWC',
  ];

  // ===========================================================================
  // WATCH CATEGORIES
  // ===========================================================================

  /// Watch type categories
  static const List<String> watchCategories = [
    'Luxury',
    'Sport',
    'Classic',
    'Diving',
    'Pilot',
    'Dress',
  ];

  // ===========================================================================
  // PRICE RANGES
  // ===========================================================================

  /// Price range filters for browsing
  static const Map<String, Map<String, double>> priceRanges = {
    'Under \$5,000': {'min': 0, 'max': 5000},
    '\$5,000 - \$10,000': {'min': 5000, 'max': 10000},
    '\$10,000 - \$25,000': {'min': 10000, 'max': 25000},
    '\$25,000 - \$50,000': {'min': 25000, 'max': 50000},
    'Over \$50,000': {'min': 50000, 'max': double.infinity},
  };

  // ===========================================================================
  // ANIMATION DURATIONS
  // ===========================================================================

  /// Standard animation duration
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Slow animation duration for emphasis
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  /// Fast animation duration for quick feedback
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);

  // ===========================================================================
  // PAGINATION
  // ===========================================================================

  /// Number of products to load per page
  static const int productsPerPage = 10;

  /// Number of reviews to load per page
  static const int reviewsPerPage = 5;

  /// Number of orders to load per page
  static const int ordersPerPage = 10;

  // ===========================================================================
  // VALIDATION
  // ===========================================================================

  /// Minimum password length
  static const int minPasswordLength = 6;

  /// Maximum review comment length
  static const int maxReviewLength = 500;

  /// Maximum feedback message length
  static const int maxFeedbackLength = 1000;

  // ===========================================================================
  // ORDER STATUSES
  // ===========================================================================

  /// Possible order status values
  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];
}
