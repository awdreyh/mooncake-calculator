enum Category {
  dough,
  filling;

  // Convert enum → string
  String toMap() => name;

  // Convert string → enum
  static Category fromMap(String value) {
    return Category.values.firstWhere(
      (t) => t.name == value,
      orElse: () => Category.dough,
    );
  }
}

class Type {
  final String id;
  final Category category;
  final String name;
  final String? imagePath;
  final List<String>?
  matchedDoughTypeIds; // Matched dough type IDs for this filling category

  Type({
    required this.id,
    required this.category,
    required this.name,
    this.imagePath,
    this.matchedDoughTypeIds,
  })   : assert(
         category != Category.filling || matchedDoughTypeIds != null,
         'matchedDoughTypeIds cannot be null when Category type is filling',
       );

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category.toMap(),
    'name': name,
    'imagePath': imagePath,
    'matchedDoughTypeIds': matchedDoughTypeIds,
  };

  factory Type.fromMap(Map<String, dynamic> map) {
    final idValue = map['id'];
    final categoryValue = map['category'];
    final nameValue = map['name'];
    final imagePathValue = map['imagePath'];

    return Type(
      id: idValue is String ? idValue : idValue?.toString() ?? '',
      name: nameValue is String ? nameValue : nameValue?.toString() ?? '',
      category: categoryValue is String
          ? Category.fromMap(categoryValue)
          : Category.dough,
      imagePath: imagePathValue is String ? imagePathValue : null,
      matchedDoughTypeIds: map['matchedDoughTypeIds'] == null
          ? null
          : (map['matchedDoughTypeIds'] as List<dynamic>)
                .map((item) => item?.toString() ?? '')
                .where((item) => item.isNotEmpty)
                .toList(),
    );
  }
}