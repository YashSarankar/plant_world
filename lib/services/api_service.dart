import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import '../models/product.dart';
import '../models/product_detail.dart';
import '../models/wishlist_item.dart';
import '../models/cart_item.dart';
import '../models/slider.dart';
import '../models/order_model.dart';

class ApiService {
  static const String _baseUrl = 'https://plant-world.actthost.com/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> register(
    String fullname,
    String email,
    String mobile,
    String password,
    String state,
    String city,
    String pincode,
    String address,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/userregister'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fullname': fullname,
        'email': email,
        'phone': mobile,
        'password': password,
        'state': state,
        'city': city,
        'pincode': pincode,
        'address': address,
      }),
    );

    if (response.statusCode == 200||response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to register');
    }
  }
  
  Future<bool> updateProfile(String userId, String fullName, String email, String city, String state, String pincode, String address, String phone) async {
    final Map<String, dynamic> data = {
      "user_id": userId,
      "full_name": fullName,
      "email": email,
      "city": city,
      "state": state,
      "pincode": pincode,
      "address": address,
      "phone": phone,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/updateProfile'),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(data),
    );
    return response.statusCode == 200;
  }

  // Method to fetch categories with subcategory counts
  static Future<List<Category>> fetchCategories() async {
    final response = await http.post(Uri.parse('$_baseUrl/categorie'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (!data['error']) {
        List<Category> categories = (data['data'] as List)
            .map((categoryJson) => Category.fromJson(categoryJson))
            .toList();

        // Fetch subcategory counts for each category
        for (var category in categories) {
          try {
            List<SubCategory> subCategories = await fetchSubCategories(category.id);
            category.subCategoryCount = subCategories.length;
          } catch (e) {
            print('Error fetching subcategories for category ${category.id}: $e');
            category.subCategoryCount = 0;
          }
        }

        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Method to fetch subcategories
  static Future<List<SubCategory>> fetchSubCategories(int categoryId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/subcategorie?category_id=$categoryId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((subCategory) => SubCategory.fromJson(subCategory)).toList();
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load subcategories');
    }
  }

  Future<List<Product>> fetchProductsBySubCategory(int subCategoryId) async {
    final response = await http.post(Uri.parse('https://skm-mart.actthost.com/api/ProductBySubCategorieId?category_id=$subCategoryId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (!data['error']) {
        return (data['product'] as List)
            .map((productJson) => Product.fromJson(productJson))
            .toList();
      } else {
        throw Exception('Failed to load products');
      }
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<ProductDetail> fetchProductById(int categoryId, int subcategoryId, int id) async {
    final response = await http.post(
      Uri.parse('https://skm-mart.actthost.com/api/ProductById?category_id=$categoryId&subcategory_id=$subcategoryId&id=$id'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (!data['error']) {
        return ProductDetail.fromJson(data['product'][0]);
      } else {
        throw Exception('Failed to load product details');
      }
    } else {
      throw Exception('Failed to load product details');
    }
  }

  Future<void> addToWishlist(int userId, int productId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/addWishlist'), // Replace with your actual base URL
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'product_id': productId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['error']) {
        throw Exception('Failed to add to wishlist');
      }
    } else {
      throw Exception('Failed to add to wishlist');
    }
  }

  Future<void> removeFromWishlist(int userId, int productId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/removewishlist'), // Replace with your actual base URL
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'product_id': productId,
      }),
    );

    // Log the response for debugging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['error']) {
        throw Exception('Failed to remove from wishlist');
      }
    } else {
      throw Exception('Failed to remove from wishlist');
    }
  }

  Future<List<WishlistItem>> getWishlist(int userId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/getWishlist'), // Replace with your actual base URL
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (!data['error']) {
        if (data['data'] == null || (data['data'] as List).isEmpty) {
          return []; // Return an empty list if no items found
        }
        return (data['data'] as List)
            .map((itemJson) => WishlistItem.fromJson(itemJson))
            .toList(); // Convert each item to WishlistItem
      } else {
        throw Exception('Failed to load wishlist: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load wishlist: ${response.statusCode}');
    }
  }

  Future<void> addToCart(int productId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('user_id') ?? 1;

    final response = await http.post(
      Uri.parse('$_baseUrl/addCart'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'product_id': productId,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['error']) {
        throw Exception('Failed to add to cart: ${responseData['message']}');
      }
    } else {
      throw Exception('Server error. Please try again later.');
    }
  }

  Future<List<CartItem>> getCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('user_id') ?? 1;

    final response = await http.post(
      Uri.parse('$_baseUrl/getCart'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user_id': userId}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (!data['error']) {
        return (data['data'] as List)
            .map((itemJson) => CartItem.fromJson(itemJson))
            .toList();
      } else {
        throw Exception('Failed to load cart: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load cart');
    }
  }

  Future<void> deleteCartItem(int productId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('user_id') ?? 1;

    final response = await http.post(
      Uri.parse('$_baseUrl/deleteCart'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'product_id': productId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['error']) {
        throw Exception('Failed to delete item: ${data['message']}');
      }
    } else {
      throw Exception('Failed to delete item');
    }
  }

  static Future<List<SliderModel>> fetchSliders() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sliders'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (!data['error']) {
          return (data['data'] as List)
              .map((slider) => SliderModel.fromJson(slider))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching sliders: $e');
      return [];
    }
  }

  Future<List<dynamic>> getNotifications(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/getnotifications'),
        body: {
          'user_id': userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Debugging: Print the response data to check its structure
        print('Response data: $data');

        // Check if the response indicates success
        if (!data['error'] && data['notification'] != null && data['notification'].isNotEmpty) {
          return data['notification'];
        } else {
          // Return an empty list if no notifications
          return [];
        }
      } else {
        throw Exception('Failed to load notifications. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  Future<void> submitOrder(int userId, int productId, int paymentId) async {
    final response = await http.post(
      Uri.parse('https://plant-world.actthost.com/api/submitOrderData'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'product_id': productId,
        'payment_id': paymentId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit order: ${response.body}');
    }
  }

  Future<OrderResponse> getOrders(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('https://plant-world.actthost.com/api/getOrderData'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        return OrderResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }
} 