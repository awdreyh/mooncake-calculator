
import 'package:sqflite/sqflite.dart';

enum UnitType {
  g,
  ml,
  cup,
  tsp,
  tbsp;

  // Convert enum → string
  String toMap() => name;

  // Convert string → enum
  static UnitType fromMap(String value) {
    return UnitType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => UnitType.g,
    );
  }
}

enum IngredientCategory {
  recipe,
  task;

  // Convert enum → string
  String toMap() => name;

  // Convert string → enum
  static IngredientCategory fromMap(String value) {
    return IngredientCategory.values.firstWhere(
      (t) => t.name == value,
      orElse: () => IngredientCategory.recipe,
    );
  }
}

class Ingredient {
  final String id;
  final String name;
  final double amount;
  final UnitType unit;
  final IngredientCategory category;

  Ingredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.category,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'amount': amount,
    'unit': unit.toMap(),
    'category': category.toMap(),
  };

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    final categoryValue = map['category'] ?? map['type'];

    return Ingredient(
      id: map['id'] == null ? '' : map['id'].toString(),
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      unit: UnitType.fromMap(map['unit'] as String),
      category: IngredientCategory.fromMap(categoryValue as String),
    );
  }

  Future<int> save(
    Database db, {
    String? category,
    String? recipeId,
    String? taskId,
  }) async {
    return await db.insert(
      'ingredients',
      {
        'id': id,
        'recipe_id': recipeId,
        'task_id': taskId,
        'type': category ?? this.category.toMap(),
        'name': name,
        'amount': amount,
        'unit': unit.toMap(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> delete(Database db) async {
    return await db.delete(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteById(Database db, String id) async {
    return await db.delete(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}