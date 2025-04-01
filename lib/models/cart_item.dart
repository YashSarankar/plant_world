class CartItem {
  final int id;
  final int userId;
  final int productId;
  final double price;
  final double mrp;
  final double discount;
  final double total;
  final int quantity;
  final String name;
  final String image;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.price,
    required this.mrp,
    required this.discount,
    required this.total,
    required this.quantity,
    required this.name,
    required this.image,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      userId: json['userid'] is String ? int.parse(json['userid']) : json['userid'],
      productId: json['productid'] is String ? int.parse(json['productid']) : json['productid'],
      price: json['price'] is String ? double.parse(json['price']) : json['price'].toDouble(),
      mrp: json['mrp'] is String ? double.parse(json['mrp']) : json['mrp'].toDouble(),
      discount: json['discount'] is String ? double.parse(json['discount']) : json['discount'].toDouble(),
      total: json['total'] is String ? double.parse(json['total']) : json['total'].toDouble(),
      quantity: json['quantity'] is String ? int.parse(json['quantity']) : json['quantity'],
      name: json['name'],
      image: json['image'],
    );
  }
} 