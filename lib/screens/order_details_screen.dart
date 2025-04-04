import 'package:flutter/material.dart';
import '../models/order_model.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text('Order Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
        backgroundColor: Colors.green[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Timeline
            _buildOrderStatusTimeline(context),
            
            SizedBox(height: 12),
            
            // Order ID and Date
            _buildOrderInfoCard(context),
            
            SizedBox(height: 12),
            
            // Product Details
            _buildProductDetailsCard(context),
            
            SizedBox(height: 12),
            
            // Order Summary
            _buildOrderSummaryCard(context),
            
            SizedBox(height: 12),
            
            // Payment Information
            _buildPaymentInfoCard(context),
            
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusTimeline(BuildContext context) {
    // Use the exact labels from the screenshot
    final statusSteps = ['Order Placed', 'Processing', 'Shipped', 'Delivered'];
    int currentStep = 0;
    
    // Determine current step based on activeStatus
    switch (order.activeStatus.toLowerCase()) {
      case 'pending':
        currentStep = 0;
        break;
      case 'received':
        currentStep = 1;
        break;
      case 'confirm':
      case 'confirmed':
        currentStep = 2;
        break;
      case 'delivered':
        currentStep = 3;
        break;
      default:
        currentStep = 0;
    }
    
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 30),
          
          // First row: Circles with icons
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Order Placed circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.receipt_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              
              // Line between Order Placed and Processing
              Expanded(
                child: Container(
                  height: 3,
                  color: currentStep > 0 ? Colors.green[700] : Colors.grey[300],
                ),
              ),
              
              // Processing circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: currentStep >= 1 ? Colors.green[700] : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.assignment_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              
              // Line between Processing and Shipped
              Expanded(
                child: Container(
                  height: 3,
                  color: currentStep > 1 ? Colors.green[700] : Colors.grey[300],
                ),
              ),
              
              // Shipped circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: currentStep >= 2 ? Colors.green[700] : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              
              // Line between Shipped and Delivered
              Expanded(
                child: Container(
                  height: 3,
                  color: currentStep > 2 ? Colors.green[700] : Colors.grey[300],
                ),
              ),
              
              // Delivered circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: currentStep >= 3 ? Colors.green[700] : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.home_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 4),
          
          // Second row: Labels with shorter text
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Order Placed label
              Container(
                width: 50,
                child: Text(
                  'Ordered',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              Expanded(child: SizedBox()),
              
              // Processing label
              Container(
                width: 50,
                child: Text(
                  'Process',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: currentStep >= 1 ? FontWeight.w500 : FontWeight.normal,
                    color: currentStep >= 1 ? Colors.green[700] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              Expanded(child: SizedBox()),
              
              // Shipped label
              Container(
                width: 50,
                child: Text(
                  'Shipped',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: currentStep >= 2 ? FontWeight.w500 : FontWeight.normal,
                    color: currentStep >= 2 ? Colors.green[700] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              Expanded(child: SizedBox()),
              
              // Delivered label
              Container(
                width: 50,
                child: Text(
                  'Delivered',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: currentStep >= 3 ? FontWeight.w500 : FontWeight.normal,
                    color: currentStep >= 3 ? Colors.green[700] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.orderId}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        _formatDate(order.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildStatusBadge(order.activeStatus),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Product Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Qty: ${order.quantity ?? 1}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://plant-world.actthost.com/uploads/products/${order.image}',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.productName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Product ID: ${order.prodId}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    if (order.variant != null && order.variant!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Variant: ${order.variant}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '₹${order.discountedPrice}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green[800],
                          ),
                        ),
                        SizedBox(width: 8),
                        if (order.price != order.discountedPrice)
                          Text(
                            '₹${order.price}',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context) {
    final discount = order.price - order.discountedPrice;
    final totalAmount = order.subTotal > 0 ? order.subTotal : order.discountedPrice * (order.quantity ?? 1);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          _buildSummaryRow('Price (${order.quantity ?? 1} item)', '₹${order.price}'),
          if (discount > 0)
            _buildSummaryRow(
              'Discount',
              '- ₹$discount',
              valueColor: Colors.green[700],
            ),
          _buildSummaryRow('Delivery', 'Free', valueColor: Colors.green[700]),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey[300]),
          ),
          _buildSummaryRow(
            'Total Amount',
            '₹$totalAmount',
            isBold: true,
          ),
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green[100]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.savings_outlined, color: Colors.green[700], size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      discount > 0
                          ? 'You saved ₹$discount on this order'
                          : 'Free delivery on this order',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getPaymentIcon(),
                  color: Colors.grey[700],
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPaymentMethodName(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      order.status,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PAID',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName() {
    if (order.status.toLowerCase().contains('cod')) {
      return 'Cash on Delivery';
    } else if (order.status.toLowerCase().contains('razor')) {
      return 'Razorpay';
    } else {
      return 'Online Payment';
    }
  }

  IconData _getPaymentIcon() {
    if (order.status.toLowerCase().contains('cod')) {
      return Icons.payments_outlined;
    } else if (order.status.toLowerCase().contains('razor')) {
      return Icons.credit_card;
    } else {
      return Icons.account_balance_wallet_outlined;
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'delivered':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'confirmed':
      case 'confirm':
        color = Colors.blue;
        icon = Icons.check_circle_outline;
        break;
      case 'received':
        color = Colors.orange;
        icon = Icons.inventory_outlined;
        break;
      case 'pending':
        color = Colors.amber;
        icon = Icons.hourglass_empty;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.green[800]!;
        icon = Icons.check;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: valueColor ?? (isBold ? Colors.green[800] : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
} 