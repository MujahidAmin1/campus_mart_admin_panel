
import 'package:campus_mart_admin/core/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pendingRepo = Provider((ref){
  return PendingDeliveryRepo(
firebaseAuth: ref.watch(firebaseAuthProvider),
firestore: ref.watch(firestoreProvider),
  );
});

class PendingDeliveryRepo {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  PendingDeliveryRepo({required this.firestore, required this.firebaseAuth});

  /// Fetch all orders with "paid" or "shipped" status (admin panel - pending deliveries)
  /// Orders remain visible after "Dropped" is clicked, only disappear when "Received" is clicked
  Stream<List<Map<String, dynamic>>> fetchPendingDeliveries() {
    try {
      return firestore
          .collection('orders')
          .where('status', whereIn: ['paid', 'shipped'])
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['orderId'] = doc.id; // Ensure orderId is included
          return data;
        }).toList();
      });
    } catch (e) {
      throw Exception('Error fetching pending deliveries: $e');
    }
  }

  /// Fetch product details by productId
  Future<Map<String, dynamic>?> fetchProductById(String productId) async {
    try {
      final doc = await firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  /// Update order status to "shipped" when seller drops/delivers the item
  Future<void> updateStatusToDropped(String orderId) async {
    try {
      await firestore.collection('orders').doc(orderId).update({
        'status': 'shipped',
        'isShippingConfirmed': true,
      });
    } catch (e) {
      throw Exception('Error updating order to shipped: $e');
    }
  }

  /// Update order status to "collected" when buyer picks up the item
  Future<void> updateStatusToCollected(String orderId) async {
    try {
      await firestore.collection('orders').doc(orderId).update({
        'status': 'collected',
        'hasCollectedItem': true,
        'recievedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error updating order to collected: $e');
    }
  }
}