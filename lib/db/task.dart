import 'ingredient.dart';
import 'package:sqflite/sqflite.dart';

class Task {
  final String id;
  final String doughRecipeId;
  final String fillingRecipeId;
  final int size;
  final int quantity;
  final double ratio;
  final List<Ingredient> ingredients;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? comment;
  final double? rating;
  final bool? isCompleted;

  Task({
    required this.id,
    required this.doughRecipeId,
    required this.fillingRecipeId,
    required this.size,
    required this.quantity,
    required this.ratio,
    required this.ingredients,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.comment,
    this.rating,
    this.isCompleted,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'dough_recipe_id': doughRecipeId,
        'filling_recipe_id': fillingRecipeId,
        'size': size,
        'quantity': quantity,
        'ratio': ratio,
        'ingredients': ingredients.map((ingredient) => ingredient.toMap()).toList(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'comment': comment,
        'rating': rating,
        'is_completed': isCompleted,
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'] == null ? '' : map['id'].toString(),
        doughRecipeId: map['dough_recipe_id'] == null ? '' : map['dough_recipe_id'].toString(),
        fillingRecipeId: map['filling_recipe_id'] == null ? '' : map['filling_recipe_id'].toString(),
        size: map['size'] as int,
        quantity: map['quantity'] as int,
        ratio: (map['ratio'] as num).toDouble(),
        ingredients: map['ingredients'] == null
            ? <Ingredient>[]
            : (map['ingredients'] as List<dynamic>)
                .map((i) => Ingredient.fromMap(i as Map<String, dynamic>))
                .toList(),
        createdAt: map['created_at'] == null
            ? DateTime.now()
            : DateTime.parse(map['created_at'] as String),
        updatedAt: map['updated_at'] == null
            ? DateTime.now()
            : DateTime.parse(map['updated_at'] as String),
        isCompleted: map['is_completed'] == null
            ? null
            : (map['is_completed'] is int
                ? (map['is_completed'] as int) == 1
                : map['is_completed'] as bool),
        rating: map['rating'] == null ? null : (map['rating'] as num).toDouble(),
        comment: map['comment'] as String?,
      );


Future<String> save(Database db) async {
   await db.insert(
      'tasks',
      {
        'id': id,
        'dough_recipe_id': doughRecipeId,
        'filling_recipe_id': fillingRecipeId,
        'size': size,
        'quantity': quantity,
        'ratio': ratio,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'comment': comment,
        'is_completed': isCompleted == true ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await db.delete(
      'ingredients',
      where: 'task_id = ?',
      whereArgs: [id],
    );

    for (final ingredient in ingredients) {
      await ingredient.save(
        db,
        taskId: id,
      );
    }

    return id;
  // Implementation for saving task
}
}