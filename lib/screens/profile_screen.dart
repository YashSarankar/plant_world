import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/wishlist_item.dart';
import 'auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  String userName = "";
  String userEmail = "";
  String userPhone = "";
  String userAddress = "";
  int totalOrders = 0; // You can set this based on your logic
  int wishlistItems = 0; // You can set this based on your logic
  
  late AnimationController _animationController;
  final ApiService _apiService = ApiService();
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }
  
  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('user_id') ?? 1; // Get user ID from SharedPreferences
    
    try {
      // Fetch wishlist from API
      final List<WishlistItem> wishlist = await _apiService.getWishlist(userId);
      
      setState(() {
        userName = prefs.getString('name') ?? "User";
        userEmail = prefs.getString('email') ?? "No email";
        userPhone = prefs.getString('phone') ?? "No phone";
        userAddress = prefs.getString('address') ?? "No address";
        
        // Set wishlist count from API response
        wishlistItems = wishlist.length;
        
        // You can also load totalOrders from your data source
      });
    } catch (e) {
      print('Error loading wishlist: $e');
      setState(() {
        userName = prefs.getString('name') ?? "User";
        userEmail = prefs.getString('email') ?? "No email";
        userPhone = prefs.getString('phone') ?? "No phone";
        userAddress = prefs.getString('address') ?? "No address";
        wishlistItems = 0; // Default to 0 if there's an error
      });
    }
  }
  
  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all user data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor; // Use theme's primary color
    final secondaryColor = theme.colorScheme.secondary.withOpacity(0.1);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              pinned: true,
              title: Text(
                'My Profile',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: theme.textTheme.titleLarge?.color,
                  letterSpacing: 0.2,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: primaryColor,
                    size: 22,
                  ),
                  onPressed: () {
                    _animationController.forward(from: 0.0);
                    // Navigate to edit profile screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                    ).then((_) => _loadUserData()); // Reload data when returning
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.15),
                ),
              ),
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User profile header
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Profile image
                        Hero(
                          tag: 'profile-image',
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : "U",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // User info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: theme.textTheme.titleLarge?.color,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                icon: Icons.email_outlined,
                                text: userEmail,
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                icon: Icons.phone_outlined,
                                text: userPhone,
                              ),
                              if (userAddress.isNotEmpty && userAddress != "No address")
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: _buildInfoRow(
                                    icon: Icons.location_on_outlined,
                                    text: userAddress,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Stats Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Orders card
                        Expanded(
                          child: _buildStatCard(
                            title: 'My Orders',
                            value: totalOrders.toString(),
                            icon: Icons.shopping_bag_outlined,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Wishlist card
                        Expanded(
                          child: _buildStatCard(
                            title: 'Wishlist',
                            value: wishlistItems.toString(),
                            icon: Icons.favorite_border,
                            color: Colors.red.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Account Settings Section
                  _buildSectionHeader(title: 'Account Settings', primaryColor: primaryColor),
                  
                  const SizedBox(height: 8),
                  
                  // Account settings options
                  _buildSettingItem(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    subtitle: 'Manage your personal details',
                    onTap: () {},
                  ),
                  
                  _buildDivider(),
                  
                  _buildSettingItem(
                    icon: Icons.location_on_outlined,
                    title: 'Addresses',
                    subtitle: 'Your shipping and billing addresses',
                    onTap: () {},
                  ),
                  
                  _buildDivider(),
                  
                  _buildSettingItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Set your notification preferences',
                    onTap: () {
                      // Navigate to the notification screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationScreen()),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Support Section
                  _buildSectionHeader(title: 'Support', primaryColor: primaryColor),
                  
                  const SizedBox(height: 8),
                  
                  _buildSettingItem(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    subtitle: 'Get help with your orders and account',
                    onTap: () {},
                  ),
                  
                  _buildDivider(),
                  
                  _buildSettingItem(
                    icon: Icons.policy_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    onTap: () {},
                  ),
                  
                  _buildDivider(),
                  
                  _buildSettingItem(
                    icon: Icons.info_outline,
                    title: 'About Us',
                    subtitle: 'Learn more about our company',
                    onTap: () {},
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Logout Option
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _logout();
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(Icons.logout, color: Colors.red.shade700),
                      label: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        color: Colors.grey.shade200,
        height: 1,
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required Color primaryColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to build stat cards
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to build setting items
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    final Color iconColorFinal = iconColor ?? Theme.of(context).primaryColor;
    
    return InkWell(
      onTap: onTap,
      splashColor: Theme.of(context).primaryColor.withOpacity(0.05),
      highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColorFinal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColorFinal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
} 