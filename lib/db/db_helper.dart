import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'type.dart';
import 'recipe.dart';
import 'task.dart';

class MCService {
  MCService({String? databaseName})
    : _databaseName = databaseName ?? 'mooncake.db';

  static Database? _database;
  final String _databaseName;

  Future<Database> get _databaseInstance async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }

  Future<void> _seedDefault(Database db) async {
    final existingTypes = await db.query('types', columns: ['id']);
    if (existingTypes.isEmpty) {
      for (final type in defaultTypes) {
        await db.insert('types', {
          'id': type.id,
          'category': type.category.toMap(),
          'name': type.name,
          'matched_dough_type': type.matchedDoughTypeIds == null
              ? null
              : jsonEncode(
                  type.matchedDoughTypeIds!
                      .map((item) => item.toString())
                      .toList(),
                ),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
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
    final databasePath =
        '${databaseDirectory}${Platform.pathSeparator}$_databaseName';

    _database = await openDatabase(
      databasePath,
      version: 2,
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
            matched_dough_type TEXT
          )
        ''');
        await _seedDefault(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE tasks RENAME TO tasks_old');
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
            INSERT INTO tasks (
              id,
              dough_recipe_id,
              filling_recipe_id,
              size,
              quantity,
              ratio,
              created_at,
              updated_at,
              comment,
              is_completed
            )
            SELECT
              CAST(id AS TEXT),
              dough_recipe_id,
              filling_recipe_id,
              size,
              quantity,
              ratio,
              created_at,
              updated_at,
              comment,
              is_completed
            FROM tasks_old
          ''');
          await db.execute('DROP TABLE tasks_old');
        }
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

  Future<List<Recipe>> loadRecipes({Database? database}) async {
    final db = database ?? await _databaseInstance;
    return await Recipe.loadAll(db);
  }

  Future<List<Type>> loadTypes({Database? database}) async {
    final db = database ?? await _databaseInstance;
    final rows = await db.query('types');
    return rows.map((row) {
      final matchedDoughTypeValue = row['matched_dough_type'];
      final matchedDoughTypeIds = matchedDoughTypeValue == null
          ? null
          : (jsonDecode(matchedDoughTypeValue as String) as List<dynamic>)
                .map((item) => item.toString())
                .toList();

      return Type.fromMap({
        'id': row['id']?.toString(),
        'category': row['category']?.toString(),
        'name': row['name']?.toString(),
        'matchedDoughTypeIds': matchedDoughTypeIds,
      });
    }).toList();
  }

  Future<Recipe?> loadRecipe(String id, {Database? database}) async {
    final db = database ?? await _databaseInstance;
    return await Recipe.load(db, id);
  }

  Future<int> updateRecipeFavorite(
    String id,
    bool isFavorite, {
    Database? database,
  }) async {
    final db = database ?? await _databaseInstance;
    return await db.update(
      'recipes',
      {
        'is_favorite': isFavorite ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteRecipe(String id, {Database? database}) async {
    final db = database ?? await _databaseInstance;
    await db.delete('directions', where: 'recipe_id = ?', whereArgs: [id]);
    await db.delete('ingredients', where: 'recipe_id = ?', whereArgs: [id]);
    return await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  Future<String> saveTask(Task task, {Database? database}) async {
    final db = database ?? await _databaseInstance;
    return await task.save(db);
  }

  Future<Task?> loadTask(String id, {Database? database}) async {
    final db = database ?? await _databaseInstance;
    return await Task.load(db, id);
  }

  Future<List<Task>> loadTasks({Database? database}) async {
    final db = database ?? await _databaseInstance;
    return await Task.loadAll(db);
  }

  Future<int> countTasksUsingRecipe(
    String recipeId, {
    Database? database,
  }) async {
    final db = database ?? await _databaseInstance;
    final rows = await db.rawQuery(
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

  Future<List<Task>> loadTasksUsingRecipe(
    String recipeId, {
    Database? database,
  }) async {
    final db = database ?? await _databaseInstance;
    final rows = await db.query(
      'tasks',
      where: 'dough_recipe_id = ? OR filling_recipe_id = ?',
      whereArgs: [recipeId, recipeId],
    );

    return Future.wait(
      rows.map((taskRow) async {
        final taskId = taskRow['id'].toString();
        final ingredients = await Task.load(
          db,
          taskId,
        ).then((task) => task?.ingredients ?? []);
        final taskMap = Map<String, dynamic>.from(taskRow)
          ..['ingredients'] = ingredients
              .map((ingredient) => ingredient.toMap())
              .toList();
        return Task.fromMap(taskMap);
      }),
    );
  }
}
