import 'package:sqflite/sqflite.dart';
import 'ingredient.dart';
import 'direction.dart';

class Recipe {
  final String id;
  final String name; // eg: '祖母的广式月饼食谱'
  final String? typeId; 
  final int quantity;
  final int size;
  final double? ratio;  //ratio is the percentage of dough weight / total weight
  final String? description;
  final List<Ingredient> ingredients;
  final bool? isFavorite;
  final double? rating;
  final String? url;
  final String? comment;
  final List<Direction>? directions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    required this.id,
    required this.name, 
    required this.typeId,
    required this.quantity,
    required this.size,
    required this.ratio,     
    this.description,
    required this.ingredients,
    this.isFavorite = false,
    this.rating,
    this.url,
    this.comment,
    this.directions,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();



  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'typeId': typeId,
    'quantity': quantity,
    'size': size,
    'ratio': ratio,
    'description': description,
    'ingredients': ingredients.map((i) => i.toMap()).toList(),
    'isFavorite': isFavorite,
    'rating': rating,
    'url': url,
    'comment': comment,
    'directions': directions?.map((d) => d.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Recipe.fromMap(Map<String, dynamic> map) {
    final isFavoriteValue = map['isFavorite'] ?? map['is_favorite'];
    final createdAtValue = map['createdAt'] ?? map['created_at'];
    final updatedAtValue = map['updatedAt'] ?? map['updated_at'];

    bool? parsedFavorite;
    if (isFavoriteValue != null) {
      if (isFavoriteValue is bool) {
        parsedFavorite = isFavoriteValue;
      } else if (isFavoriteValue is int) {
        parsedFavorite = isFavoriteValue == 1;
      } else {
        parsedFavorite = isFavoriteValue.toString().toLowerCase() == 'true';
      }
    }

    final ingredientsData = map['ingredients'] as List<dynamic>?;
    final directionsData = map['directions'] as List<dynamic>?;

    return Recipe(
      id: map['id'] == null ? '' : map['id'].toString(),
      name: map['name'] as String,
      typeId: map['typeId'] == null ? '' : map['typeId'].toString(),
      quantity: map['quantity'] as int,
      size: map['size'] as int,
      ratio: (map['ratio'] as num?)?.toDouble(),   
      description: map['description'] as String?,
      ingredients: ingredientsData == null
          ? <Ingredient>[]
          : ingredientsData
              .map((i) => Ingredient.fromMap(i as Map<String, dynamic>))
              .toList(),
      isFavorite: parsedFavorite,
      rating: (map['rating'] as num?)?.toDouble(),
      url: map['url'] as String?,
      comment: map['comment'] as String?,
      directions: directionsData?.map((d) => Direction.fromMap(d as Map<String, dynamic>))
              .toList(),
      createdAt: createdAtValue == null
          ? DateTime.now()
          : DateTime.parse(createdAtValue as String),
      updatedAt: updatedAtValue == null
          ? DateTime.now()
          : DateTime.parse(updatedAtValue as String),
    );
  }

  // Future<Category?> getCategory(Database db) async {

  //   final type = await getTypeById(db, typeId);
  //   return type?.category;
  // }

  // Future<List<Type>> getMatchDoughType(Database db) async {
  //   final type = await getTypeById(db, typeId);

  //   if (type == null || type.category != Category.filling) {
  //     return <Type>[];
  //   }

  //   return type.matchedDoughType ?? <Type>[];
  // }

  // static Future<Type?> getTypeById(Database db, String? typeId) async {
  //   if (typeId == null || typeId.isEmpty) {
  //     return null;
  //   }

  //   final rows = await db.query(
  //     'types',
  //     where: 'id = ?',
  //     whereArgs: [typeId],
  //   );

  //   if (rows.isEmpty) {
  //     return null;
  //   }

  //   final row = rows.first;
  //   final matchedDoughTypeValue = row['matched_dough_type'];

  //   return Type.fromMap({
  //     'id': row['id']?.toString(),
  //     'category': row['category']?.toString(),
  //     'name': row['name']?.toString(),
  //     'matchedDoughType': matchedDoughTypeValue == null
  //         ? null
  //         : jsonDecode(matchedDoughTypeValue as String),
  //   });
  // }

  static Future<Recipe?> load(Database db, String id) async {
    final rows = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rows.isEmpty) {
      return null;
    }

    final recipeRow = rows.first;
    final ingredients = await _loadIngredients(db, id);
    final directions = await _loadDirections(db, id);
    final recipeMap = Map<String, dynamic>.from(recipeRow)
      ..['ingredients'] = ingredients
      ..['directions'] = directions;

    return Recipe.fromMap(recipeMap);
  }

