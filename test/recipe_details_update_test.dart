import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cake_app2/db/db_helper.dart';
import '../../db/model/ingredient.dart';
import 'package:moon_cake_app2/db/recipe.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('saving recipe details persists rating, comment, and matched dough types', () async {
    final service = MCService(databaseName: 'recipe_details_update_test.db');
    final dbPath = await getDatabasesPath();
    await deleteDatabase('$dbPath/recipe_details_update_test.db');

    final recipe = Recipe(
      id: 'recipe-details-test',
      name: 'Test Recipe',
      typeId: 'f7a5d8b9-2c1f-4f3d-a8bd-2a4e7d5c9e1f',
      quantity: 8,
      size: 100,
      ratio: 0.4,
      ingredients: <Ingredient>[],
      description: 'Original description',
      comment: 'Original comment',
      rating: 3.5,
    );

    await service.saveRecipe(recipe);

    final updatedRecipe = Recipe(
      id: recipe.id,
      name: recipe.name,
      typeId: recipe.typeId,
      quantity: recipe.quantity,
      size: recipe.size,
      ratio: recipe.ratio,
      description: recipe.description,
      ingredients: recipe.ingredients,
      comment: 'Updated comment',
      rating: 4.5,
      isFavorite: recipe.isFavorite,
    );

    await service.updateRecipeDetails(updatedRecipe);
    await service.updateTypeMatchedDoughTypes(
      recipe.typeId!,
      ['7a91f6c1-4c5d-482e-a15a-7d9e7b3c0f89', 'c1d2f9b4-5e6a-4d73-9998-8c3f6c7f3e5a'],
    );

    final reloadedRecipe = await service.loadRecipe(recipe.id);
    final types = await service.loadTypes();
    final fillingType = types.firstWhere((type) => type.id == recipe.typeId);

    expect(reloadedRecipe?.comment, 'Updated comment');
    expect(reloadedRecipe?.rating, 4.5);
    expect(fillingType.matchedDoughTypeIds, isNotNull);
    expect(fillingType.matchedDoughTypeIds, ['7a91f6c1-4c5d-482e-a15a-7d9e7b3c0f89', 'c1d2f9b4-5e6a-4d73-9998-8c3f6c7f3e5a']);
  });
}
