import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../screens/product_detail_screen.dart';

class AllProductsScreen extends StatefulWidget {
  @override
  _AllProductsScreenState createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  late Future<List<Product>> _products;

  @override
  void initState() {
    super.initState();
    _products = ApiService.fetchAllProducts().then((allProduct) => allProduct.products);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('All Products',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Product>>(
          future: _products,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No products available'));
            }

            final products = snapshot.data!;

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                double? originalPrice = double.tryParse(product.price);
                double? discountedPrice =
                    product.discountedPrice.isNotEmpty ? double.tryParse(product.discountedPrice) : null;

                String discountText = "";
                if (originalPrice != null &&
                    discountedPrice != null &&
                    discountedPrice < originalPrice) {
                  double discountPercentage =
                      ((originalPrice - discountedPrice) / originalPrice) * 100;
                  discountText = '${discountPercentage.toStringAsFixed(1)}% OFF';
                }

                return GestureDetector(
                  onTap: () {
                    // Navigate to the Product Detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          categoryId: product.categoryId,
                          subcategoryId: product.subcategoryId,
                          productId: product.id,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                "https://plant-world.actthost.com/uploads/products/${product.image}",
                                fit: BoxFit.cover,
                                height: 130,
                                width: double.infinity,
                              ),
                            ),
                            if (discountText.isNotEmpty)
                              Positioned(
                                left: 8,
                                top: 12,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    discountText,
                                    style: TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: Icon(Icons.favorite_border, color: Colors.red),
                                onPressed: () {
                                  // Add to wishlist functionality
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                product.name,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '\$${product.discountedPrice}',
                                style: TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                              if (discountedPrice != null)
                                Text(
                                  '\$${product.price}',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.red, decoration: TextDecoration.lineThrough),
                                ),
                              SizedBox(height: 4),
                              Text(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                product.catName,
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
