import 'package:flutter/material.dart';
import 'package:new_project/screens/product_detail_screen.dart';
import '../models/category.dart';
import 'subcategory_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import 'package:shimmer/shimmer.dart';
import '../models/slider.dart';
import 'all_categories_screen.dart';
import 'cart_screen.dart';
import 'main_screen.dart';
import '../models/featured_product.dart';
import 'all_products_screen.dart';

class HomeScreen extends StatefulWidget {

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentBannerIndex = 0;
  late AnimationController _animationController;
  late Future<List<Category>> _categories;
  late Future<List<SliderModel>> _sliders;
  int _cartItemCount = 0;
  late Future<List<FeaturedProduct>> _featuredProducts;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _categories = _fetchCategories();
    _sliders = ApiService.fetchSliders();
    _featuredProducts = ApiService.fetchFeaturedProducts();
    // Auto-scroll banner
    Future.delayed(const Duration(seconds: 1), () {
      // Start auto-scrolling the banner
      _startAutoScroll();
    });
    
    // Fetch cart count from API service
    _fetchCartItemCount();
  }

  Future<List<Category>> _fetchCategories() async {
    try {
      return await ApiService.fetchCategories();
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              automaticallyImplyLeading: false,
              floating: true,
              pinned: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.green.shade800,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade300, Colors.green.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.eco, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Plant World',
                    style: TextStyle(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    child: Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, size: 26),
                          onPressed: _navigateToCart,
                        ),
                        if (_cartItemCount > 0) // Only show badge if items exist
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Center(
                                child: Text(
                                  _cartItemCount > 99 ? '99+' : '$_cartItemCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Carousel Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        children: [
                          FutureBuilder<List<SliderModel>>(
                            future: _sliders,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              final sliders = snapshot.data!;
                              
                              return PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentBannerIndex = index;
                                  });
                                },
                                itemCount: sliders.length,
                                itemBuilder: (context, index) {
                                  final slider = sliders[index];
                                  final imageUrl = "https://plant-world.actthost.com/uploads/homesliders/${slider.image}";
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          spreadRadius: 1,
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            imageUrl,
                                            fit: BoxFit.fill,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              print('Error loading image: $error');
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Icon(Icons.error_outline, color: Colors.red[400]),
                                              );
                                            },
                                          ),
                                          // Gradient overlay
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withOpacity(0.6),
                                                ],
                                                stops: const [0.6, 1.0],
                                              ),
                                            ),
                                          ),
                                          // Content
                                          Positioned(
                                            bottom: 20,
                                            left: 20,
                                            child: Text(
                                              slider.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                shadows: [
                                                  Shadow(
                                                    offset: Offset(1, 1),
                                                    blurRadius: 3,
                                                    color: Colors.black54,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          
                          // Banner Indicators
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: FutureBuilder<List<SliderModel>>(
                              future: _sliders,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const SizedBox();
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    snapshot.data!.length,
                                    (index) => AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      width: _currentBannerIndex == index ? 16 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: _currentBannerIndex == index
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Categories Section - Enhanced header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 5,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.green.shade700,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Categories',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllCategoriesScreen(showBackButton: true),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.green.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'View All',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Colors.green.shade700,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Categories List - Improved design
                  SizedBox(
                    height: 160,
                    child: FutureBuilder<List<Category>>(
                      future: _categories,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade400, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'Failed to load categories',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.category_outlined, color: Colors.grey.shade400, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'No categories available',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          );
                        }

                        final categories = snapshot.data!;

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          physics: const BouncingScrollPhysics(),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final imageUrl = "https://plant-world.actthost.com/uploads/category/${category.image}";
                            print('Category Image URL: $imageUrl'); // Print the category image URL
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubCategoryScreen(category: category),
                                  ),
                                );
                              },
                              child: Container(
                                width: 160,
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.08),
                                      offset: const Offset(0, 8),
                                      blurRadius: 24,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Background Design Element
                                    Positioned(
                                      right: -20,
                                      top: -20,
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    
                                    // Content
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Image Container
                                          Container(
                                            height: 65,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  imageUrl,
                                                ),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          
                                          // Category Name
                                          Text(
                                            category.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green.shade900,
                                              letterSpacing: 0.3,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          
                                          const SizedBox(height: 4),
                                          
                                          // Subtitle and Items Count
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  category.subtitle ?? 'Explore items',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade600,
                                                    height: 1.2,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade50,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.category_outlined,
                                                      size: 8,
                                                      color: Colors.green.shade700,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '${category.subCategoryCount ?? 0}',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.green.shade700,
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
                                    
                                    // Interaction Feedback
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SubCategoryScreen(category: category),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Featured Products Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 5,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.green.shade700,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Featured Products',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AllProductsScreen()),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.green.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'View All',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Colors.green.shade700,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Displaying featured products
                  FutureBuilder<List<FeaturedProduct>>(
                    future: _featuredProducts,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No featured products available'));
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.60,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final product = snapshot.data![index];

                          // Calculate the discount percentage
                          double originalPrice = double.tryParse(product.price ?? '0') ?? 0;
                          double discountedPrice = double.tryParse(product.discountedPrice ?? '0') ?? 0;
                          String discountText = "";
                          
                          if (originalPrice > 0 && discountedPrice < originalPrice) {
                            double discountPercentage = ((originalPrice - discountedPrice) / originalPrice) * 100;
                            discountText = '${discountPercentage.toStringAsFixed(1)}% OFF';
                          }

                          return GestureDetector(
                            onTap: () {
                              // Navigate to the Product Detail screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    categoryId: int.parse(product.categoryId.toString()),
                                    subcategoryId: int.parse(product.subcategoryId.toString()),
                                    productId: int.parse(product.id.toString()),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                                border: Border.all(color: Colors.green.shade200, width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product image with gradient overlay
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
                                            "https://plant-world.actthost.com/uploads/products/${product.image}",
                                            fit: BoxFit.cover,
                                            height: 130,
                                            width: double.infinity,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: double.infinity,
                                                height: 130,
                                                color: Colors.grey[200],
                                                child: Icon(Icons.error_outline, color: Colors.red[400]),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      // Gradient overlay
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.black.withOpacity(0.5),
                                                Colors.transparent,
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Discount Text
                                      if (discountText.isNotEmpty)
                                        Positioned(
                                          left: 8,
                                          top: 8,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              discountText,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Product Name
                                        Text(
                                          product.name ?? 'Unnamed Product',
                                          style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Price
                                        Text(
                                          '\₹${double.parse(product.price ?? '0').toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                            decoration: product.discountedPrice != null ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        // Discount Price
                                        if (product.discountedPrice != null)
                                          Text(
                                            '\₹${double.parse(product.discountedPrice ?? '0').toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        // Category Name with Icon
                                        Container(
                                          margin: const EdgeInsets.only(top: 2),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.category_outlined,
                                                size: 8,
                                                color: Colors.green.shade700,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                product.catName ?? 'Uncategorized',
                                                style: TextStyle(
                                                  color: Colors.green.shade700,
                                                  fontSize: 8,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Fix the auto-scroll method to properly handle page count
  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        // Get the total number of pages from the FutureBuilder data
        _sliders.then((sliders) {
          if (sliders.isNotEmpty && _pageController.hasClients) {
            final int totalPages = sliders.length;
            final int nextPage = (_currentBannerIndex + 1) % totalPages;
            
            _pageController.animateToPage(
              nextPage,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          }
          
          // Continue auto-scrolling
          _startAutoScroll();
        });
      }
    });
  }

  // Update this method to fetch cart count from API
  Future<void> _fetchCartItemCount() async {
    try {
      // Get cart items from API service
      final cartItems = await ApiService().getCart();
      
      // Directly update cart count with the length of cartItems
      setState(() {
        _cartItemCount = cartItems.length; // This assumes cartItems is always a List
      });
    } catch (e) {
      print('Error fetching cart count: $e');
      // In case of error, set cart count to 0
      setState(() {
        _cartItemCount = 0;
      });
    }
  }
  
  // Update this method to navigate to cart screen via bottom navigation
  void _navigateToCart() {
    // Navigate to MainScreen with cart tab selected
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(initialIndex: 2), // Assuming cart is at index 2
      ),
    );
  }
}