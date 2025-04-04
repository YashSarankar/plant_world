import 'dart:async';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class PaymentService {
  late Razorpay _razorpay;
  Function(String)? onPaymentSuccessCallback; // Callback for payment success with payment ID
  Function(String)? onPaymentErrorCallback; // Callback for payment error with error message

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout(
    BuildContext context, 
    double amount, 
    String description,
    Function(String) onSuccess,
    Function(String) onError
  ) async {
    // Set callbacks
    onPaymentSuccessCallback = onSuccess;
    onPaymentErrorCallback = onError;
    
    // Get user details from SharedPreferences if available
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');
    final String? phone = prefs.getString('phone');
    final String? name = prefs.getString('name');
    
    var options = {
      'key': 'rzp_test_0klLyBUlTUrsxb', // Replace with your Razorpay key
      'amount': (amount * 100).toInt().toString(), // Amount in paise
      'currency': 'INR',
      'name': 'Plant World',
      'description': description,
      'prefill': {
        'contact': phone ?? '',
        'email': email ?? '',
        'name': name ?? '',
      },
      'theme': {
        'color': '#4CAF50', // Green color for theme
      },
    };
    
    try {
      _razorpay.open(options);
    } catch (e) {
      onError("Error opening payment gateway: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (onPaymentSuccessCallback != null && response.paymentId != null) {
      onPaymentSuccessCallback!(response.paymentId!);
      print("Payment Success: ${response.paymentId}");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (onPaymentErrorCallback != null) {
      String errorMessage = "Payment Failed";
      
      if (response.code == Razorpay.PAYMENT_CANCELLED) {
        errorMessage = "Payment was cancelled";
      } else if (response.code == Razorpay.NETWORK_ERROR) {
        errorMessage = "Network error occurred";
      } else {
        errorMessage = "Payment Error: ${response.message ?? 'Unknown error'}";
      }
      
      onPaymentErrorCallback!(errorMessage);
    }
    print("Payment Error: ${response.code} - ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: ${response.walletName}");
  }

  void dispose() {
    _razorpay.clear();
  }

  Future<String> getPaymentStatus(String paymentId) async {
    return "Payment Status"; // Replace with actual status
  }
} 
