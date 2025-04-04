import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_project/screens/product_by_subcategory_screen.dart';
import 'package:new_project/services/api_service.dart';
import '../models/category.dart' as category_model;
import '../models/subcategory.dart';



class SubCategoryScreen extends StatefulWidget {
  final category_model.Category category;

  SubCategoryScreen({required this.category});

  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  late Future<List<SubCategory>> _subCategories;

  @override
  void initState() {
    super.initState();
    _subCategories = ApiService.fetchSubCategories(widget.category.id);
    
    // Set the system UI overlay style here
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Set status bar color to black
      statusBarIconBrightness: Brightness.light, // Set status bar icons to light
      systemNavigationBarColor: Colors.black, // Set navigation bar color to black
      systemNavigationBarIconBrightness: Brightness.light, // Set navigation bar icons to light
    ));
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern banner for the category with back button
              Container(
                height: 120,
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      Theme.of(context).colorScheme.primary.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        Icons.category_outlined,
                        size: 100,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.of(context).pop(),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.category.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 3,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Text(
                      'Subcategories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),

              // Subcategories grid
              Expanded(
                child: FutureBuilder<List<SubCategory>>(
                  future: _subCategories,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[300],
                              size: 60,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading subcategories',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              color: Colors.grey[400],
                              size: 60,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No subcategories found',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final subCategories = snapshot.data!;

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: subCategories.length,
                      itemBuilder: (context, index) {
                        final subCategory = subCategories[index];
                        return Hero(
                          tag: 'subcategory_${subCategory.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductBySubCategoryScreen(
                                      subCategoryId: subCategory.id,
                                      categoryName: widget.category.name,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                        child: subCategory.image != null && subCategory.image!.isNotEmpty
                                            ? Image.network(
                                                "https://skm-mart.actthost.com/uploads/subcategory/${subCategory.image!}",
                                                fit: BoxFit.fill,
                                                width: double.infinity,
                                                height: double.infinity,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                    child: Icon(
                                                      Icons.image_not_supported_outlined,
                                                      size: 32,
                                                      color: Theme.of(context).colorScheme.primary,
                                                    ),
                                                  );
                                                },
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Center(
                                                    child: CircularProgressIndicator(
                                                      value: loadingProgress.expectedTotalBytes != null
                                                          ? loadingProgress.cumulativeBytesLoaded / 
                                                              loadingProgress.expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  );
                                                },
                                              )
                                            : Container(
                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                child: Icon(
                                                  Icons.category,
                                                  size: 32,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        subCategory.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 