import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../model/recipe.dart';
import '../model/ingredient.dart';
import '../model/direction.dart';
import 'type.dart' as type_repo;

class RecipeRepository {
  final MCDatabase db;
  RecipeRepository(this.db);
  Future<List<Recipe>> loadAll() async {
    final database = await db.database;
    final result = await database.query('recipes');

    final recipes = <Recipe>[];
    for (final recipeRow in result) {
      final recipeId = recipeRow['id'] as String;
      final ingredients = await _loadIngredients(database, recipeId);
      final directions = await _loadDirections(database, recipeId);

      final recipeMap = Map<String, dynamic>.from(recipeRow)
        ..['ingredients'] = ingredients.map((i) => i.toMap()).toList()
        ..['directions'] = directions.map((d) => d.toMap()).toList();

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
          .map((ingredient) => ingredient.toMap())
          .toList()
      ..['directions'] = directions
          .map((direction) => direction.toMap())
          .toList();

    return Recipe.fromMap(recipeMap);
  }

  Future<String> loadType(String id) async {
    final recipe = await load(id);
    if (recipe?.typeId == null) return '';
    final type = await type_repo.TypeRepository(db).load(recipe!.typeId!);
    return type?.name ?? '';
  }

  Future<List<Ingredient>> _loadIngredients(
    Database db,
    String recipeId,
  ) async {
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
      final recipeId = await txn.insert('recipes', recipe.toMap());

      for (final ingredient in recipe.ingredients) {
        await txn.insert('ingredients', {
          'id': ingredient.id,
          'recipe_id': recipe.id,
          'task_id': null,
          'name': ingredient.name,
          'amount': ingredient.amount,
          'unit': ingredient.unit.toMap(),
          'category': ingredient.category.toMap(),
        });
      }

      if (recipe.directions != null) {
        for (final direction in recipe.directions!) {
          await txn.insert('directions', {
            'recipe_id': recipe.id,
            'step_index': direction.stepIndex,
            'step_title': direction.stepTitle,
            'step_description': direction.stepDescription,
            'step_image_path': direction.stepImagePath,
          });
        }
      }

      return recipeId;
    });
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

  Future<int> updateFavorite(String recipeId, bool isFavorite) async {
    final database = await db.database;
    return await database.update(
      'recipes',
      {
        'is_favorite': isFavorite ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [recipeId],
    );
  }

  Future<int> delete(String id) async {
    final database = await db.database;
    return await database.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveDirections(List<Map<String, dynamic>> directions) async {
    final database = await db.database;
    await database.transaction((txn) async {
      for (final direction in directions) {
        final existingDirection = await txn.query(
          'directions',
          where: 'id = ?',
          whereArgs: [direction['id']],
        );

        if (existingDirection.isNotEmpty) {
          // Update existing direction
          await txn.update(
            'directions',
            direction,
            where: 'id = ?',
            whereArgs: [direction['id']],
          );
        } else {
          // Insert new direction
          await txn.insert('directions', direction);
        }
      }
    });
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
