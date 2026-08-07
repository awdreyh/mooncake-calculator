import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:moon_cake_app2/dbSeed/recipe.dart';
import 'package:moon_cake_app2/dbSeed/type.dart';

Future<void> main() async {
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  final dbFile = File(p.join(Directory.current.path, 'assets', 'db', 'feed.db'));
  if (dbFile.existsSync()) {
    stdout.writeln('Removing existing ${dbFile.path}');
    dbFile.deleteSync();
  }

  final db = await databaseFactory.openDatabase(dbFile.path);
  try {
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
      CREATE TABLE directions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id TEXT NOT NULL,
        step_index TEXT NOT NULL,
        step_title TEXT NOT NULL,
        step_description TEXT NOT NULL,
        step_image TEXT,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
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
        unit TEXT NOT NULL,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        dough_recipe_id TEXT NOT NULL,
        filling_recipe_id TEXT NOT NULL,
        size INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        ratio REAL NOT NULL,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        comment TEXT,
        is_completed BOOLEAN NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE types (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        name TEXT NOT NULL,
        imagePath TEXT,
        matched_dough_type TEXT
      )
    ''');

    for (final type in defaultTypes) {
      await db.insert('types', {
        'id': type.id,
        'category': type.category.toMap(),
        'name': type.name,
        'imagePath': type.imagePath,
        'matched_dough_type': type.matchedDoughTypeIds == null
            ? null
            : jsonEncode(type.matchedDoughTypeIds),
      });
    }

    for (final recipe in defaultRecipes) {
      await db.insert('recipes', {
        'id': recipe.id,
        'name': recipe.name,
        'typeId': recipe.typeId,
        'quantity': recipe.quantity,
        'size': recipe.size,
        'ratio': recipe.ratio,
        'description': recipe.description,
        'is_favorite': recipe.isFavorite == true ? 1 : 0,
        'rating': recipe.rating,
        'url': recipe.url,
        'comment': recipe.comment,
      });

      for (final ingredient in recipe.ingredients) {
        await db.insert('ingredients', {
          'id': ingredient.id,
          'recipe_id': recipe.id,
          'task_id': null,
          'type': ingredient.category.toMap(),
          'name': ingredient.name,
          'amount': ingredient.amount,
          'unit': ingredient.unit.toMap(),
        });
      }
    }

    stdout.writeln('Seeded feed.db with ${defaultTypes.length} types and ${defaultRecipes.length} recipes.');
  } finally {
    await db.close();
  }
}
