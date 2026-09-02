import 'package:moon_cake_app/data/database/seeds/seeders/types.dart';
import 'package:sqflite/sqflite.dart';
import 'package:moon_cake_app/data/database/seeds/seeders/recipes.dart';


class SeedManager {
  final Database db;
  SeedManager(this.db);

  Future<void> seedAll() async {
  await TypesSeeder(db).seed();
  await RecipesSeeder(db).seed();
  }
}