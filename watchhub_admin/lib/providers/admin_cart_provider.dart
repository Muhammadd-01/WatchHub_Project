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
      // Since parent 'carts/{uid}' docs might not exist, we query the subcollection 'items' directly
      // Note: This requires an index if we add where clauses, but for basic get() it works.
      // However, 'items' is also used by wishlists. We must filter.
      final querySnapshot = await _firestore.collectionGroup('items').get();

      final Map<String, Map<String, dynamic>> cartGroups = {};

      for (var doc in querySnapshot.docs) {
        // Check if this item belongs to a 'carts' collection
        // Path format: carts/{uid}/items/{productId}
        final pathSegments = doc.reference.path.split('/');

        // Safety check for correct path depth
        if (pathSegments.length >= 4 &&
            pathSegments[0] == 'carts' &&
            pathSegments[2] == 'items') {
          final uid = pathSegments[1];
          final productData = doc.data();
          final productId = productData['productId'] ??
              doc.id; // Use productId field or doc ID

          if (!cartGroups.containsKey(uid)) {
            cartGroups[uid] = {
              'uid': uid,
              'items': <Map<String, dynamic>>[],
            };
          }

          // Fetch product name separately (optimization: cache names)
          DocumentSnapshot? productDoc;
          try {
            productDoc =
                await _firestore.collection('products').doc(productId).get();
          } catch (_) {}

          cartGroups[uid]!['items'].add({
            'productId': productId,
            'quantity': productData['quantity'] ?? 0,
            'productName': productDoc != null && productDoc.exists
                ? productDoc['name']
                : 'Product #$productId',
            'price': productDoc != null && productDoc.exists
                ? (productDoc['price'] ?? 0)
                : 0,
          });
        }
      }

      // Now enrich with User Names
      List<Map<String, dynamic>> finalCarts = [];
      for (var uid in cartGroups.keys) {
        final userData = await _firestore.collection('users').doc(uid).get();
        final userMap = userData.data() ?? {};

        finalCarts.add({
          'uid': uid,
          'userName': userMap['name'] ?? 'Unknown User',
          'userEmail': userMap['email'] ?? 'No Email',
          'items': cartGroups[uid]!['items'],
          'itemCount': (cartGroups[uid]!['items'] as List).length,
        });
      }

      _activeCarts = finalCarts;
    } catch (e) {
      debugPrint('Error fetching carts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> clearUserCart(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('carts')
          .doc(uid)
          .collection('items')
          .get();
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      await fetchActiveCarts();
      return true;
    } catch (e) {
      debugPrint('Error clearing cart for $uid: $e');
      return false;
    }
  }
}
