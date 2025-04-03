import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_project/screens/all_categories_screen.dart';
import 'package:new_project/screens/cart_screen.dart';
import 'dart:ui';
import 'package:new_project/screens/profile_screen.dart';
import 'package:new_project/screens/wishlist_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }
  
  // List of screens to display
  final List<Widget> _screens = [
     HomeScreen(),
     const AllCategoriesScreen(showBackButton: false),
    const CartScreen(),
    const WishlistScreen(),
    const ProfileScreen(),
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey.shade500,
          backgroundColor: Colors.white,
          elevation: 0,
          iconSize: 22,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          items: [
            _buildNavItem(Icons.home_outlined, Icons.home, 'Home'),
            _buildNavItem(Icons.category_outlined, Icons.category, 'Categories'),
            _buildNavItem(Icons.shopping_cart_outlined, Icons.shopping_cart, 'Cart'),
            _buildNavItem(Icons.favorite_outline, Icons.favorite, 'Wishlist'),
            _buildNavItem(Icons.person_outline, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }
  
  BottomNavigationBarItem _buildNavItem(IconData unselectedIcon, IconData selectedIcon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(unselectedIcon),
      activeIcon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(selectedIcon),
          Container(
            margin: const EdgeInsets.only(top: 2),
            height: 3,
            width: 16,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
          )
        ],
      ),
      label: label,
    );
  }
}
