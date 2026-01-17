// =============================================================================
// FILE: main_screen.dart
// PURPOSE: Root screen for authenticated users
// DESCRIPTION: Holds the BottomNavigationBar and switches between main feature screens.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../../main.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/wishlist_provider.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'wishlist/wishlist_screen.dart';
import 'cart/cart_screen.dart';
import 'profile/profile_screen.dart';
import '../services/push_notification_service.dart';

/// Root screen for authenticated users
///
/// PURPOSE:
/// Serves as the main container for the application's core navigation.
/// It uses a BottomNavigationBar to switch between the 5 main tabs:
/// Home, Search, Wishlist, Cart, and Profile.
///
/// CALLED FROM:
/// - AuthWrapper (in main.dart) when AuthState is 'authenticated'.
/// - LoginScreen/SignupScreen (after successful login/signup).
///
/// INITIALIZATION:
/// - In `initState`, it triggers initialization of user-specific providers
///   (CartProvider, WishlistProvider) using the current user's UID.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated) {
        final uid = auth.uid!;
        context.read<CartProvider>().initialize(uid);
        context.read<WishlistProvider>().initialize(uid);
        // Also ensure products are loaded for search
        context.read<ProductProvider>().refresh();

        // Initialize Push Notifications with UID
        PushNotificationService().initialize(navigatorKey, uid: uid);
      }
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const WishlistScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          child: NavigationBar(
            height: 65,
            backgroundColor: theme.scaffoldBackgroundColor,
            indicatorColor: AppColors.primaryGold.withOpacity(0.2),
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: [
              _buildNavDestination(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Home',
              ),
              _buildNavDestination(
                icon: Icons.search_outlined,
                selectedIcon: Icons.search_rounded,
                label: 'Search',
              ),
              _buildWishlistDestination(),
              _buildCartDestination(),
              _buildNavDestination(
                icon: Icons.person_outline,
                selectedIcon: Icons.person_rounded,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildNavDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    return NavigationDestination(
      icon: Icon(icon, color: AppColors.textSecondary),
      selectedIcon: Icon(selectedIcon, color: AppColors.primaryGold),
      label: label,
    );
  }

  NavigationDestination _buildCartDestination() {
    return NavigationDestination(
      icon: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return Badge(
            label: Text('${cart.totalItems}'),
            isLabelVisible: cart.totalItems > 0,
            backgroundColor: AppColors.primaryGold,
            textColor: Colors.white,
            child: const Icon(Icons.shopping_bag_outlined,
                color: AppColors.textSecondary),
          );
        },
      ),
      selectedIcon: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return Badge(
            label: Text('${cart.totalItems}'),
            isLabelVisible: cart.totalItems > 0,
            backgroundColor: AppColors.primaryGold,
            textColor: Colors.white,
            child: const Icon(Icons.shopping_bag_rounded,
                color: AppColors.primaryGold),
          );
        },
      ),
      label: 'Cart',
    );
  }

  NavigationDestination _buildWishlistDestination() {
    return NavigationDestination(
      icon: Consumer<WishlistProvider>(
        builder: (context, wishlist, child) {
          return Badge(
            label: Text('${wishlist.count}'),
            isLabelVisible: wishlist.count > 0,
            backgroundColor: AppColors.primaryGold,
            textColor: Colors.white,
            child: const Icon(Icons.favorite_outline,
                color: AppColors.textSecondary),
          );
        },
      ),
      selectedIcon: Consumer<WishlistProvider>(
        builder: (context, wishlist, child) {
          return Badge(
            label: Text('${wishlist.count}'),
            isLabelVisible: wishlist.count > 0,
            backgroundColor: AppColors.primaryGold,
            textColor: Colors.white,
            child: const Icon(Icons.favorite_rounded,
                color: AppColors.primaryGold),
          );
        },
      ),
      label: 'Wishlist',
    );
  }
}
