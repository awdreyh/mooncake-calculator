import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cake_app2/db/recipe.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('recipe helpers return the linked recipe name and type', () async {
    final db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE recipes (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          typeId TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          size INTEGER NOT NULL,
          ratio REAL NOT NULL,
          description TEXT,
          is_favorite BOOLEAN NOT NULL DEFAULT 0,
          rating REAL,
          url TEXT,
          comment TEXT,
          created_at TEXT NOT NULL DEFAULT (datetime('now')),
          updated_at TEXT NOT NULL DEFAULT (datetime('now'))
        )
      ''');
      await db.execute('''
        CREATE TABLE ingredients (
          id TEXT PRIMARY KEY,
          recipe_id TEXT,
          task_id TEXT,
          type TEXT NOT NULL,
          name TEXT NOT NULL,
          amount REAL NOT NULL,
          unit TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE directions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          recipe_id TEXT NOT NULL,
          step_index TEXT NOT NULL,
          step_title TEXT NOT NULL,
          step_description TEXT NOT NULL,
          step_image TEXT
        )
      ''');
    });

    await db.insert('recipes', {
      'id': 'recipe-1',
      'name': 'Classic Mooncake',
      'typeId': 'type-1',
      'quantity': 8,
      'size': 100,
      'ratio': 0.4,
      'description': null,
      'is_favorite': 0,
      'rating': null,
      'url': null,
      'comment': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    final name = await Recipe.getNamebyRecipeId(db, 'recipe-1');
    final type = await Recipe.getTypebyRecipeId(db, 'recipe-1');

    expect(name, 'Classic Mooncake');
    expect(type, 'type-1');

    await db.close();
  });
}
