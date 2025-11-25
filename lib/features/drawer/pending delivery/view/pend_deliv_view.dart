import 'package:campus_mart_admin/features/drawer/pending%20delivery/widget/deliv_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingDeliveryView extends ConsumerWidget {
  const PendingDeliveryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        children: [
          DeliveryWidget(productName: "Air Max", timestamp: DateTime.now(), onItemDropped: (){}, onItemReceived: (){},),
          DeliveryWidget(productName: "Air Max", timestamp: DateTime.now(), onItemDropped: (){}, onItemReceived: (){},),
          
        
      ]),
    );
  }
}