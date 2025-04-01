class Category {
    final int id;
    final String name;
    final String? subtitle;
    final String image;
    int? subCategoryCount;

    Category({
        required this.id,
        required this.name,
        this.subtitle,
        required this.image,
        this.subCategoryCount,
    });

    factory Category.fromJson(Map<String, dynamic> json) {
        return Category(
            id: json['id'],
            name: json['name'],
            subtitle: json['subtitle'],
            image: json['image'],
            subCategoryCount: 0,
        );
    }
}

class Datum {
    int id;
    String name;
    dynamic subtitle;
    String image;
    int status;
    DateTime createdAt;
    DateTime updatedAt;

    Datum({
        required this.id,
        required this.name,
        required this.subtitle,
        required this.image,
        required this.status,
        required this.createdAt,
        required this.updatedAt,
    });

}
