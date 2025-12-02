import 'package:campus_mart_admin/core/utils/my_colors.dart';
import 'package:flutter/material.dart';

class DeliveryWidget extends StatelessWidget {
  final String productName;
  final String orderId;
  final DateTime timestamp;
  final String status;
  final VoidCallback onItemDropped;
  final VoidCallback onItemReceived;

  const DeliveryWidget({
    super.key,
    required this.productName,
    required this.orderId,
    required this.timestamp,
    required this.status,
    required this.onItemDropped,
    required this.onItemReceived,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MyColors.purpleShade.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: MyColors.purpleShade.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: MyColors.purpleShade,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MyColors.darkBase,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order ID: $orderId',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: MyColors.purpleShade,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimestamp(timestamp),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Action buttons
          Row(
            children: [
              // Item Dropped button
              ElevatedButton.icon(
                onPressed: (status == 'shipped' || status == 'completed') ? null : onItemDropped,
                icon: const Icon(Icons.local_shipping, size: 18),
                label: const Text('Dropped'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (status == 'shipped' || status == 'completed') ? Colors.grey.shade200 : Colors.orange.shade50,
                  foregroundColor: (status == 'shipped' || status == 'completed') ? Colors.grey.shade400 : Colors.orange.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: (status == 'shipped' || status == 'completed') ? Colors.grey.shade300 : Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  disabledBackgroundColor: Colors.grey.shade200,
                  disabledForegroundColor: Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 12),
              
              // Item Received button
              ElevatedButton.icon(
                onPressed: status == 'completed' ? null : onItemReceived,
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Received'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: status == 'completed' ? Colors.grey.shade200 : Colors.green.shade50,
                  foregroundColor: status == 'completed' ? Colors.grey.shade400 : Colors.green.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: status == 'completed' ? Colors.grey.shade300 : Colors.green.shade200,
                      width: 1,
                    ),
                  ),
                  disabledBackgroundColor: Colors.grey.shade200,
                  disabledForegroundColor: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}






