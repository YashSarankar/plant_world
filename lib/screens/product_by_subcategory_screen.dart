import 'package:flutter/material.dart';
import 'package:new_project/services/api_service.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product.dart'; // Import the Product model
import '../screens/product_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts for better typography
import 'package:shimmer/shimmer.dart'; // Import for loading effects
import 'package:shared_preferences/shared_preferences.dart'; // Import for shared preferences

class ProductBySubCategoryScreen extends StatefulWidget {
  final int subCategoryId;
  final String categoryName;

  ProductBySubCategoryScreen({required this.subCategoryId, required this.categoryName});

  @override
  _ProductBySubCategoryScreenState createState() => _ProductBySubCategoryScreenState();
}

class _ProductBySubCategoryScreenState extends State<ProductBySubCategoryScreen> {
  late Future<List<Product>> _products;
  List<Product> _loadedProducts = [];
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _sortBy = 'Default';
  
  // Filter options
  RangeValues _priceRange = RangeValues(0, 10000);
  double _maxPrice = 10000;
  
  // Search functionality
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  int userId = 0; // Declare userId variable

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadProducts();
  }

  void _loadUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id') ?? 0; // Assign the userId from shared preferences
  }

  //take user id from shared preferences


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final products = await _apiService.fetchProductsBySubCategory(widget.subCategoryId);
      final wishlistItems = await _apiService.getWishlist(userId);
      final wishlistProductIds = wishlistItems.map((item) => item.productId).toSet();

      setState(() {
        _loadedProducts = products;
        for (var product in _loadedProducts) {
          product.isFavorited = wishlistProductIds.contains(product.id);
        }
        _isLoading = false;
      });
      
      _determineMaxPrice();
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _determineMaxPrice() {
    try {
      if (_loadedProducts.isNotEmpty) {
        double maxPrice = 0;
        for (var product in _loadedProducts) {
          double price = double.parse(product.discountedPrice);
          if (price > maxPrice) maxPrice = price;
        }
        setState(() {
          _maxPrice = maxPrice + 100; // Add buffer
          _priceRange = RangeValues(0, _maxPrice);
        });
      }
    } catch (e) {
      print('Error determining max price: $e');
    }
    return Future.value();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.green[800],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Products',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Price Range',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${_priceRange.start.toInt()}'),
                      Text('₹${_priceRange.end.toInt()}'),
                    ],
                  ),
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: _maxPrice,
                  divisions: 100,
                  labels: RangeLabels(
                    '₹${_priceRange.start.toInt()}',
                    '₹${_priceRange.end.toInt()}',
                  ),
                  onChanged: (RangeValues values) {
                    setModalState(() {
                      _priceRange = values;
                    });
                  },
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _priceRange = RangeValues(0, _maxPrice);
                            });
                          },
                          child: Text('Reset'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Apply filters is now handled in the build method
                            });
                            Navigator.pop(context);
                          },
                          child: Text('Apply'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[800],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Product> _sortProducts(List<Product> products) {
    switch (_sortBy) {
      case 'Price: Low to High':
        products.sort((a, b) => double.parse(a.discountedPrice).compareTo(double.parse(b.discountedPrice)));
        break;
      case 'Price: High to Low':
        products.sort((a, b) => double.parse(b.discountedPrice).compareTo(double.parse(a.discountedPrice)));
        break;
      case 'Name: A to Z':
        products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Name: Z to A':
        products.sort((a, b) => b.name.compareTo(a.name));
        break;
      default:
        // Default sorting (no sorting)
        break;
    }
    return products;
  }

  Widget _buildProductShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.65,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 14,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 10,
                        color: Colors.white,
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: 80,
                        height: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search products...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => setState(() => _searchQuery = query),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            if (_searchController.text.isEmpty) {
              _toggleSearch();
              return;
            }
            _searchController.clear();
            setState(() => _searchQuery = '');
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(
        icon: Icon(Icons.search, color: Colors.white),
        onPressed: _toggleSearch,
      ),
    ];
  }

  Widget _buildAppBarTitle() {
    return _isSearching
        ? _buildSearchField()
        : Text(
            widget.categoryName,
            style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (_isSearching) {
              _toggleSearch();
            } else {
              Navigator.pop(context);
            }
          },
          icon: Icon(_isSearching ? Icons.arrow_back : Icons.arrow_back, color: Colors.white),
        ),
        title: _buildAppBarTitle(),
        backgroundColor: Colors.green[800],
        actions: _buildAppBarActions(),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Sort By',
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Divider(),
                              ListTile(
                                title: Text('Default'),
                                trailing: _sortBy == 'Default' ? Icon(Icons.check, color: Colors.green[800]) : null,
                                onTap: () {
                                  setState(() {
                                    _sortBy = 'Default';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text('Price: Low to High'),
                                trailing: _sortBy == 'Price: Low to High' ? Icon(Icons.check, color: Colors.green[800]) : null,
                                onTap: () {
                                  setState(() {
                                    _sortBy = 'Price: Low to High';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text('Price: High to Low'),
                                trailing: _sortBy == 'Price: High to Low' ? Icon(Icons.check, color: Colors.green[800]) : null,
                                onTap: () {
                                  setState(() {
                                    _sortBy = 'Price: High to Low';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text('Name: A to Z'),
                                trailing: _sortBy == 'Name: A to Z' ? Icon(Icons.check, color: Colors.green[800]) : null,
                                onTap: () {
                                  setState(() {
                                    _sortBy = 'Name: A to Z';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text('Name: Z to A'),
                                trailing: _sortBy == 'Name: Z to A' ? Icon(Icons.check, color: Colors.green[800]) : null,
                                onTap: () {
                                  setState(() {
                                    _sortBy = 'Name: Z to A';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.sort, size: 20, color: Colors.grey[700]),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Sort: $_sortBy',
                            style: TextStyle(color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: InkWell(
                    onTap: _showFilterBottomSheet,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_list, size: 20, color: Colors.grey[700]),
                        SizedBox(width: 4),
                        Text(
                          'Filter',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: _isLoading
                  ? _buildProductShimmer()
                  : Builder(
                      builder: (context) {
                        if (_loadedProducts.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_basket, size: 60, color: Colors.grey[400]),
                                SizedBox(height: 16),
                                Text(
                                  'No products found in this category',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        }

                        var products = _sortProducts(List.from(_loadedProducts));
                        
                        // Apply search filter if search query exists
                        if (_searchQuery.isNotEmpty) {
                          products = products.where((product) => 
                            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            product.catName.toLowerCase().contains(_searchQuery.toLowerCase())
                          ).toList();
                          
                          // Show no results for search
                          if (products.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                                  SizedBox(height: 16),
                                  Text(
                                    'No products match your search',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                      });
                                    },
                                    child: Text('Clear Search'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[800],
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                        
                        // Filter products by price range
                        final filteredProducts = products.where((product) {
                          double productPrice = double.parse(product.discountedPrice);
                          return productPrice >= _priceRange.start && productPrice <= _priceRange.end;
                        }).toList();
                        
                        // Check if no products match the filter criteria
                        if (filteredProducts.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.filter_alt_off, size: 60, color: Colors.grey[400]),
                                SizedBox(height: 16),
                                Text(
                                  'No products match your filter criteria',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _priceRange = RangeValues(0, _maxPrice);
                                    });
                                  },
                                  child: Text('Reset Filters'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[800],
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio: 0.65,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              
                              return Hero(
                                tag: 'product-${product.id}',
                                child: Material(
                                  borderRadius: BorderRadius.circular(16),
                                  elevation: 2,
                                  shadowColor: Colors.black.withOpacity(0.1),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductDetailScreen(
                                            categoryId: product.categoryId,
                                            subcategoryId: product.subcategoryId,
                                            productId: product.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                height: 130,
                                                decoration: BoxDecoration(
                                                  borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(16),
                                                    topRight: Radius.circular(16),
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(16),
                                                    topRight: Radius.circular(16),
                                                  ),
                                                  child: Image.network(
                                                    'https://skm-mart.actthost.com/uploads/products/${product.image}',
                                                    fit: BoxFit.cover,
                                                    height: 130,
                                                    width: double.infinity,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        height: 130,
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment.topLeft,
                                                            end: Alignment.bottomRight,
                                                            colors: [
                                                              Colors.green.shade50,
                                                              Colors.green.shade100,
                                                            ],
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Icon(
                                                            Icons.image_not_supported_outlined,
                                                            color: Colors.grey[400],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              if (double.parse(product.discountedPrice) < double.parse(product.price))
                                                Positioned(
                                                  top: 10,
                                                  left: 10,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.shade500,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      '${(100 - (double.parse(product.discountedPrice) / double.parse(product.price) * 100)).toStringAsFixed(0)}% OFF',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: IconButton(
                                                  icon: Icon(
                                                    product.isFavorited ? Icons.favorite : Icons.favorite_border,
                                                    color: product.isFavorited ? Colors.red : Colors.grey[600],
                                                  ),
                                                  onPressed: () async {
                                                    try {
                                                      if (product.isFavorited) {
                                                        await _apiService.removeFromWishlist(userId, product.id);
                                                        setState(() {
                                                          product.isFavorited = false;
                                                          
                                                          final originalProduct = _loadedProducts.firstWhere((p) => p.id == product.id);
                                                          originalProduct.isFavorited = false;
                                                        });
                                                        _showSnackBar('${product.name} has been removed from your wishlist.');
                                                      } else {
                                                        await _apiService.addToWishlist(userId, product.id);
                                                        setState(() {
                                                          product.isFavorited = true;
                                                          
                                                          final originalProduct = _loadedProducts.firstWhere((p) => p.id == product.id);
                                                          originalProduct.isFavorited = true;
                                                        });
                                                        _showSnackBar('${product.name} has been added to your wishlist.');
                                                      }
                                                    } catch (e) {
                                                      print('Failed to update wishlist: $e');
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  style: GoogleFonts.lato(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Colors.green.shade900,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.category_outlined,
                                                      size: 12,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        product.catName,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.grey.shade600,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        if (product.price != null)
                                                          Text(
                                                            '\₹${double.parse(product.price).toStringAsFixed(2)}',
                                                            style: TextStyle(
                                                              color: Colors.grey.shade500,
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 11,
                                                              decoration: TextDecoration.lineThrough,
                                                            ),
                                                          ),
                                                        Text(
                                                          '\₹${double.parse(product.discountedPrice).toStringAsFixed(2)}',
                                                          style: GoogleFonts.lato(
                                                            color: Colors.green.shade800,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green[50],
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.star,
                                                            size: 12,
                                                            color: Colors.amber,
                                                          ),
                                                          SizedBox(width: 2),
                                                          Text(
                                                            '4.5',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
} 