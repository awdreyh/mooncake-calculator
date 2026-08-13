import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'seeds/seed_manager.dart';

class MCDatabase {
  static final MCDatabase instance = MCDatabase._init();
  static Database? _database;

  MCDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mc.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
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
            name TEXT NOT NULL,
            amount REAL NOT NULL,
            unit TEXT NOT NULL,
            category TEXT NOT NULL,
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
            rating REAL,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now')),
            comment TEXT,
            is_completed BOOLEAN NOT NULL DEFAULT 0,
            FOREIGN KEY (dough_recipe_id) REFERENCES recipes (id),
            FOREIGN KEY (filling_recipe_id) REFERENCES recipes (id)
          )
        ''');
    await db.execute('''
          CREATE TABLE types (
            id TEXT PRIMARY KEY,
            category TEXT NOT NULL,
            name TEXT NOT NULL,
            image_path TEXT,
            matched_dough_type_ids TEXT
            
          )
        ''');

        await SeedManager(db).seedAll();
  }

  
}
