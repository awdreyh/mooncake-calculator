import 'package:sqflite/sqflite.dart';
import '../seed_data/recipes.dart';

class RecipesSeeder {
  final Database db;
  RecipesSeeder(this.db);

  Future<void> seed() async {
    final batch = db.batch();

    for (final recipe in recipesSeed) {
      final recipeData = {
        'id': recipe['id'],
        'name': recipe['name'],
        'typeId': recipe['typeId'],
        'quantity': recipe['quantity'],
        'size': recipe['size'],
        'ratio': recipe['ratio'],
        'description': recipe['description'],
        'is_favorite': recipe['isFavorite'] ?? false,
        'rating': recipe['rating'],
        'url': recipe['url'],
        'comment': recipe['comment'],
      };

      batch.insert('recipes', recipeData);

      final ingredients = recipe['ingredients'] as List<dynamic>? ?? <dynamic>[];
      for (final ingredientEntry in ingredients) {
        final ingredient = ingredientEntry as Map<String, dynamic>;
        batch.insert('ingredients', {
          'id': ingredient['id'],
          'recipe_id': recipe['id'],
          'task_id': null,
          'type': 'recipe',
          'name': ingredient['name'],
          'amount': ingredient['amount'],
          'unit': ingredient['unit'],
        });
      }
    }

    await batch.commit(noResult: true);
  }
}