import 'package:campus_mart_admin/core/utils/my_colors.dart';
import 'package:campus_mart_admin/features/drawer/pending%20delivery/controller/pend_controller.dart';
import 'package:campus_mart_admin/features/drawer/pending%20delivery/widget/deliv_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingDeliveryView extends ConsumerStatefulWidget {
  const PendingDeliveryView({super.key});

  @override
  ConsumerState<PendingDeliveryView> createState() => _PendingDeliveryViewState();
}

class _PendingDeliveryViewState extends ConsumerState<PendingDeliveryView> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, String> _productCache = {}; // Cache for product names

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> _getProductName(String productId) async {
    // Check cache first
    if (_productCache.containsKey(productId)) {
      return _productCache[productId]!;
    }

    // Fetch from Firestore
    final controller = ref.read(pendingDeliveryControllerProvider);
    final productData = await controller.getProductDetails(productId);
    
    final productName = productData?['title'] ?? 'Unknown Product';
    _productCache[productId] = productName;
    
    return productName;
  }

  @override
  Widget build(BuildContext context) {
    final filteredDeliveriesAsync = ref.watch(filteredPendingDeliveriesProvider);
    final controller = ref.watch(pendingDeliveryControllerProvider);

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search by last 5 digits of Order ID...',
                prefixIcon: const Icon(Icons.search, color: MyColors.purpleShade),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: MyColors.purpleShade, width: 2),
                ),
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: filteredDeliveriesAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  final searchQuery = ref.watch(searchQueryProvider);
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          searchQuery.isEmpty 
                              ? Icons.local_shipping_outlined 
                              : Icons.search_off,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty 
                              ? 'No Pending Deliveries' 
                              : 'No Orders Found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          searchQuery.isEmpty 
                              ? 'All orders have been delivered'
                              : 'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final orderId = order['orderId'] as String;
                    final productId = order['productId'] as String? ?? '';
                    final orderDate = (order['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final last5Digits = orderId.length >= 5 
                        ? orderId.substring(orderId.length - 5) 
                        : orderId;
                    
                    return FutureBuilder<String>(
                      future: _getProductName(productId),
                      builder: (context, snapshot) {
                        final productName = snapshot.data ?? 'Loading...';
                        
                        return DeliveryWidget(
                          productName: productName,
                          orderId: last5Digits,
                          timestamp: orderDate,
                          onItemDropped: () async {
                            try {
                              await controller.markAsDropped(orderId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Order marked as shipped'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          onItemReceived: () async {
                            try {
                              await controller.markAsReceived(orderId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Order marked as collected'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: MyColors.purpleShade,
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading deliveries',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}