import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:moon_cake_app2/dbSeed/recipe.dart' as db_seed_recipe;
import 'package:moon_cake_app2/dbSeed/type.dart' as db_seed_type;


class MCDatabase {
  static const int _dbVersion = 3;
  static final MCDatabase instance = MCDatabase._init();
  static Database? _database;

  MCDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mc.db');
    return _database!;
  }

  Future<void> reset() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    await Directory(dirname(path)).create(recursive: true);

    final databaseFile = File(path);
    final shouldCopyAsset = !await databaseFile.exists();

    if (shouldCopyAsset) {
      try {
        final assetData = await rootBundle.load('assets/db/feed.db');
        final bytes = assetData.buffer.asUint8List();
        await databaseFile.writeAsBytes(bytes, flush: true);
      } catch (_) {
        // Fall back to creating the database schema directly if the asset is missing.
      }
    }

    final db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
    await _ensureSeeded(db);
    return db;
  }

  Future<void> _ensureSeeded(Database db) async {
    try {
      final countRes = await db.rawQuery('SELECT COUNT(*) AS c FROM types');
      final count = countRes.isNotEmpty ? countRes.first['c'] : 0;
      final typesCount = count is int ? count : int.tryParse(count.toString()) ?? 0;
      if (typesCount > 0) return;

      await db.transaction((txn) async {
        for (final type in db_seed_type.defaultTypes) {
          await txn.insert('types', {
            'id': type.id,
            'category': type.category.toMap(),
            'name': type.name,
            'imagePath': type.imagePath,
            'matched_dough_type': type.matchedDoughTypeIds == null
                ? null
                : jsonEncode(type.matchedDoughTypeIds),
          });
        }

        for (final recipe in db_seed_recipe.defaultRecipes) {
          await txn.insert('recipes', {
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
        }
      });
    } catch (error) {
      // Keep startup resilient and allow the app to continue even if initial seeding fails.
      // This avoids a hard failure when the bundled asset is missing or malformed.
      debugPrint('Database seed failed: $error');
    }
  }

 
  Future _createDB(Database db, int version) async {
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
            image_paths TEXT,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now')),
            comment TEXT,
            rating REAL,
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
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final columns = await db.rawQuery("PRAGMA table_info(tasks)");
      final hasImagePaths = columns.any((column) => column['name'] == 'image_paths');
      if (!hasImagePaths) {
        await db.execute('ALTER TABLE tasks ADD COLUMN image_paths TEXT');
      }
    }

    if (oldVersion < 3) {
      final columns = await db.rawQuery("PRAGMA table_info(tasks)");
      final hasRating = columns.any((column) => column['name'] == 'rating');
      if (!hasRating) {
        await db.execute('ALTER TABLE tasks ADD COLUMN rating REAL');
      }
    }
  }
}
