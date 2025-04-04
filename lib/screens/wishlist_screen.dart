import 'package:flutter/material.dart';
import 'package:new_project/screens/main_screen.dart';
import 'package:new_project/screens/product_by_subcategory_screen.dart';
import 'package:new_project/services/api_service.dart';
import 'package:new_project/models/wishlist_item.dart'; // Import the WishlistItem model
import 'package:shimmer/shimmer.dart'; // Add this import for shimmer effect
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  Future<List<WishlistItem>>? _wishlistItems; // Change to nullable Future
  final ApiService _apiService = ApiService(); // Create an instance of ApiService
  late int userId; // Change to late initialization
  List<WishlistItem> _filteredItems = []; // List to hold filtered items
  String _searchQuery = ''; // Search query
  bool _isSearching = false; // Track if the search field is visible
  List<int> _selectedItems = [];
  bool _isMultiSelectMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load user ID from shared preferences
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id') ?? 0; // Retrieve user ID or default to 0
    _loadWishlist(); // Load wishlist items after retrieving user ID
  }

  Future<void> _loadWishlist() async {
    setState(() {
      _wishlistItems = _apiService.getWishlist(userId); // Initialize wishlist items
      _selectedItems = [];
      _isMultiSelectMode = false;
    });
  }

  void _filterWishlistItems(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Add this method to handle the deletion of a product from the wishlist
  Future<void> _deleteProductFromWishlist(int productId) async {
    try {
      await _apiService.removeFromWishlist(userId, productId);
      // Reload the wishlist after successful removal
      await _loadWishlist(); // Ensure the wishlist is loaded
      setState(() {}); // Trigger a rebuild to refresh the UI
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item removed from wishlist'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Handle error (e.g., show a snackbar or dialog)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove item from wishlist'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
    }
  }

  Future<void> _deleteSelectedItems() async {
    try {
      for (int productId in _selectedItems) {
        await _apiService.removeFromWishlist(userId, productId);
      }
      await _loadWishlist();
      setState(() {
        _isMultiSelectMode = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedItems.length} items removed from wishlist'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove items from wishlist'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
    }
  }

  void _toggleItemSelection(int productId) {
    setState(() {
      if (_selectedItems.contains(productId)) {
        _selectedItems.remove(productId);
        if (_selectedItems.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedItems.add(productId);
      }
    });
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedItems.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.green.shade700;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: !_isMultiSelectMode,
        title: _isSearching
            ? _buildSearchField()
            : Text(
                _isMultiSelectMode 
                    ? '${_selectedItems.length} selected' 
                    : 'My Wishlist',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: primaryColor,
                  letterSpacing: 0.3,
                ),
              ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: _buildAppBarActions(primaryColor),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.withOpacity(0.15),
          ),
        ),
      ),
      body: FutureBuilder<List<WishlistItem>>(
        future: _wishlistItems, // Use the nullable Future
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading(); // Show shimmer loading while waiting
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'), // Handle error
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyWishlist(); // Show empty wishlist message
          }

          final wishlistItems = snapshot.data!;
          _filteredItems = _searchQuery.isEmpty
              ? wishlistItems
              : wishlistItems
                  .where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

          return _buildWishlistContent(_filteredItems); // Show the wishlist content
        },
      ),
      floatingActionButton: _isMultiSelectMode && _selectedItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _deleteSelectedItems,
              backgroundColor: Colors.red.shade600,
              icon: Icon(Icons.delete_outline),
              label: Text('Delete (${_selectedItems.length})'),
            )
          : null,
    );
  }

  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search wishlist...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),
      style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
      onChanged: _filterWishlistItems,
    );
  }

  List<Widget> _buildAppBarActions(Color primaryColor) {
    if (_isMultiSelectMode) {
      return [
        IconButton(
          icon: Icon(Icons.close, color: primaryColor),
          onPressed: _toggleMultiSelectMode,
        ),
      ];
    } else if (_isSearching) {
      return [
        IconButton(
          icon: Icon(Icons.close, color: primaryColor),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
            });
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: Icon(Icons.search_outlined, color: primaryColor),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.select_all, color: primaryColor),
          onPressed: _toggleMultiSelectMode,
        ),
      ];
    }
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 60,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Save items you like to your wishlist and revisit them anytime',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Browse Products',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistContent(List<WishlistItem> wishlistItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: wishlistItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No items found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Try a different search term',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    physics: const BouncingScrollPhysics(),
                    itemCount: wishlistItems.length,
                    itemBuilder: (context, index) {
                      final item = wishlistItems[index];
                      return _buildWishlistItem(item);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistItem(WishlistItem item) {
    final bool isSelected = _selectedItems.contains(int.parse(item.productId));
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isSelected ? Colors.green.shade300 : Colors.grey.shade100,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (_isMultiSelectMode) {
                _toggleItemSelection(int.parse(item.productId));
              } else {
                // Navigate to product details
              }
            },
            onLongPress: () {
              if (!_isMultiSelectMode) {
                _toggleMultiSelectMode();
                _toggleItemSelection(int.parse(item.productId));
              }
            },
            splashColor: Colors.green.withOpacity(0.05),
            highlightColor: Colors.green.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_isMultiSelectMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.green.shade700 : Colors.grey.shade200,
                          border: Border.all(
                            color: isSelected ? Colors.green.shade700 : Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  Hero(
                    tag: 'wishlist_${item.productId}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          "https://skm-mart.actthost.com/uploads/products/${item.image}",
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.image_not_supported,
                                size: 30,
                                color: Colors.grey.shade600,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '₹${double.parse(item.discountedPrice).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            if (item.mrpPrice != item.discountedPrice)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Text(
                                  '₹${double.parse(item.mrpPrice).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: Text(
                            'In Stock',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isMultiSelectMode)
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(),
                      onPressed: () {
                        _deleteProductFromWishlist(int.parse(item.productId));
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add this new method for shimmer loading effect
  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: 6, // Show 6 shimmer items
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
} 