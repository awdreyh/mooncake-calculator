import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../model/recipe.dart';
import '../model/ingredient.dart';
import '../model/direction.dart';
import '../model/type.dart';

class RecipeRepository {  
  final MCDatabase db;
  RecipeRepository(this.db);
  
  Future<List<Recipe>> loadAll() async {
    final database = await db.database;
    final result = await database.query('recipes');
    return result.map((map) => Recipe.fromMap(map)).toList();
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
    return await database.insert('recipes', recipe.toMap());
  }

  Future<int> update(Recipe recipe) async {
    final database = await db.database;
    return await database.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
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
   