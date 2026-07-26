import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'category.dart';
import 'recipe.dart';
import 'task.dart';


class MCService {
  MCService({String? databaseName}) : _databaseName = databaseName ?? 'mooncake.db';
  
  static Database? _database;
  final String _databaseName;

   Future<Database> get _databaseInstance async {
    if (_database != null) {
      return _database!;    }
    else {
      _database = await _initDatabase();
      return _database!;
    }
    
   }

   Future<void> _seedDefault(Database db) async {
    final existingTypes = await db.query('types', columns: ['id']);
    if (existingTypes.isEmpty) {
      for (final type in defaultTypes) {
        await db.insert(
          'types',
          {
            'id': type.id,
            'category': type.category.toMap(),
            'name': type.name,
            'matched_dough_type': type.matchedDoughType == null
                ? null
                : jsonEncode(type.matchedDoughType!.map((item) => item.toMap()).toList()),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    final existingRecipes = await db.query('recipes', columns: ['id']);
    if (existingRecipes.isEmpty) {
      for (final recipe in defaultRecipes) {
        await saveRecipe(recipe, database: db);
      }
    }
  }

  Future<Database> _initDatabase() async {  

    final databaseDirectory = await getDatabasesPath();
    final databasePath = '${databaseDirectory}${Platform.pathSeparator}$_databaseName';

    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async { 
        await db.execute('''
          CREATE TABLE recipes (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
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
            id INTEGER PRIMARY KEY AUTOINCREMENT,
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
            matched_dough_type TEXT
          )
        ''');
        await _seedDefault(db);
      },
      onOpen: (db) async {
        await _seedDefault(db);
      },
      );

   return _database!;
  }

 Future<String> saveRecipe(Recipe recipe, {Database? database}) async {
    final db = database ?? await _databaseInstance;
    return await recipe.save(db);
  }

  Future<String> saveTask(Task task, {Database? database}) async {
    final db = database ?? await _databaseInstance;
    return await task.save(db);
  }

 
  Future<List<Type>> getDoughType({Database? database}) async {
    final db = database ?? await _databaseInstance;
    final rows = await db.query(
      'types',
      where: 'category = ?',
      whereArgs: [Category.dough.toMap()],
    );
    return rows.map((row) => Type.fromMap(_rowToMap(row))).toList();
  }

  Map<String, dynamic> _rowToMap(Map<String, Object?> row) {
    final map = <String, dynamic>{
      'id': row['id'] as String,
      'category': row['category'] as String,
      'name': row['name'] as String,
    };
    if (row['matched_dough_type'] != null) {
      map['matchedDoughType'] = jsonDecode(row['matched_dough_type'] as String) as List<dynamic>;
    }
    return map;
  }
}


