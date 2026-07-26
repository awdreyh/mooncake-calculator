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
  final List<Type>? matchedDoughType; // Matched dough categories for this filling category

  Type({
    required this.id,
    required this.category,
    required this.name,
    this.matchedDoughType,
  }) : assert(
          category != Category.filling || matchedDoughType != null,
          'matchedDoughType cannot be null when Category type is filling',
        );

  Map<String, dynamic> toMap() =>{
      'id': id,
      'category': category.toMap(),
      'name': name,
      'matchedDoughType': matchedDoughType?.map((i) => i.toMap()).toList(),
    };  

  factory Type.fromMap(Map<String, dynamic> map) {
    final idValue = map['id'];
    return Type(
      id: idValue is String ? idValue : idValue.toString(),
      name: map['name'] as String,
      category: Category.fromMap(map['category'] as String),
      matchedDoughType: map['matchedDoughType'] == null
          ? null
          : (map['matchedDoughType'] as List<dynamic>)
              .map((item) => Type.fromMap(item as Map<String, dynamic>))
              .toList(),
    );
  }
  static List<Type> matchedDoughTypesIds(List<Type> types) {
    return types.where((type) => type.category == Category.dough).toList();
  }
}

final defaultTypes = [
  Type(id: '7a91f6c1-4c5d-482e-a15a-7d9e7b3c0f89', category: Category.dough, name: '广式月饼'),
  Type(id: 'c1d2f9b4-5e6a-4d73-9998-8c3f6c7f3e5a', category: Category.dough, name: '冰皮月饼'),
  Type(
    id: 'f7a5d8b9-2c1f-4f3d-a8bd-2a4e7d5c9e1f',
    category: Category.filling,
    name: '红豆沙',
    matchedDoughType: [
      Type(id: '7a91f6c1-4c5d-482e-a15a-7d9e7b3c0f89', category: Category.dough, name: '广式月饼'),
      Type(id: 'c1d2f9b4-5e6a-4d73-9998-8c3f6c7f3e5a', category: Category.dough, name: '冰皮月饼'),
    ],
  ),
  Type(
    id: 'a6d5f8c9-3b2c-4e1a-b9f7-6d8e4c7b5f3a',
    category: Category.filling,
    name: '五仁',
    matchedDoughType: [
      Type(id: '7a91f6c1-4c5d-482e-a15a-7d9e7b3c0f89', category: Category.dough, name: '广式月饼'),
    ],
  ),
];

 

