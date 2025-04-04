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
  final String? stone;
  final String? weight;
  final int isFeature;
  final String catName;
  final String subcatName;
  final String createdAt;
  final String updatedAt;
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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      categoryId: int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      subcategoryId: int.tryParse(json['subcategory_id']?.toString() ?? '0') ?? 0,
      image: json['image'] ?? '',
      otherImage: json['other_image'] ?? '',
      description: json['description'] ?? '',
      shortDesc: json['short_desc'] ?? '',
      status: int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      productCode: json['product_code'] ?? '',
      price: json['price'] ?? '0',
      discountedPrice: json['discounted_price'] ?? '0',
      stone: json['stone']?.toString(),
      weight: json['weight']?.toString(),
      isFeature: int.tryParse(json['is_feature']?.toString() ?? '0') ?? 0,
      catName: json['cat_name'] ?? '',
      subcatName: json['subcat_name'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      cname: json['cname'] ?? '',
    );
  }
} 