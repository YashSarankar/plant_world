class FeaturedProduct {
  final int? id;
  final String? name;
  final String? description;
  final String? shortDesc;
  final String? image;
  final String? productCode;
  final String? price;
  final String? discountedPrice;
  final String? weight;
  final String? stone;
  final String? catName;
  final String? subcatName;
  final int? categoryId;
  final int? subcategoryId;

  FeaturedProduct({
    this.id,
    this.name,
    this.description,
    this.shortDesc,
    this.image,
    this.productCode,
    this.price,
    this.discountedPrice,
    this.weight,
    this.stone,
    this.catName,
    this.subcatName,
    this.categoryId,
    this.subcategoryId,
  });

  factory FeaturedProduct.fromJson(Map<String, dynamic> json) {
    return FeaturedProduct(
      id: int.tryParse(json['id']?.toString() ?? ''),
      name: json['name'],
      description: json['description'],
      shortDesc: json['short_desc'],
      image: json['image'],
      productCode: json['product_code'],
      price: json['price']?.toString(),
      discountedPrice: json['discounted_price']?.toString(),
      weight: json['weight']?.toString(),
      stone: json['stone']?.toString(),
      catName: json['cat_name'],
      subcatName: json['subcat_name'],
      categoryId: int.tryParse(json['category_id']?.toString() ?? ''),
      subcategoryId: int.tryParse(json['subcategory_id']?.toString() ?? ''),
    );
  }
}