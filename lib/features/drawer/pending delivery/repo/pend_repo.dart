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

  /// Private helper method to create a notification for a user
  Future<void> _createNotification({
    required String userId,
    required String title,
    required String body,
    required String orderId,
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'title': title,
      'body': body,
      'isRead': false,
      'createdAt': Timestamp.now(),
      'type': 'order_update',
      'relatedId': orderId,
    });
  }

  /// Update order status to "shipped" when seller drops/delivers the item
  /// Pass orderData from the view to avoid extra Firestore read
  Future<void> updateStatusToDropped(String orderId, {Map<String, dynamic>? orderData}) async {
    try {
      await firestore.collection('orders').doc(orderId).update({
        'status': 'shipped',
        'isShippingConfirmed': true,
      });

      // Create notification for the buyer
      if (orderData != null) {
        final buyerId = orderData['buyerId'] as String?;
        final productId = orderData['productId'] as String?;
        
        if (buyerId != null && productId != null) {
          final productData = await fetchProductById(productId);
          final productTitle = productData?['title'] ?? 'your item';
          
          await _createNotification(
            userId: buyerId,
            title: 'Order Shipped',
            body: 'Your order for "$productTitle" has been shipped and is ready for pickup.',
            orderId: orderId,
          );
        }
      }
    } catch (e) {
      throw Exception('Error updating order to shipped: $e');
    }
  }

  /// Update order status to "collected" when buyer picks up the item
  /// Pass orderData from the view to avoid extra Firestore read
  Future<void> updateStatusToCollected(String orderId, {Map<String, dynamic>? orderData}) async {
    try {
      await firestore.collection('orders').doc(orderId).update({
        'status': 'collected',
        'hasCollectedItem': true,
        'recievedAt': Timestamp.now(),
      });

      // Create notification for the seller
      if (orderData != null) {
        final sellerId = orderData['sellerId'] as String?;
        final productId = orderData['productId'] as String?;
        
        if (sellerId != null && productId != null) {
          final productData = await fetchProductById(productId);
          final productTitle = productData?['title'] ?? 'your item';
          
          await _createNotification(
            userId: sellerId,
            title: 'Item Collected',
            body: 'Your item "$productTitle" has been collected by the buyer.',
            orderId: orderId,
          );
        }
      }
    } catch (e) {
      throw Exception('Error updating order to collected: $e');
    }
  }

  /// Release payment to seller - marks order as completed
  /// Pass orderData from the view to avoid extra Firestore read
  Future<void> releasePayment(String orderId, {Map<String, dynamic>? orderData}) async {
    try {
      await firestore.collection('orders').doc(orderId).update({
        'status': 'completed',
        'completedAt': Timestamp.now(),
      });

      // Create notification for the seller
      if (orderData != null) {
        final sellerId = orderData['sellerId'] as String?;
        final productId = orderData['productId'] as String?;
        
        if (sellerId != null && productId != null) {
          final productData = await fetchProductById(productId);
          final productTitle = productData?['title'] ?? 'your item';
          
          await _createNotification(
            userId: sellerId,
            title: 'Payment Released',
            body: 'Payment for "$productTitle" has been released to your account.',
            orderId: orderId,
          );
        }
      }
    } catch (e) {
      throw Exception('Error releasing payment: $e');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await firestore.collection('orders').doc(orderId).delete();
    } catch (e) {
      throw Exception('Error cancelling order');
    }
  }
}
