// =============================================================================
// FILE: admin_cart_provider.dart
// PURPOSE: View All Active Carts
// DESCRIPTION: Fetches all carts from Firestore and resolves user details.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _activeCarts = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get activeCarts => _activeCarts;
  bool get isLoading => _isLoading;

  Future<void> fetchActiveCarts() async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Get all cart documents (assuming top-level 'carts' collection where docId is UID)
      final cartsSnapshot = await _firestore.collection('carts').get();

      List<Map<String, dynamic>> loadedCarts = [];

      for (var doc in cartsSnapshot.docs) {
        final uid = doc.id;

        // 2. Get items in the 'items' subcollection
        final itemsSnapshot = await _firestore
            .collection('carts')
            .doc(uid)
            .collection('items')
            .get();

        if (itemsSnapshot.docs.isNotEmpty) {
          // 3. Get User Details
          final userDoc = await _firestore.collection('users').doc(uid).get();
          final userData =
              userDoc.data() ?? {'name': 'Unknown User', 'email': 'No Email'};

          // 4. Resolve Product Details (Name only for summary)
          List<Map<String, dynamic>> items = [];
          for (var itemDoc in itemsSnapshot.docs) {
            final itemData = itemDoc.data();
            final productId =
                itemData['productId']; // or doc.id if stored that way

            // To be efficient, we might not fetch full product details for overview,
            // but let's try to get product name if possible, or just show ID/Quantity.
            // A meaningful view needs names.
            DocumentSnapshot? productDoc;
            try {
              productDoc =
                  await _firestore.collection('products').doc(productId).get();
            } catch (_) {}

            items.add({
              'productId': productId,
              'quantity': itemData['quantity'] ?? 0,
              'productName': productDoc != null && productDoc.exists
                  ? productDoc['name']
                  : 'Unknown Product',
              'price': productDoc != null && productDoc.exists
                  ? (productDoc['price'] ?? 0)
                  : 0,
            });
          }

          if (items.isNotEmpty) {
            loadedCarts.add({
              'uid': uid,
              'userName': userData['name'],
              'userEmail': userData['email'],
              'items': items,
              'itemCount': items.length,
            });
          }
        }
      }

      _activeCarts = loadedCarts;
    } catch (e) {
      debugPrint('Error fetching carts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
