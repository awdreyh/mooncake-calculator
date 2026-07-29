import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cake_app2/db/type.dart';
import 'package:moon_cake_app2/db/recipe.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('getTypeById loads type from the types table', () async {
    final db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE types (
            id TEXT PRIMARY KEY,
            category TEXT NOT NULL,
            name TEXT NOT NULL,
            matched_dough_type TEXT
          )
        ''');
      },
    );

    await db.insert('types', {
      'id': 'type-1',
      'category': Category.dough.toMap(),
      'name': '广式月饼',
      'matched_dough_type': null,
    });

    final type = await Recipe.getTypeById(db, 'type-1');

    expect(type, isNotNull);
    expect(type!.id, 'type-1');
    expect(type.name, '广式月饼');
    expect(type.category, Category.dough);

    await db.close();
  });

  test('getCategory uses the recipe typeId to load the category', () async {
    final db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE types (
            id TEXT PRIMARY KEY,
            category TEXT NOT NULL,
            name TEXT NOT NULL,
            matched_dough_type TEXT
          )
        ''');
      },
    );

    await db.insert('types', {
      'id': 'type-2',
      'category': Category.filling.toMap(),
      'name': '红豆沙',
      'matched_dough_type': '[]',
    });

    final recipe = Recipe(
      id: 'recipe-1',
      name: 'Test recipe',
      typeId: 'type-2',
      quantity: 1,
      size: 1,
      ratio: 0.4,
      ingredients: const [],
    );

    final category = await recipe.getCategory(db);

    expect(category, isNotNull);
    expect(category, Category.filling);

    await db.close();
  });
}
