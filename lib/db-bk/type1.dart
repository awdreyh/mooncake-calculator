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
  final String? imageName;
  final List<String>?
  matchedDoughTypeIds; // Matched dough type IDs for this filling category

  Type({
    required this.id,
    required this.category,
    required this.name,
    this.imageName,
    this.matchedDoughTypeIds,
  })   : assert(
         category != Category.filling || matchedDoughTypeIds != null,
         'matchedDoughTypeIds cannot be null when Category type is filling',
       );

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category.toMap(),
    'name': name,
    'imageName': imageName,
    'matchedDoughTypeIds': matchedDoughTypeIds,
  };

  factory Type.fromMap(Map<String, dynamic> map) {
    final idValue = map['id'];
    final categoryValue = map['category'];
    final nameValue = map['name'];
    final imageNameValue = map['imageName'];

    return Type(
      id: idValue is String ? idValue : idValue?.toString() ?? '',
      name: nameValue is String ? nameValue : nameValue?.toString() ?? '',
      category: categoryValue is String
          ? Category.fromMap(categoryValue)
          : Category.dough,
      imageName: imageNameValue is String ? imageNameValue : null,
      matchedDoughTypeIds: map['matchedDoughTypeIds'] == null
          ? null
          : (map['matchedDoughTypeIds'] as List<dynamic>)
                .map((item) => item?.toString() ?? '')
                .where((item) => item.isNotEmpty)
                .toList(),
    );
  }

  static Type getTypeById(String? id, {required List<Type> types}) {
    if (id == null || id.isEmpty) {
      return Type(id: '', category: Category.dough, name: '');
    }
    final match = types.firstWhere(
      (type) => type.id == id,
      orElse: () => Type(id: id, category: Category.dough, name: id),
    );
    return match;
  }  

  static List<Type> getMatchedDoughTypesById(
    String? id, {
    required List<Type> types,
  }) {
    if (id == null || id.isEmpty) {
      return <Type>[];
    }

    final match = types.firstWhere(
      (type) => type.id == id,
      orElse: () => Type(id: id, category: Category.dough, name: id),
    );

    if (match.category != Category.filling) {
      return <Type>[];
    }

    final matchedTypeIds = match.matchedDoughTypeIds ?? <String>[];
    return types.where((type) => matchedTypeIds.contains(type.id)).toList();
  }
}

final defaultTypes = [
  Type(
    id: '7a91f6c1-4c5d-482e-a15a-7d9e7b3c0f89',
    category: Category.dough,
    name: '广式月饼',
    imageName: 'cantoneseStyle',
  ),
  Type(
    id: 'c1d2f9b4-5e6a-4d73-9998-8c3f6c7f3e5a',
    category: Category.dough,
    name: '冰皮月饼',
    imageName: 'snowSkin',
  ),
  Type(
    id: 'd2e3f4a5-6b7c-8d9e-0f1a-2b3c4d5e6f7g',
    category: Category.dough,
    name: '苏式月饼',
    imageName: 'cantoneseStyle',
  ),
  Type(
    id: 'f7a5d8b9-2c1f-4f3d-a8bd-2a4e7d5c9e1f',
    category: Category.filling,
    name: '红豆沙',
    imageName: 'cantoneseStyle',
    matchedDoughTypeIds: [
      '7a91f6c1-4c5d-482e-a15a-7d9e7b3c0f89',
      'c1d2f9b4-5e6a-4d73-9998-8c3f6c7f3e5a',
      'd2e3f4a5-6b7c-8d9e-0f1a-2b3c4d5e6f7g',
    ],
  ),
  Type(
    id: 'b3c4d5e6-7f8g-9h0i-1j2k-3l4m5n6o7p8q',
    category: Category.filling,
    name: '莲蓉',
    imageName: 'snowSkin',
    matchedDoughTypeIds: [
      '7a91f6c1-4c5d-482e-a15a-7d9e7b3c0f89',
      'c1d2f9b4-5e6a-4d73-9998-8c3f6c7f3e5a',
      'd2e3f4a5-6b7c-8d9e-0f1a-2b3c4d5e6f7g',
    ],
  ),
  Type(
    id: 'a6d5f8c9-3b2c-4e1a-b9f7-6d8e4c7b5f3a',
    category: Category.filling,
    name: '五仁',
    imageName: 'cantoneseStyle',
    matchedDoughTypeIds: [
      '7a91f6c1-4c5d-482e-a15a-7d9e7b3c0f89',
      'd2e3f4a5-6b7c-8d9e-0f1a-2b3c4d5e6f7g',
    ],
  ),
];
