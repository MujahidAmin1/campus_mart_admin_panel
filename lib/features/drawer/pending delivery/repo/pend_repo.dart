import 'package:campus_mart_admin/core/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pendingRepo = Provider((ref) {
  return PendingDeliveryRepo(firestore: ref.watch(firestoreProvider));
});

class PendingDeliveryRepo {
  final FirebaseFirestore firestore;

  PendingDeliveryRepo({required this.firestore});

  /// Fetch all orders with "paid", "shipped", or "collected" status
  Stream<List<Map<String, dynamic>>> fetchPendingDeliveries() {
    return firestore
        .collection('orders')
        .where('status', whereIn: ['paid', 'shipped', 'collected'])
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['orderId'] = doc.id;
              return data;
            }).toList());
  }

  /// Fetch product details by productId
  Future<Map<String, dynamic>?> fetchProductById(String productId) async {
    final doc = await firestore.collection('products').doc(productId).get();
    return doc.data();
  }

  /// Fetch inflow and outflow statistics
  Stream<Map<String, double>> fetchInflowOutflow() {
    return firestore.collection('orders').snapshots().map((snapshot) {
      double inflow = 0.0;
      double outflow = 0.0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String?;
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

        if (['paid', 'shipped', 'collected', 'completed'].contains(status)) {
          inflow += amount;
        }
        if (status == 'completed') {
          outflow += amount;
        }
      }

      return {'inflow': inflow, 'outflow': outflow, 'pending': inflow - outflow};
    });
  }

  /// Helper to get product title from orderData
  Future<String> _getProductTitle(Map<String, dynamic>? orderData) async {
    final productId = orderData?['productId'] as String?;
    if (productId == null) return 'your item';
    final productData = await fetchProductById(productId);
    return productData?['title'] ?? 'your item';
  }

  /// Create a notification for a user
  Future<void> _notify(String? userId, String title, String body, String orderId) async {
    if (userId == null) return;
    await firestore.collection('users').doc(userId).collection('notifications').add({
      'title': title,
      'body': body,
      'isRead': false,
      'createdAt': Timestamp.now(),
      'type': 'order_update',
      'relatedId': orderId,
    });
  }

  /// Update order status to "shipped"
  Future<void> updateStatusToDropped(String orderId, {Map<String, dynamic>? orderData}) async {
    await firestore.collection('orders').doc(orderId).update({
      'status': 'shipped',
      'isShippingConfirmed': true,
    });

    if (orderData != null) {
      final title = await _getProductTitle(orderData);
      await _notify(
        orderData['buyerId'],
        'Order Shipped',
        'Your order for "$title" has been shipped and is ready for pickup.',
        orderId,
      );
    }
  }

  /// Update order status to "collected"
  Future<void> updateStatusToCollected(String orderId, {Map<String, dynamic>? orderData}) async {
    await firestore.collection('orders').doc(orderId).update({
      'status': 'collected',
      'hasCollectedItem': true,
      'recievedAt': Timestamp.now(),
    });

    if (orderData != null) {
      final title = await _getProductTitle(orderData);
      await _notify(
        orderData['sellerId'],
        'Item Collected',
        'Your item "$title" has been collected by the buyer.',
        orderId,
      );
    }
  }

  /// Release payment to seller - marks order as completed and product as unavailable
  Future<void> releasePayment(String orderId, {Map<String, dynamic>? orderData}) async {
    await firestore.collection('orders').doc(orderId).update({
      'status': 'completed',
      'completedAt': Timestamp.now(),
    });

    if (orderData != null) {
      // Mark product as unavailable (sold)
      final productId = orderData['productId'] as String?;
      if (productId != null) {
        await firestore.collection('products').doc(productId).update({
          'isAvailable': false,
        });
      }

      final title = await _getProductTitle(orderData);
      await _notify(
        orderData['sellerId'],
        'Payment Released',
        'Payment for "$title" has been released to your account.',
        orderId,
      );
    }
  }

  /// Cancel an order - notifies buyer and seller, then deletes order
  Future<void> cancelOrder(String orderId, {Map<String, dynamic>? orderData}) async {
    if (orderData != null) {
      final title = await _getProductTitle(orderData);
      await _notify(
        orderData['buyerId'],
        'Order Cancelled',
        'Your order for "$title" has been cancelled by the admin.',
        orderId,
      );
      await _notify(
        orderData['sellerId'],
        'Order Cancelled',
        'The order for "$title" has been cancelled by the admin.',
        orderId,
      );
    }
    await firestore.collection('orders').doc(orderId).delete();
  }
}
