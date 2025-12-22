
import 'package:campus_mart_admin/core/providers.dart';
import 'package:campus_mart_admin/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productsRepositoryProvider = Provider((ref) {
   return ProductsRepository(
     firestore: ref.watch(firestoreProvider),
     auth: ref.watch(firebaseAuthProvider),
   );
});

class ProductsRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ProductsRepository({required this.firestore, required this.auth});

  Stream<List<Product>> fetchAllProducts() {
    try {
      final productDoc = firestore.collection('products').snapshots();
      return productDoc.map((snapshot) => snapshot.docs
          .map((doc) => Product.fromMap(doc.data()))
          .toList());
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
  Future deleteProduct(String id)async{
    await firestore.collection('products').doc(id).delete();
  }
}