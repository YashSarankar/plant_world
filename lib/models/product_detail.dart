class ProductDetail {
  final int id;
  final String name;
  final int categoryId;
  final int subcategoryId;
  final String image;
  final String otherImage;
  final String description;
  final String shortDesc;
  final int status;
  final String productCode;
  final String price;
  final String discountedPrice;
  final int? stone;
  final String? weight;
  final int isFeature;
  final String catName;
  final String subcatName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String cname;

  ProductDetail({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.subcategoryId,
    required this.image,
    required this.otherImage,
    required this.description,
    required this.shortDesc,
    required this.status,
    required this.productCode,
    required this.price,
    required this.discountedPrice,
    this.stone,
    this.weight,
    required this.isFeature,
    required this.catName,
    required this.subcatName,
    required this.createdAt,
    required this.updatedAt,
    required this.cname,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'],
      name: json['name'],
      categoryId: json['category_id'],
      subcategoryId: json['subcategory_id'],
      image: json['image'],
      otherImage: json['other_image'],
      description: json['description'],
      shortDesc: json['short_desc'],
      status: json['status'],
      productCode: json['product_code'],
      price: json['price'],
      discountedPrice: json['discounted_price'],
      stone: json['stone'],
      weight: json['weight'],
      isFeature: json['is_feature'],
      catName: json['cat_name'],
      subcatName: json['subcat_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      cname: json['cname'],
    );
  }
} 