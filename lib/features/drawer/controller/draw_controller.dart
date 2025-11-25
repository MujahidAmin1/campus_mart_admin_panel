
import 'package:campus_mart_admin/features/drawer/repo/drawer_repository.dart';
import 'package:campus_mart_admin/models/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productContProvider = StreamNotifierProvider.autoDispose<ProductController, List<Product>>(() {
  return ProductController();
});

class ProductController extends  StreamNotifier<List<Product>> {
  late final ProductsRepository productsRepository;
  @override
  Stream<List<Product>> build() {
    final productsRepository = ref.watch(productsRepositoryProvider);
    return productsRepository.fetchAllProducts();
  }


  Stream<List<Product>> fetchProducts() {
    return productsRepository.fetchAllProducts();
  }
}