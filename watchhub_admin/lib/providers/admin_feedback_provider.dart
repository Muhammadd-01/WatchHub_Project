// =============================================================================
// FILE: admin_feedback_provider.dart
// PURPOSE: View Feedbacks
// DESCRIPTION: Fetch reviews/feedbacks.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFeedbackProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _feedbacks = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get feedbacks => _feedbacks;
  bool get isLoading => _isLoading;

  Future<void> fetchFeedbacks() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Assuming 'reviews' collection or 'feedbacks'
      // Based on previous conversations, main app usually uses 'reviews' subcollection or top level.
      // I'll check if a 'feedback' or 'contact_messages' collection exists.
      // For now, I'll target a generic 'feedbacks' collection.
      final snapshot = await _firestore
          .collection('feedbacks')
          .orderBy('createdAt', descending: true)
          .get();
      _feedbacks = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching feedbacks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resolveFeedback(String feedbackId) async {
    try {
      await _firestore.collection('feedbacks').doc(feedbackId).update({
        'isResolved': true,
        'respondedAt': FieldValue.serverTimestamp(),
      });
      await fetchFeedbacks();
      return true;
    } catch (e) {
      debugPrint('Error resolving feedback: $e');
      return false;
    }
  }
}
