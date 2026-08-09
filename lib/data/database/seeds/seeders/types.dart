import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../seed_data/type.dart';

class TypesSeeder {
  final Database db;
  TypesSeeder(this.db);

  Future<void> seed() async {
    final batch = db.batch();
    for (final type in typesSeed) {
      batch.insert('types', {
        ...type,
        'matchedDoughTypeIds': type['matchedDoughTypeIds'] == null
            ? null
            : jsonEncode(type['matchedDoughTypeIds']),
      });
    }
    await batch.commit(noResult: true);
  }
}