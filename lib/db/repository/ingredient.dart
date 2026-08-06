import '../db_helper.dart';
import '../model/ingredient.dart';

class IngredientRepository {
  final MCDatabase db;
  IngredientRepository(this.db);


  Future<int> insert(Ingredient ingredient) async {
    final database = await db.database;
    return await database.insert('ingredient', ingredient.toMap());  
  }

  Future<Ingredient?> load(String id) async {
    final database = await db.database;
    final rows = await database.query(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rows.isEmpty) {
      return null;
    }

    final ingredientRow = rows.first;
    return Ingredient.fromMap(ingredientRow);
  }

  Future<int> updateIngredient(Ingredient ingredient) async {
    final database = await db.database;
    return await database.update(
      'recipes',
      ingredient.toMap(),
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );
  } 

 Future<int> deleteIngredient(int id) async {
    final database = await db.database;
    return await database.delete(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  } 

}