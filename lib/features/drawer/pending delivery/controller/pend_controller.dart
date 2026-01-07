
import 'package:campus_mart_admin/features/drawer/pending%20delivery/repo/pend_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final pendingDeliveryProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(pendingRepo);
  return repo.fetchPendingDeliveries();
});

// Inflow/Outflow statistics provider
final inflowOutflowProvider = StreamProvider.autoDispose<Map<String, double>>((ref) {
  final repo = ref.watch(pendingRepo);
  return repo.fetchInflowOutflow();
});

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered pending deliveries based on search query only
final filteredPendingDeliveriesProvider = Provider.autoDispose<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final ordersAsync = ref.watch(pendingDeliveryProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return ordersAsync.whenData((orders) {
    // Apply search filter only
    if (searchQuery.isNotEmpty) {
      return orders.where((order) {
        final orderId = order['orderId'] as String;
        final first6Chars = orderId.length >= 6
          ? orderId.substring(0, 6)
          : orderId;
        return first6Chars.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    return orders;
  });
});

class PendingDeliveryController {
  final PendingDeliveryRepo repo;

  PendingDeliveryController(this.repo);

  Future<void> markAsDropped(String orderId) async {
    await repo.updateStatusToDropped(orderId);
  }

  Future<void> markAsCollected(String orderId) async {
    await repo.updateStatusToCollected(orderId);
  }

  Future<void> releasePayment(String orderId) async {
    await repo.releasePayment(orderId);
  }

  Future<Map<String, dynamic>?> getProductDetails(String productId) async {
    return await repo.fetchProductById(productId);
  }
  Future<void> cancelOrder(String orderId) async {
    await repo.cancelOrder(orderId);
  }
}

final pendingDeliveryControllerProvider = Provider((ref) {
  final repo = ref.watch(pendingRepo);
  return PendingDeliveryController(repo);
});
