class WishlistItem {
  final int id;
  final String userId;
  final String productId;
  final String name;
  final String mrpPrice;
  final String discountedPrice;
  final String? weight; // Weight can be null
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isAvailable;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.name,
    required this.mrpPrice,
    required this.discountedPrice,
    this.weight,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.isAvailable,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'],
      userId: json['userid'],
      productId: json['productid'],
      name: json['name'],
      mrpPrice: json['MRP_Price'],
      discountedPrice: json['discounted_price'],
      weight: json['weight'],
      image: json['image'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isAvailable: json['isAvailable'] ?? true,
    );
  }
} 