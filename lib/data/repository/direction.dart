import '../database/db_helper.dart';
import '../model/direction.dart';

class DirectionRepository {
  final MCDatabase db;
  DirectionRepository(this.db);

  Future<int> insert(Direction direction) async {
    final database = await db.database;
    return await database.insert('directions', direction.toMap());
  }

  Future<Direction?> load(String id) async {
    final database = await db.database;
    final rows = await database.query(
      'directions',
      where: 'id = ?',
      whereArgs: [id],
      orderBy: 'step_index ASC', // Order by stepIndex
    );

    if (rows.isEmpty) {
      return null;
    }

    final directionRow = rows.first;
    return Direction.fromMap(directionRow);
  }

  Future<int> updateDirection(Direction direction) async {
    final database = await db.database;
    return await database.update(
      'directions',
      direction.toMap(),
      where: 'id = ?',
      whereArgs: [direction.id],
    );
  }

  Future<int> deleteDirection(String id) async {
    final database = await db.database;
    return await database.delete(
      'directions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> saveDirections(String recipeId, List<Direction> directions) async {
    final database = await db.database;

    // Start a transaction to ensure atomicity
    await database.transaction((txn) async {
      // Delete existing directions for the recipe
      await txn.delete(
        'directions',
        where: 'recipe_id = ?',
        whereArgs: [recipeId],
      );

      // Insert new directions
      for (var direction in directions) {
        await txn.insert('directions', direction.toMap());
      }
    });
  }

  Future<List<Direction>> getDirectionsByRecipeId(String recipeId) async {
    final database = await db.database;
    final rows = await database.query(
      'directions',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
      orderBy: 'step_index ASC', // Order by stepIndex
    );

    return rows.map((row) => Direction.fromMap(row)).toList();
  }

  Future<void> deleteDirectionsByRecipeId(String recipeId) async {
    final database = await db.database;
    await database.delete(
      'directions',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
  }

}