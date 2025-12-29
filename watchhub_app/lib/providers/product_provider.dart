// =============================================================================
// FILE: product_provider.dart
// PURPOSE: Product state management for WatchHub
// DESCRIPTION: Manages product listing, filtering, searching, and individual
//              product details. Fetches data from Firestore.
// =============================================================================

import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/firestore_crud_service.dart';

/// Product state provider
///
/// This provider:
/// - Manages product listings
/// - Handles filtering by brand, category, price
/// - Provides search functionality
/// - Manages featured and new arrival products
class ProductProvider extends ChangeNotifier {
  // Service
  final FirestoreCrudService _firestoreService = FirestoreCrudService();

  // State
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _newArrivals = [];
  List<ProductModel> _searchResults = [];
  ProductModel? _selectedProduct;

  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  String? _selectedBrand;
  String? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;
  String _sortBy = 'newest';
  String _searchQuery = '';

  // Getters
  List<ProductModel> get products =>
      _filteredProducts.isNotEmpty ? _filteredProducts : _products;
  List<ProductModel> get allProducts => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get newArrivals => _newArrivals;
  List<ProductModel> get searchResults => _searchResults;
  ProductModel? get selectedProduct => _selectedProduct;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasProducts => _products.isNotEmpty;
  bool get hasFilters =>
      _selectedBrand != null ||
      _selectedCategory != null ||
      _minPrice != null ||
      _maxPrice != null;

  String? get selectedBrand => _selectedBrand;
  String? get selectedCategory => _selectedCategory;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String get sortBy => _sortBy;

  // ===========================================================================
  // LOAD PRODUCTS
  // ===========================================================================

  /// Loads all products from Firestore
  Future<void> loadProducts() async {
    try {
      _setLoading(true);
      _clearError();

      _products = await _firestoreService.getProducts(sortBy: _sortBy);

      // Apply any existing filters
      _applyFilters();

      debugPrint('ProductProvider: Loaded ${_products.length} products');

      notifyListeners();
    } catch (e) {
      debugPrint('ProductProvider: Error loading products - $e');
      _setError('Failed to load products');
    } finally {
      _setLoading(false);
    }
  }

  /// Loads featured products
  Future<void> loadFeaturedProducts() async {
    try {
      _featuredProducts = await _firestoreService.getProducts(
        isFeatured: true,
        limit: 6,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('ProductProvider: Error loading featured products - $e');
    }
  }

  /// Loads new arrival products
  Future<void> loadNewArrivals() async {
    try {
      _newArrivals = await _firestoreService.getProducts(
        isNewArrival: true,
        sortBy: 'newest',
        limit: 6,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('ProductProvider: Error loading new arrivals - $e');
    }
  }

  /// Loads products by brand
  Future<void> loadProductsByBrand(String brand) async {
    try {
      _setLoading(true);
      _selectedBrand = brand;

      _products = await _firestoreService.getProducts(
        brand: brand,
        sortBy: _sortBy,
      );

      _filteredProducts = _products;

      notifyListeners();
    } catch (e) {
      debugPrint('ProductProvider: Error loading products by brand - $e');
      _setError('Failed to load products');
    } finally {
      _setLoading(false);
    }
  }

  /// Loads products by category
  Future<void> loadProductsByCategory(String category) async {
    try {
      _setLoading(true);
      _selectedCategory = category;

      _products = await _firestoreService.getProducts(
        category: category,
        sortBy: _sortBy,
      );

      _filteredProducts = _products;

      notifyListeners();
    } catch (e) {
      debugPrint('ProductProvider: Error loading products by category - $e');
      _setError('Failed to load products');
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================================
  // GET SINGLE PRODUCT
  // ===========================================================================

  /// Gets a single product by ID
  Future<ProductModel?> getProduct(String productId) async {
    try {
      // Check if already loaded
      final existingProduct = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => ProductModel(
          id: '',
          name: '',
          brand: '',
          description: '',
          price: 0,
          imageUrl: '',
          category: '',
          stock: 0,
          specifications: {},
          createdAt: DateTime.now(),
        ),
      );

      if (existingProduct.id.isNotEmpty) {
        _selectedProduct = existingProduct;
        notifyListeners();
        return existingProduct;
      }

      // Fetch from Firestore
      final product = await _firestoreService.getProduct(productId);
      _selectedProduct = product;
      notifyListeners();
      return product;
    } catch (e) {
      debugPrint('ProductProvider: Error getting product - $e');
      return null;
    }
  }

  /// Sets the selected product
  void setSelectedProduct(ProductModel product) {
    _selectedProduct = product;
    notifyListeners();
  }

  /// Clears the selected product
  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  // ===========================================================================
  // SEARCH
  // ===========================================================================

  /// Searches products by query
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    try {
      _searchQuery = query;
      _setLoading(true);

      _searchResults = await _firestoreService.searchProducts(query);

      debugPrint(
        'ProductProvider: Found ${_searchResults.length} results for "$query"',
      );

      notifyListeners();
    } catch (e) {
      debugPrint('ProductProvider: Error searching products - $e');
      _searchResults = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Clears search results
  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    notifyListeners();
  }

  // ===========================================================================
  // FILTERING
  // ===========================================================================

  /// Sets the brand filter
  void setBrandFilter(String? brand) {
    _selectedBrand = brand;
    _applyFilters();
    notifyListeners();
  }

  /// Sets the category filter
  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Sets the price range filter
  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    _applyFilters();
    notifyListeners();
  }

  /// Sets the sort option
  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applyFilters();
    notifyListeners();
  }

  /// Applies all current filters
  void _applyFilters() {
    _filteredProducts = List.from(_products);

    // Apply brand filter
    if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
      _filteredProducts = _filteredProducts
          .where((p) => p.brand == _selectedBrand)
          .toList();
    }

    // Apply category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      _filteredProducts = _filteredProducts
          .where((p) => p.category == _selectedCategory)
          .toList();
    }

    // Apply min price filter
    if (_minPrice != null) {
      _filteredProducts = _filteredProducts
          .where((p) => p.price >= _minPrice!)
          .toList();
    }

    // Apply max price filter
    if (_maxPrice != null && _maxPrice != double.infinity) {
      _filteredProducts = _filteredProducts
          .where((p) => p.price <= _maxPrice!)
          .toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'price_asc':
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        _filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'newest':
      default:
        _filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  /// Clears all filters
  void clearFilters() {
    _selectedBrand = null;
    _selectedCategory = null;
    _minPrice = null;
    _maxPrice = null;
    _sortBy = 'newest';
    _filteredProducts = [];
    notifyListeners();
  }

  // ===========================================================================
  // UTILITY
  // ===========================================================================

  /// Gets unique brands from products
  List<String> get availableBrands {
    return _products.map((p) => p.brand).toSet().toList()..sort();
  }

  /// Gets unique categories from products
  List<String> get availableCategories {
    return _products.map((p) => p.category).toSet().toList()..sort();
  }

  /// Gets min and max prices from products
  Map<String, double> get priceRange {
    if (_products.isEmpty) {
      return {'min': 0, 'max': 100000};
    }

    final prices = _products.map((p) => p.price).toList();
    return {
      'min': prices.reduce((a, b) => a < b ? a : b),
      'max': prices.reduce((a, b) => a > b ? a : b),
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Refreshes all product data
  Future<void> refresh() async {
    await Future.wait([
      loadProducts(),
      loadFeaturedProducts(),
      loadNewArrivals(),
    ]);
  }
}
