import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import '../model/type.dart';

class TypeRepository {
  final MCDatabase db;
  TypeRepository(this.db);

  Future<List<Type>> loadAll() async {
    final database = await db.database;
    final rows = await database.query('types');
    return rows.map(_fromRow).toList();
  }

  Future<Type?> load(String id) async {
    final database = await db.database;
    final rows = await database.query(
      'types',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rows.isEmpty) {
      return null;
    }

    return _fromRow(rows.first);
  }

  Future<int> insert(Type type) async {
    final database = await db.database;
    return await database.insert(
      'types',
      _toRow(type),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(Type type) async {
    final database = await db.database;
    return await database.update(
      'types',
      _toRow(type),
      where: 'id = ?',
      whereArgs: [type.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> delete(String id) async {
    final database = await db.database;
    return await database.delete(
      'types',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Type>> loadMatchedDoughTypes(String? recipeTypeId) async {
    if (recipeTypeId == null) {
      return [];
    }

    final allTypes = await loadAll();
    final recipeType = allTypes.firstWhere(
      (type) => type.id == recipeTypeId,
      orElse: () => Type(
        id: recipeTypeId,
        category: Category.dough,
        name: '',
        matchedDoughTypeIds: <String>[],
      ),
    );

    if (recipeType.category != Category.filling) {
      return [];
    }

    final matchedDoughTypeIds = recipeType.matchedDoughTypeIds ?? [];
    return allTypes
        .where((type) =>
            type.category == Category.dough && matchedDoughTypeIds.contains(type.id))
        .toList();
  }

  Type _fromRow(Map<String, dynamic> row) {
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
      'imageName': row['imageName']?.toString(),
      'matchedDoughTypeIds': matchedDoughTypeIds,
    });
  }

  Map<String, dynamic> _toRow(Type type) {
    return {
      'id': type.id,
      'category': type.category.toMap(),
      'name': type.name,
      'imageName': type.imageName,
      'matched_dough_type': type.matchedDoughTypeIds == null
          ? null
          : jsonEncode(type.matchedDoughTypeIds),
    };
  }
}
