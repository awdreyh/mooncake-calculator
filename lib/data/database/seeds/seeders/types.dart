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
        'id': type['id'],
        'category': type['category'],
        'name': type['name'],
        'image_path': type['image_path'],
        'matched_dough_type_ids': type['matched_dough_type_ids'] == null
            ? null
            : jsonEncode(type['matched_dough_type_ids']),
      });
    }
    await batch.commit(noResult: true);
  }
}