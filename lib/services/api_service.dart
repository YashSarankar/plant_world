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
import '../models/featured_product.dart';
import '../models/all_product.dart';

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
    final response = await http.post(Uri.parse('$_baseUrl/ProductBySubCategorieId?category_id=$subCategoryId'));

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
    try {
      print('Fetching product with ID: $id, categoryId: $categoryId, subcategoryId: $subcategoryId');
      
      // Ensure all parameters are valid integers
      final validCategoryId = categoryId > 0 ? categoryId : 0;
      final validSubcategoryId = subcategoryId > 0 ? subcategoryId : 0;
      final validProductId = id > 0 ? id : 0;
      
      final response = await http.post(
        Uri.parse('$_baseUrl/ProductById?category_id=$validCategoryId&subcategory_id=$validSubcategoryId&id=$validProductId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: ${response.body}');
        
        if (!data['error'] && data['product'] != null && (data['product'] as List).isNotEmpty) {
          // Add null safety checks when creating the ProductDetail object
          final productData = data['product'][0];
          
          // Check if any required fields are null before parsing
          if (productData == null) {
            throw Exception('Product data is null');
          }
          
          try {
            return ProductDetail.fromJson(productData);
          } catch (e) {
            print('Error parsing product data: $e');
            throw Exception('Error parsing product data: $e');
          }
        } else {
          throw Exception('Product not found or empty product data');
        }
      } else {
        throw Exception('Failed to load product details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchProductById: $e');
      throw Exception('Failed to load product: $e');
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
    final int userId = prefs.getInt('id') ?? 0;

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
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id') ?? 0;
      
      final response = await http.post(
        Uri.parse('$_baseUrl/getCart'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Check if the response contains cart items
        if (response.body.isNotEmpty && response.body != '[]') {
          final data = json.decode(response.body);
          if (!data['error'] && data.containsKey('data') && data['data'] != null) {
            // If data is a list, process it normally
            if (data['data'] is List) {
              return (data['data'] as List)
                  .map((item) => CartItem.fromJson(item))
                  .toList();
            } else {
              // If data is not a list, return an empty list
              return [];
            }
          } else {
            // If there's no data or it's null, return an empty list
            return [];
          }
        } else {
          // If the response body is empty, return an empty list
          return [];
        }
      } else {
        throw Exception('Failed to load cart');
      }
    } catch (e) {
      print('Error fetching cart count: $e');
      // Return an empty list on error
      return [];
    }
  }

  Future<void> deleteCartItem(int productId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('id') ?? 0;
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

  Future<bool> submitOrder(int userId, int productId, String paymentId) async {
    final response = await http.post(
      Uri.parse('https://plant-world.actthost.com/api/submitOrderData'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'product_id': productId,
        'payment_id': paymentId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['error']) {
        throw Exception('Failed to submit order: ${data['message']}');
      }
      return true; // Return true to indicate success
    } else {
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

  // New method to fetch featured products
  static Future<List<FeaturedProduct>> fetchFeaturedProducts() async {
    final response = await http.post(Uri.parse('$_baseUrl/getFeatureProduct'));

    if (response.statusCode == 200||response.statusCode == 201) {
      final data = json.decode(response.body);
      if (!data['error']) {
        List<FeaturedProduct> products = (data['product'] as List)
            .map((item) => FeaturedProduct.fromJson(item))
            .toList();
        return products;
      } else {
        throw Exception('Failed to load featured products');
      }
    } else {
      throw Exception('Failed to load featured products');
    }
  }

  static Future<AllProduct> fetchAllProducts() async {
    final response = await http.post(Uri.parse('$_baseUrl/AllProduct'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (!data['error']) {
        return AllProduct.fromJson(data);
      } else {
        throw Exception('Failed to load products');
      }
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<bool> updateCartItemQuantity(int userId, int productId, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/updateCart'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': userId.toString(),
          'product_id': productId.toString(),
          'quantity': quantity.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!data['error']) {
          return true;
        }
        return false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error updating cart quantity: $e');
      return false;
    }
  }
}