import 'dart:async';
import 'package:flutter/material.dart';
import 'package:new_project/screens/main_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/api_service.dart';
import '../models/cart_item.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:new_project/screens/checkout_screen.dart';
import '../services/payment_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<CartItem>> _cartItems;
  Map<int, int> _quantities = {};
  double _total = 0;
  bool _showSwipeHint = false;
  PaymentService _paymentService = PaymentService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cartItems = Future.value([]); // Initialize with an empty Future
    _loadCart();
    _checkFirstTime();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenHint = prefs.getBool('has_seen_swipe_hint') ?? false;
    setState(() {
      _showSwipeHint = !hasSeenHint;
    });
  }

  void _dismissHint() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_swipe_hint', true);
    setState(() {
      _showSwipeHint = false;
    });
  }

  Future<void> _loadCart() async {
    try {
      final items = await _apiService.getCart();
      
      if (mounted) {
        setState(() {
          _cartItems = Future.value(items);
          if (items.isEmpty) {
            _total = 0;
          } else {
            _calculateTotal(items);
          }
        });
      }
    } catch (e) {
      // Handle the error when the API response isn't a list
      if (mounted) {
        setState(() {
          _cartItems = Future.value([]);
          _total = 0;
        });
        
        print("Error fetching cart: $e");
      }
    }
  }

  void _calculateTotal(List<CartItem> items) {
    _total = items.fold(0, (sum, item) {
      final quantity = _quantities[item.id] ?? item.quantity;
      return sum + (item.price * quantity);
    });
  }

  void _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity <= 0) return; // Don't allow quantity less than 1
    
    setState(() {
      _isLoading = true; // Show loading state
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id') ?? 0;
      
      // Call the API to update the quantity
      final success = await _apiService.updateCartItemQuantity(
        userId, 
        item.productId, 
        newQuantity
      );
      
      if (success) {
        // If API call was successful, update the local state
        setState(() {
          _quantities[item.id] = newQuantity;
          // Recalculate total
          _cartItems.then((items) {
            _calculateTotal(items);
          });
          _isLoading = false;
        });
        
        // Reload cart to get updated data from server
        _loadCart();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quantity updated successfully'),
            backgroundColor: Colors.green[700],
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        // If API call failed, show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update quantity'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle any exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDismissed(CartItem item) {
    // Immediately remove the item from the local list to prevent the "dismissed widget still in tree" error
    setState(() {
      _cartItems = _cartItems.then((items) {
        return items.where((cartItem) => cartItem.id != item.id).toList();
      });
    });
    
    // Then delete from backend
    _deleteItem(item);
  }

  Future<void> _deleteItem(CartItem item) async {
    // Store a reference to the scaffold messenger before any async operations
    final scaffoldMessenger = mounted ? ScaffoldMessenger.of(context) : null;
    
    try {
      await _apiService.deleteCartItem(item.productId);
      
      // Check if mounted before updating state
      if (mounted) {
        // Reload cart data
        final updatedItems = await _apiService.getCart();
        
        setState(() {
          _cartItems = Future.value(updatedItems);
          if (updatedItems.isEmpty) {
            _total = 0; // Reset total if cart is empty
          } else {
            _calculateTotal(updatedItems);
          }
        });
      }
    } catch (e) {
      // Only show error if still mounted and scaffoldMessenger was obtained
      if (mounted && scaffoldMessenger != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete item: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.green[700],
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.withOpacity(0.15),
          ),
        ),
      ),
      body: _isLoading
        ? Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
            ),
          )
        : FutureBuilder<List<CartItem>>(
            future: _cartItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Error loading cart',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadCart,
                        child: Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyCart();
              } else {
                return _buildCartList(snapshot.data!);
              }
            },
          ),
    );
  }

  Widget _buildEmptyCart() {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[100],
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Your Cart is Empty',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Looks like you haven\'t added\nanything to your cart yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen())
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Continue Shopping',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartList(List<CartItem> cartItems) {
    return Column(
      children: [
        if (_showSwipeHint && cartItems.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Swipe Gestures',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      icon: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      onPressed: _dismissHint,
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.swipe_left_alt,
                      color: Colors.red.shade400,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Swipe left to remove items from cart',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.swipe_right_alt,
                      color: Colors.green.shade700,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Swipe right to quickly place an order',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              final currentQuantity = _quantities[item.id] ?? item.quantity;
              return Dismissible(
                key: Key(item.id.toString()),
                direction: DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    bool? result = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(
                            'Remove Item',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to remove this item from your cart?',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(
                                'Remove',
                                style: TextStyle(
                                  color: Colors.red[400],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    return result ?? false;
                  } else {
                    bool? result = await _showOrderConfirmation(item);
                    return result ?? false;
                  }
                },
                onDismissed: (_) => _onDismissed(item),
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20.0),
                  color: Colors.green[600],
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                  ),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.0),
                  color: Colors.red[400],
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                  ),
                ),
                child: Card(
                  elevation: 1,
                  margin: EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                'https://skm-mart.actthost.com/uploads/products/${item.image}',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                '₹${(item.price * currentQuantity).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildQuantityButton(
                                        icon: Icons.remove,
                                        onPressed: () => _updateQuantity(item, currentQuantity - 1),
                                      ),
                                      Container(
                                        width: 32,
                                        child: Text(
                                          '$currentQuantity',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      _buildQuantityButton(
                                        icon: Icons.add,
                                        onPressed: () => _updateQuantity(item, currentQuantity + 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(12, 8, 12, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal:',
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            ),
                            Text(
                              '₹${_total.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Delivery:',
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            ),
                            Text(
                              'FREE',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${_total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutScreen(
                                  cartItems: cartItems,
                                  total: _total,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            minimumSize: Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 14,
          color: Colors.green.shade700,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(CartItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Remove Item',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to remove this item from your cart?',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(item);
              },
              child: Text(
                'Remove',
                style: TextStyle(
                  color: Colors.red[400],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showOrderConfirmation(CartItem item) async {
    // Store a reference to the scaffold messenger before any async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('id') ?? 0;
    
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Order'),
          content: Text('Do you want to place an order for ${item.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog first
                Navigator.of(context).pop(true);
                
                try {
                  // Process payment
                  final paymentId = await _processPayment(item);
                  
                  if (paymentId == null) {
                    // Payment failed or was cancelled
                    return; // Just return without a value
                  }
                  
                  // Submit order with the payment ID
                  final success = await _apiService.submitOrder(userId, item.productId, paymentId);
                  
                  if (success) {
                    // Just reload the cart to refresh the data
                    _loadCart();
                    
                    // Show success message
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Order placed successfully!'),
                        backgroundColor: Colors.green[700],
                      ),
                    );
                  }
                  // No return value needed
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to place order: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  // No return value needed
                }
              },
              child: Text(
                'Place Order',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }

  Future<String?> _processPayment(CartItem item) async {
    Completer<String?> completer = Completer<String?>();
    
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.green[700],
            ),
          );
        },
      );
      
      // Process payment with callbacks
      _paymentService.openCheckout(
        context, 
        item.price,
        item.name,
        (String paymentId) {
          // Close loading dialog
          Navigator.pop(context);
          completer.complete(paymentId);
        },
        (String errorMessage) {
          // Close loading dialog if still showing
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
          completer.complete(null); // Complete with null to indicate failure
        }
      );
    } catch (error) {
      // Close loading dialog if still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
      completer.complete(null); // Complete with null to indicate failure
    }
    
    return completer.future;
  }
}