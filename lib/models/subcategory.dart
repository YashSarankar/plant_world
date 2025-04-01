class SubCategory {
  final int id;
  final String name;
  final int categoryId;
  final String? image;

  SubCategory({
    required this.id,
    required this.name,
    required this.categoryId,
    this.image,
  });

  // Factory method to create a SubCategory from JSON
  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'], // Maps to 'id' in the response
      name: json['subcategory'], // Maps to 'subcategory' in the response
      categoryId: json['category_id'], // Maps to 'category_id' in the response
      image: json['image'], // Maps to 'image' in the response
    );
  }
} 