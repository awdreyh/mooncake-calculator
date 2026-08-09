import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../model/recipe.dart';
import '../model/ingredient.dart';
import '../model/task.dart';


class TaskRepository {
  final MCDatabase db;  
  TaskRepository(this.db);

 Future<List<Task>> loadAll() async {
    final database = await db.database;
    final result = await database.query('tasks');
    return result.map((map) => Task.fromMap(map)).toList();
  }
 
 Future<Task?> load(String id) async {
    final database = await db.database;
    final rows = await database.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rows.isEmpty) {
      return null;
    }

    final taskRow = rows.first;
    final ingredients = await _loadIngredients(database, id);
    final taskMap = Map<String, dynamic>.from(taskRow)
      ..['ingredients'] = ingredients;

    return Task.fromMap(taskMap);
  }

  Future<Recipe?> loadRecipe(String recipeId) async {
    final database = await db.database;
    final rows = await database.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [recipeId],
    );

    if (rows.isEmpty) {
      return null;
    }

    final recipeRow = rows.first;
    final ingredients = await _loadIngredients(database, recipeId);
    final recipeMap = Map<String, dynamic>.from(recipeRow)
      ..['ingredients'] = ingredients;

    return Recipe.fromMap(recipeMap);
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
      );
    }).toList();
  }

  static Future<List<Ingredient>> _loadIngredients(Database db, String taskId) async {
    final rows = await db.query(
      'ingredients',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );

    return rows.map((row) => Ingredient.fromMap(row)).toList();
  }

  Future<int> insert(Task task) async {
    final database = await db.database;
    return await database.insert('tasks', task.toMap());
  }

  Future<int> update(Task task) async {
    final database = await db.database;
    return await database.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> delete(String id) async {
    final database = await db.database;
    return await database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}