  static Future<List<Recipe>> loadAll(Database db) async {
    final rows = await db.query('recipes');

    return Future.wait(rows.map((recipeRow) async {
      final recipeId = recipeRow['id'] as String;
      final ingredients = await _loadIngredients(db, recipeId);
      final directions = await _loadDirections(db, recipeId);
      final recipeMap = Map<String, dynamic>.from(recipeRow)
        ..['ingredients'] = ingredients
        ..['directions'] = directions;
      return Recipe.fromMap(recipeMap);
    }));
  }

  static Future<List<Map<String, dynamic>>> _loadIngredients(Database db, String recipeId) async {
    final rows = await db.query(
      'ingredients',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );

    return rows.map((row) => <String, dynamic>{
      'id': row['id'] == null ? '' : row['id'].toString(),
      'name': row['name'] as String,
      'amount': row['amount'],
      'unit': row['unit'] as String,
      'type': row['type'] as String,
      'category': row['type'] as String,
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> _loadDirections(Database db, String recipeId) async {
    final rows = await db.query(
      'directions',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
      orderBy: 'step_index ASC',
    );

    return rows.map((row) => <String, dynamic>{
      'stepIndex': row['step_index'] as String,
      'stepTitle': row['step_title'] as String,
      'stepDescription': row['step_description'] as String,
      'stepImage': row['step_image'] as String?,
    }).toList();
  }

  Future<String> save(Database db) async {
    await db.insert(
      'recipes',
      {
        'id': id,
        'name': name,
        'typeId': typeId,
        'quantity': quantity,
        'size': size,
        'ratio': ratio,
        'description': description,
        'is_favorite': (isFavorite ?? false) ? 1 : 0,
        'rating': rating,
        'url': url,
        'comment': comment,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await db.delete(
      'ingredients',
      where: 'recipe_id = ?',
      whereArgs: [id],
    );
    await db.delete(
      'directions',
      where: 'recipe_id = ?',
      whereArgs: [id],
    );

    for (final ingredient in ingredients) {
      await ingredient.save(
        db,
        category: 'recipe',
        recipeId: id,
      );
    }

    if (directions != null) {
      for (final direction in directions!) {
        await db.insert(
          'directions',
          {
            'recipe_id': id,
            'step_index': direction.stepIndex,
            'step_title': direction.stepTitle,
            'step_description': direction.stepDescription,
            'step_image': direction.stepImage,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    return id;
  }
}
 final defaultRecipes = [
      Recipe(
        id: '0ef4bca1-77e2-4fbb-914b-1f3d5d0538f8',
        name: '经典广式月饼饼皮',
        quantity: 8,
        size: 100,
        ratio: 0.4,
        typeId: '7a91f6c1-4c5d-482e-a15a-7d9e7b3c0f89',
        description: '经典广式月饼饼皮食谱，适合制作传统的广式月饼。',
        ingredients: [
          Ingredient(id: '3ad16c7d-16c1-4baf-8a83-7b4f5d3c2e01', category: IngredientCategory.recipe, name: '低筋面粉', amount: 162.0, unit: UnitType.g),
          Ingredient(id: 'b6f8e2f4-6139-46c0-8b58-4d9f2c7e5d03', category: IngredientCategory.recipe, name: '糖浆', amount: 114.0, unit: UnitType.g),
          Ingredient(id: 'd4e5f6a7-3b2c-4d1e-9f8a-1b2c3d4e5f60', category: IngredientCategory.recipe, name: '油', amount: 44.0, unit: UnitType.g),
          Ingredient(id: 'f1a2b3c4-5d6e-7f89-0a1b-2c3d4e5f6078', category: IngredientCategory.recipe, name: '碱水', amount: 1.0, unit: UnitType.g),
        ],
        isFavorite: false,
        rating: 0,
        url: null,
        comment: null,
      ),
      Recipe(
        id: '8e0e37f0-9aad-4758-8c7d-c88c9f8f5b85',
        name: '经典冰皮月饼饼皮',
        quantity: 8,
        size: 100,
        ratio: 0.4,
        typeId: 'c1d2f9b4-5e6a-4d73-9998-8c3f6c7f3e5a',
        description: '经典冰皮月饼饼皮食谱，适合制作传统的冰皮月饼。',
        ingredients: [
          Ingredient(id: 'eb4c35b7-a69f-4c3a-bd91-8f7d6e5c4b02', category: IngredientCategory.recipe, name: '糯米粉', amount: 41.0, unit: UnitType.g),
          Ingredient(id: 'a19f2e3d-4c6b-48d2-9e1f-2a3b4c5d6e07', category: IngredientCategory.recipe, name: '澄粉', amount: 26.0, unit: UnitType.g),
          Ingredient(id: 'c8f7e6d5-b4a3-4c2d-9e1f-0a1b2c3d4e05', category: IngredientCategory.recipe, name: '粘米粉', amount: 34.0, unit: UnitType.g),
          Ingredient(id: 'f2d1c3b4-a5e6-4d7c-9f8a-0b1c2d3e4f06', category: IngredientCategory.recipe, name: '牛奶', amount: 172.0, unit: UnitType.g),
          Ingredient(id: 'b3c4d5e6-f7a8-4b9c-8d0e-1f2a3b4c5d07', category: IngredientCategory.recipe, name: '植物油', amount: 25.0, unit: UnitType.g),
        ],
        isFavorite: false,
        rating: 0,
        url: null,
        comment: null,
      ),
      Recipe(
        id: 'd67aebee-2aad-4ef3-8c3f-9b43f8a1b7e4',
        name: '经典红豆沙馅料',
        quantity: 8,
        size: 100,
        ratio: 0.4,
        typeId: 'f7a5d8b9-2c1f-4f3d-a8bd-2a4e7d5c9e1f',
        description: '经典豆沙馅食谱，适合制作传统的广式月饼。',
        ingredients: [
          Ingredient(id: 'c5f4e3d2-b1a0-4f9d-8e7c-6a5b4c3d2e01', category: IngredientCategory.recipe, name: '红豆（干）', amount: 168.0, unit: UnitType.g),
          Ingredient(id: 'd7e6f5a4-b3c2-4d1e-9f8a-0b1c2d3e4f02', category: IngredientCategory.recipe, name: '转化糖浆', amount: 33.0, unit: UnitType.g),
          Ingredient(id: 'e8f7a6b5-c4d3-4e2f-9a0b-1c2d3e4f5a03', category: IngredientCategory.recipe, name: '糖', amount: 33.0, unit: UnitType.g),
          Ingredient(id: 'f9a8b7c6-d5e4-4f3a-9b0c-1d2e3f4a5b04', category: IngredientCategory.recipe, name: '植物油', amount: 33.0, unit: UnitType.g),
        ],
        isFavorite: false,
        rating: 0,
        url: null,
        comment: null,
      ),
      Recipe(
        id: '3d4f1c7e-5b9c-4692-ab39-6d2e7f4a1b6c',
        name: '经典五仁馅料',
        quantity: 8,
        size: 100,
        ratio: 0.4,
        typeId: 'a6d5f8c9-3b2c-4e1a-b9f7-6d8e4c7b5f3a',
        description: '经典五仁馅食谱，适合制作传统的广式月饼。',
        ingredients: [
          Ingredient(id: '41a3b5c7-d8e9-4f2a-b3c1-2d4e5f6a7b08', category: IngredientCategory.recipe, name: '红豆（干）', amount: 168.0, unit: UnitType.g),
          Ingredient(id: '52b4c6d8-e9f0-4a1b-c2d3-4e5f6a7b8c09', category: IngredientCategory.recipe, name: '转化糖浆', amount: 33.0, unit: UnitType.g),
          Ingredient(id: '63c5d7e9-f0a1-4b2c-d3e4-5f6a7b8c9d01', category: IngredientCategory.recipe, name: '糖', amount: 33.0, unit: UnitType.g),
          Ingredient(id: '74d6e8f0-a1b2-4c3d-e4f5-6a7b8c9d0e12', category: IngredientCategory.recipe, name: '植物油', amount: 33.0, unit: UnitType.g),
        ],
        isFavorite: false,
        rating: 0,
        url: null,
        comment: null,
      ),
    ];


    

   