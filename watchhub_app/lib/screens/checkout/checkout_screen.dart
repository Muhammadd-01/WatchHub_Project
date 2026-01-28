import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../models/cart_model.dart';
import '../../services/firestore_crud_service.dart';
import '../../services/admin_notification_service.dart';
import '../../widgets/common/loading_button.dart';
import '../../widgets/common/glass_container.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedPaymentMethod = 'Cash on Delivery'; // Mock for now
  bool _isLoading = false;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _autofillAddress();
  }

  void _autofillAddress() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      if (user.name.isNotEmpty) _nameController.text = user.name;
      if (user.address != null) _addressController.text = user.address!;
      if (user.phone != null) _phoneController.text = user.phone!;
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted)
            Helpers.showErrorSnackbar(context, 'Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted)
          Helpers.showErrorSnackbar(
              context, 'Location permission permanently denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        final address =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
        final city = place.locality ?? '';
        final zip = place.postalCode ?? '';

        setState(() {
          _addressController.text = address;
          _cityController.text = city;
          _zipController.text = zip;
        });
        Helpers.showSuccessSnackbar(context, 'Location updated');
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) Helpers.showErrorSnackbar(context, 'Failed to get location');
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final cartProvider = context.read<CartProvider>();
      final firestoreService = FirestoreCrudService();

      // Get current user and items
      final user = authProvider.user;

      // Handle Buy Now or Cart
      final buyNowItem =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final List<CartItemModel> orderItems;
      final double totalAmount;

      if (buyNowItem != null && buyNowItem.containsKey('product')) {
        final product = buyNowItem['product'] as ProductModel;
        final qty = buyNowItem['quantity'] as int;
        orderItems = [
          CartItemModel(
            productId: product.id,
            quantity: qty,
            addedAt: DateTime.now(),
            product: product,
          )
        ];
        totalAmount = product.price * qty;
      } else {
        orderItems = cartProvider.items;
        totalAmount = cartProvider.totalPrice;
      }

      if (user == null) {
        throw Exception('User not logged in');
      }

      // Create Order Number
      final orderNumber = await firestoreService.generateOrderNumber();

      // Create Shipping Address
      final address = ShippingAddress(
        fullName: _nameController.text.trim(),
        addressLine1: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: 'N/A', // Simplified for demo
        postalCode: _zipController.text.trim(),
        country: 'USA', // Simplified for demo
        phone: _phoneController.text.trim(),
      );

      // Create Order Model
      final order = OrderModel(
        id: '', // Will be generated by Firestore
        userId: user.uid,
        orderNumber: orderNumber,
        items: orderItems,
        subtotal: totalAmount,
        totalAmount: totalAmount,
        status: 'pending',
        shippingAddress: address,
        paymentMethod: _selectedPaymentMethod,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await firestoreService.createOrder(order);

      // Decrement stock for each item
      for (final item in orderItems) {
        final product = item.product;
        if (product != null) {
          final newStock = product.stock - item.quantity;
          await firestoreService.updateProduct(item.productId, {
            'stock': newStock >= 0 ? newStock : 0,
          });
        }
      }

      // Clear Cart only if it wasn't a Buy Now
      if (buyNowItem == null) {
        await cartProvider.clearCart(user.uid);
      }

      // Notify admin of new order
      await AdminNotificationService.notifyOrderPlaced(
        orderNumber: orderNumber,
        userName: user.name.isNotEmpty ? user.name : 'Customer',
        total: totalAmount,
      );

      if (mounted) {
        Helpers.showSuccessSnackbar(context, 'Order placed successfully!');
        // Navigate to Orders or Success Screen (Using pop until home for now, then to orders)
        // Navigate to Home
        Navigator.popUntil(context, (route) => route.isFirst);
        // Or specific OrderSuccessScreen
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackbar(context, 'Failed to place order: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure we have cart items check?
    final cartProvider = context.watch<CartProvider>();
    final buyNowItem =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final bool isBuyNow =
        buyNowItem != null && buyNowItem.containsKey('product');

    if (cartProvider.isEmpty && !isBuyNow) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('Nothing to checkout')),
      );
    }

    final totalDisplay = isBuyNow
        ? (buyNowItem['product'] as ProductModel).price *
            (buyNowItem['quantity'] as int)
        : cartProvider.totalPrice;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: AppTextStyles.titleLarge.copyWith(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: Theme.of(context).iconTheme.color),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Shipping Address'),
              const SizedBox(height: 16),
              _buildTextField('Full Name', _nameController, Icons.person),
              const SizedBox(height: 12),
              _buildTextField(
                'Address',
                _addressController,
                Icons.home,
                suffixIcon: IconButton(
                  icon: _isGettingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.my_location, color: AppColors.primaryGold),
                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                  tooltip: 'Use my current location',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          'City', _cityController, Icons.location_city)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildTextField(
                          'ZIP Code', _zipController, Icons.numbers)),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField('Phone Number', _phoneController, Icons.phone,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 32),
              _buildSectionTitle('Payment Method'),
              const SizedBox(height: 16),
              _buildPaymentMethodSelector(),
              const SizedBox(height: 32),
              _buildSectionTitle('Order Summary'),
              const SizedBox(height: 16),
              _buildOrderSummary(totalDisplay),
              const SizedBox(height: 32),
              LoadingButton(
                onPressed: _placeOrder,
                isLoading: _isLoading,
                text: 'Place Order (${Helpers.formatCurrency(totalDisplay)})',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        color: Theme.of(context).textTheme.titleMedium?.color,
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {TextInputType? keyboardType, Widget? suffixIcon}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      children: [
        RadioListTile<String>(
          title: Text('Credit Card (Mock)',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color)),
          value: 'Credit Card',
          groupValue: _selectedPaymentMethod,
          onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
          activeColor: AppColors.primaryGold,
        ),
        RadioListTile<String>(
          title: Text('Cash on Delivery',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color)),
          value: 'Cash on Delivery',
          groupValue: _selectedPaymentMethod,
          onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
          activeColor: AppColors.primaryGold,
        ),
      ],
    );
  }

  Widget _buildOrderSummary(double totalDisplay) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color)),
              Text(Helpers.formatCurrency(totalDisplay),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shipping',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color)),
              Text('Free',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.success)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: AppTextStyles.titleMedium.copyWith(
                      color: Theme.of(context).textTheme.titleMedium?.color)),
              Text(Helpers.formatCurrency(totalDisplay),
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.primaryGold)),
            ],
          ),
        ],
      ),
    );
  }
}
