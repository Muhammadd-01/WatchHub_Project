// =============================================================================
// FILE: main_navigation_screen.dart
// PURPOSE: Main navigation shell for WatchHub
// DESCRIPTION: Bottom navigation with Home, Search, Cart, Wishlist, and Profile.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/product_provider.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import '../cart/cart_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../profile/profile_screen.dart';

/// Main navigation screen with bottom navigation bar
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    CartScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid "setState() or markNeedsBuild() called during build"
    // error when providers notify listeners during initialization.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final authProvider = context.read<AuthProvider>();
    final productProvider = context.read<ProductProvider>();
    final cartProvider = context.read<CartProvider>();
    final wishlistProvider = context.read<WishlistProvider>();

    // Load products
    await productProvider.refresh();

    // Initialize user-specific data if authenticated
    if (authProvider.isAuthenticated && authProvider.uid != null) {
      cartProvider.initialize(authProvider.uid!);
      wishlistProvider.initialize(authProvider.uid!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
              _buildNavItem(
                1,
                Icons.search_outlined,
                Icons.search_rounded,
                'Search',
              ),
              _buildCartNavItem(),
              _buildWishlistNavItem(),
              _buildNavItem(
                4,
                Icons.person_outline,
                Icons.person_rounded,
                'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isActive = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGold.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primaryGold : AppColors.iconSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isActive ? AppColors.primaryGold : AppColors.textTertiary,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartNavItem() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final itemCount = cartProvider.totalItems;
        final isActive = _currentIndex == 2;

        return InkWell(
          onTap: () => setState(() => _currentIndex = 2),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryGold.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isActive
                          ? Icons.shopping_bag_rounded
                          : Icons.shopping_bag_outlined,
                      color: isActive
                          ? AppColors.primaryGold
                          : AppColors.iconSecondary,
                      size: 24,
                    ),
                    if (itemCount > 0)
                      Positioned(
                        right: -8,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGold,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            itemCount > 9 ? '9+' : '$itemCount',
                            style: const TextStyle(
                              color: AppColors.scaffoldBackground,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Cart',
                  style: TextStyle(
                    color: isActive
                        ? AppColors.primaryGold
                        : AppColors.textTertiary,
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWishlistNavItem() {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, _) {
        final itemCount = wishlistProvider.count;
        final isActive = _currentIndex == 3;

        return InkWell(
          onTap: () => setState(() => _currentIndex = 3),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryGold.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isActive
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline,
                      color: isActive
                          ? AppColors.primaryGold
                          : AppColors.iconSecondary,
                      size: 24,
                    ),
                    if (itemCount > 0)
                      Positioned(
                        right: -8,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGold,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            itemCount > 9 ? '9+' : '$itemCount',
                            style: const TextStyle(
                              color: AppColors.scaffoldBackground,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Wishlist',
                  style: TextStyle(
                    color: isActive
                        ? AppColors.primaryGold
                        : AppColors.textTertiary,
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
