class OrderResponse {
  final bool error;
  final List<Order> data;

  OrderResponse({
    required this.error,
    required this.data,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      error: json['error'] ?? false,
      data: json['data'] != null 
          ? (json['data'] is List 
              ? (json['data'] as List).map((item) => Order.fromJson(item)).toList()
              : [])
          : [],
    );
  }
}

class Order {
  final int id;
  final int userId;
  final String orderId;
  final String prodId;
  final String productName;
  final String image;
  final String? variant;
  final int? quantity;
  final double price;
  final double discountedPrice;
  final double subTotal;
  final String status;
  final String activeStatus;
  final String month;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.prodId,
    required this.productName,
    required this.image,
    this.variant,
    this.quantity,
    required this.price,
    required this.discountedPrice,
    required this.subTotal,
    required this.status,
    required this.activeStatus,
    required this.month,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      orderId: json['order_id'],
      prodId: json['prodid'],
      productName: json['productname'],
      image: json['image'],
      variant: json['variant'],
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      discountedPrice: double.parse(json['discounted_price'].toString()),
      subTotal: double.parse(json['sub_total'].toString()),
      status: json['status'],
      activeStatus: json['active_status'],
      month: json['month'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
} 