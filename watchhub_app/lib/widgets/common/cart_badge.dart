import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/cart_provider.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final count = cartProvider.uniqueItems;

        return IconButton(
          icon: Badge(
            label: Text(count > 9 ? '9+' : count.toString()),
            isLabelVisible: count > 0,
            backgroundColor: AppColors.primaryGold,
            textColor: Colors.white,
            child: Icon(
              Icons.shopping_bag_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.cart);
          },
        );
      },
    );
  }
}
