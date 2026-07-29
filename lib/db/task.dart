import 'ingredient.dart';
import 'recipe.dart';
import 'package:sqflite/sqflite.dart';

class Task {
  final String id;
  final String doughRecipeId;
  final String fillingRecipeId;
  final int size;
  final int quantity;
  final double ratio; //ratio is the percentage of dough weight / total weight
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

  Future<Recipe?> getDoughRecipe(Database db) async {
    if (doughRecipeId.isEmpty) {
      return null;
    }
    return Recipe.load(db, doughRecipeId);
  }

  Future<Recipe?> getFillingRecipe(Database db) async {
    if (fillingRecipeId.isEmpty) {
      return null;
    }
    return Recipe.load(db, fillingRecipeId);
  }

  static List<Ingredient> calculateIngredientsFromRecipes({
    required Recipe doughRecipe,
    required Recipe fillingRecipe,
    required int quantity,
    required int size,
    required double ratio,
  }) {
    final doughScale = _calculateScaleFactor(
      recipe: doughRecipe,
      quantity: quantity,
      size: size,
      ratio: ratio,
      isDough: true,
    );
    final fillingScale = _calculateScaleFactor(
      recipe: fillingRecipe,
      quantity: quantity,
      size: size,
      ratio: ratio,
      isDough: false,
    );

    return [
      ..._scaleIngredients(doughRecipe.ingredients, doughScale),
      ..._scaleIngredients(fillingRecipe.ingredients, fillingScale),
    ];
  }

  static Task createFromRecipes({
    required String id,
    required Recipe doughRecipe,
    required Recipe fillingRecipe,
    required int quantity,
    required int size,
    required double ratio,
    String? comment,
    double? rating,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final ingredients = calculateIngredientsFromRecipes(
      doughRecipe: doughRecipe,
      fillingRecipe: fillingRecipe,
      quantity: quantity,
      size: size,
      ratio: ratio,
    );

    return Task(
      id: id,
      doughRecipeId: doughRecipe.id,
      fillingRecipeId: fillingRecipe.id,
      size: size,
      quantity: quantity,
      ratio: ratio,
      ingredients: ingredients,
      comment: comment,
      rating: rating,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static double _calculateScaleFactor({
    required Recipe recipe,
    required int quantity,
    required int size,
    required double ratio,
    required bool isDough,
  }) {
    final recipeTotal = recipe.quantity * recipe.size;
    final recipeRatio = recipe.ratio ?? 1.0;
    final recipeComponent = isDough
        ? recipeTotal * recipeRatio
        : recipeTotal * (1.0 - recipeRatio);

    final taskTotal = quantity * size;
    final taskComponent = isDough
        ? taskTotal * ratio
        : taskTotal * (1.0 - ratio);

    if (recipeComponent <= 0) {
      return 0.0;
    }
    return taskComponent / recipeComponent;
  }

  static List<Ingredient> _scaleIngredients(
    List<Ingredient> ingredients,
    double scale,
  ) {
    if (scale <= 0) {
      return <Ingredient>[];
    }
    return ingredients.map((ingredient) {
      return Ingredient(
        id: ingredient.id,
        name: ingredient.name,
        amount: ingredient.amount * scale,
        unit: ingredient.unit,
        category: ingredient.category,
      );
    }).toList();
  }



  static Future<Task?> load(Database db, String id) async {
    final rows = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rows.isEmpty) {
      return null;
    }

    final taskRow = rows.first;
    final ingredients = await _loadIngredients(db, id);
    final taskMap = Map<String, dynamic>.from(taskRow)
      ..['ingredients'] = ingredients;

    return Task.fromMap(taskMap);
  }

  static Future<List<Task>> loadAll(Database db) async {
    final rows = await db.query('tasks');

    return Future.wait(rows.map((taskRow) async {
      final taskId = taskRow['id'].toString();
      final ingredients = await _loadIngredients(db, taskId);
      final taskMap = Map<String, dynamic>.from(taskRow)
        ..['ingredients'] = ingredients;
      return Task.fromMap(taskMap);
    }));
  }

  static Future<List<Map<String, dynamic>>> _loadIngredients(Database db, String taskId) async {
    final rows = await db.query(
      'ingredients',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );

    return rows.map((row) => <String, dynamic>{
      'id': row['id'] == null ? '' : row['id'].toString(),
      'name': row['name'] as String,
      'amount': row['amount'],
      'unit': row['unit'] as String,
      'type': row['type'] as String,
    }).toList();
  }


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
        category: 'task',
        taskId: id,
      );
    }

    return id;
  // Implementation for saving task
}
}