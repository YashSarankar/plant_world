import 'package:new_project/models/product.dart';

class AllProduct {
  final List<Product> products;

  AllProduct({required this.products});

  factory AllProduct.fromJson(Map<String, dynamic> json) {
    var productList = json['product'] as List;
    List<Product> productItems = productList.map((i) => Product.fromJson(i)).toList();

    return AllProduct(products: productItems);
  }
} 