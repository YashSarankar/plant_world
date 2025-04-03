class FeaturedProduct {
  final int id;
  final String name;
  final String description;
  final String shortDesc;
  final String image;
  final String productCode;
  final String price;
  final String discountedPrice;
  final String? weight; // Nullable since it can be null
  final String? stone; // Nullable since it can be null
  final String catName;
  final String subcatName;
  final int categoryId;
  final int subcategoryId;

  FeaturedProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.shortDesc,
    required this.image,
    required this.productCode,
    required this.price,
    required this.discountedPrice,
    this.weight,
    this.stone,
    required this.catName,
    required this.subcatName,
    required this.categoryId,
    required this.subcategoryId,
  });

  factory FeaturedProduct.fromJson(Map<String, dynamic> json) {
    return FeaturedProduct(
      id: int.tryParse(json['id'].toString()) ?? 0, // Convert to int safely
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? 'No description available',
      shortDesc: json['short_desc'] ?? 'No short description available',
      image: json['image'] ?? 'default_image.png',
      productCode: json['product_code'] ?? 'N/A',
      price: json['price']?.toString() ?? '0', // Convert int to String if necessary
      discountedPrice: json['discounted_price']?.toString() ?? '0', // Convert int to String if necessary
      weight: json['weight']?.toString(),
      stone: json['stone']?.toString(),
      catName: json['cat_name'] ?? 'Unknown Category',
      subcatName: json['subcat_name'] ?? 'Unknown Subcategory',
      categoryId: int.tryParse(json['category_id'].toString()) ?? 0, // Convert to int safely
      subcategoryId: int.tryParse(json['subcategory_id'].toString()) ?? 0, // Convert to int safely
    );
  }
}