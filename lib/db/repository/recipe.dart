import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import '../model/recipe.dart';
import '../model/ingredient.dart';
import '../model/direction.dart';

class RecipeRepository {  
  final MCDatabase db;
  RecipeRepository(this.db);
  
  Future<List<Recipe>> loadAll() async {
    final database = await db.database;
    final result = await database.query('recipes');

    final recipes = <Recipe>[];
    for (final row in result) {
      final recipeId = row['id']?.toString();
      if (recipeId == null || recipeId.isEmpty) {
        continue;
      }

      final recipeMap = Map<String, dynamic>.from(row)
        ..['ingredients'] = await _loadIngredients(database, recipeId)
        ..['directions'] = await _loadDirections(database, recipeId);

      recipes.add(Recipe.fromMap(recipeMap));
    }

    return recipes;
  }

  Future<Recipe?> load(String id) async {
    final database = await db.database;
    final rows = await database.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rows.isEmpty) {
      return null;
    }

    final recipeRow = rows.first;
    final ingredients = await _loadIngredients(database, id);
    final directions = await _loadDirections(database, id);
    final recipeMap = Map<String, dynamic>.from(recipeRow)
      ..['ingredients'] = ingredients
      ..['directions'] = directions;

    return Recipe.fromMap(recipeMap);
  }

  Future<List<Ingredient>> _loadIngredients(Database db, String recipeId) async {
    final rows = await db.query(
      'ingredients',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
    return rows.map((row) => Ingredient.fromMap(row)).toList();
  }

  Future<List<Direction>> _loadDirections(Database db, String recipeId) async {
    final rows = await db.query(
      'directions',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
      orderBy: 'step_index ASC',
    );
    return rows.map((row) => Direction.fromMap(row)).toList();
  }
  
  Future<int> insert(Recipe recipe) async {
    final database = await db.database;
    return await database.transaction<int>((txn) async {
      final recipeId = await txn.insert('recipes', recipe.toDbMap());

      for (final ingredient in recipe.ingredients) {
        await txn.insert('ingredients', {
          'id': ingredient.id,
          'recipe_id': recipe.id,
          'task_id': null,
          'type': ingredient.category.toMap(),
          'name': ingredient.name,
          'amount': ingredient.amount,
          'unit': ingredient.unit.toMap(),
        });
      }

      if (recipe.directions != null) {
        for (final direction in recipe.directions!) {
          await txn.insert('directions', {
            'recipe_id': recipe.id,
            'step_index': direction.stepIndex,
            'step_title': direction.stepTitle,
            'step_description': direction.stepDescription,
            'step_image': direction.stepImage,
          });
        }
      }

      return recipeId;
    });
  }

  Future<int> update(Recipe recipe) async {
    final database = await db.database;
    return await database.transaction<int>((txn) async {
      final count = await txn.update(
        'recipes',
        recipe.toDbMap(),
        where: 'id = ?',
        whereArgs: [recipe.id],
      );

      await txn.delete('ingredients', where: 'recipe_id = ?', whereArgs: [recipe.id]);
      await txn.delete('directions', where: 'recipe_id = ?', whereArgs: [recipe.id]);

      for (final ingredient in recipe.ingredients) {
        await txn.insert('ingredients', {
          'id': ingredient.id,
          'recipe_id': recipe.id,
          'task_id': null,
          'type': ingredient.category.toMap(),
          'name': ingredient.name,
          'amount': ingredient.amount,
          'unit': ingredient.unit.toMap(),
        });
      }

      if (recipe.directions != null) {
        for (final direction in recipe.directions!) {
          await txn.insert('directions', {
            'recipe_id': recipe.id,
            'step_index': direction.stepIndex,
            'step_title': direction.stepTitle,
            'step_description': direction.stepDescription,
            'step_image': direction.stepImage,
          });
        }
      }

      return count;
    });
  }

  Future<int> delete(String id) async {
    final database = await db.database;
    return await database.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

    Future<int> countTasksUsingRecipe(String recipeId) async {
     final database = await db.database;
    final rows = await database.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM tasks
      WHERE dough_recipe_id = ? OR filling_recipe_id = ?
      ''',
      [recipeId, recipeId],
    );
    final count = rows.first['count'];
    return count is int ? count : int.tryParse(count.toString()) ?? 0;
  }

}
   