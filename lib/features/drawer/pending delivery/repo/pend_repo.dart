import 'package:campus_mart_admin/core/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pendingRepo = Provider((ref) {
  return PendingDeliveryRepo(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

class PendingDeliveryRepo {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  PendingDeliveryRepo({required this.firestore, required this.firebaseAuth});

  /// Fetch all orders with "paid", "shipped", or "collected" status (admin panel - pending deliveries)
  /// Orders remain visible until payment is released (status becomes "completed")
  Stream<List<Map<String, dynamic>>> fetchPendingDeliveries() {
    try {
      return firestore
          .collection('orders')
          .where('status', whereIn: ['paid', 'shipped', 'collected'])
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

  /// Fetch inflow and outflow statistics
  /// Inflow: Total amount of all paid orders (paid, shipped, collected, completed)
  /// Outflow: Total amount of completed orders (payment released to sellers)
  Stream<Map<String, double>> fetchInflowOutflow() {
    try {
      return firestore.collection('orders').snapshots().map((snapshot) {
        double inflow = 0.0;
        double outflow = 0.0;

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final status = data['status'] as String?;
          final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

          // Inflow: all orders that have been paid
          if (status == 'paid' ||
              status == 'shipped' ||
              status == 'collected' ||
              status == 'completed') {
            inflow += amount;
          }

          // Outflow: only completed orders (payment released)
          if (status == 'completed') {
            outflow += amount;
          }
        }

        return {
          'inflow': inflow,
          'outflow': outflow,
          'pending': inflow - outflow,
        };
      });
    } catch (e) {
      throw Exception('Error fetching inflow/outflow: $e');
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

  /// Release payment to seller - marks order as completed
  Future<void> releasePayment(String orderId) async {
    try {
      await firestore.collection('orders').doc(orderId).update({
        'status': 'completed',
        'completedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error releasing payment: $e');
    }
  }
  Future<void> cancelOrder(String orderId)async{
    try {
      await firestore.collection('orders').doc(orderId).delete();
    } catch (e) {
      throw Exception('Error cancelling order');
    }

  }
}
