import 'package:flutter/material.dart';
import '../db/model/type.dart';
import '../db/repository/type.dart';

class TypeProvider extends ChangeNotifier {
  final TypeRepository repository;
  TypeProvider(this.repository);

  Future<List<Type>> loadAllTypes() async {
    final result = await repository.loadAll();
    notifyListeners();
    return result;
  }

  Future<Type> loadType(String id) async {
    final result = await repository.load(id);
    if (result == null) {
      throw Exception('Type with id $id not found');
    }
    notifyListeners();
    return result;
  }

  Future<String?> loadTypeName(String id) async {
    final type = await repository.load(id);
    notifyListeners();
    return type?.name;
  }

  Future<void> insertType(Type type) async {
    await repository.insert(type);
    notifyListeners();
  }

  Future<void> updateType(Type type) async {
    await repository.update(type);
    notifyListeners();
  }

  Future<List<Type>> loadMatchedDoughTypes(String? recipeTypeId) async {
    final result = await repository.loadMatchedDoughTypes(recipeTypeId);
    notifyListeners();
    return result;
  }

  Future<void> deleteType(String id) async {
    await repository.delete(id);
    notifyListeners();
  }
}
