import 'package:flutter/material.dart';
import '../data/model/type.dart';
import '../data/repository/type.dart';

class TypeProvider extends ChangeNotifier {
  final TypeRepository repository;
  TypeProvider(this.repository);

  List<Type> _types = [];
  bool _isLoading = false;

  List<Type> get types => _types;
  bool get isLoading => _isLoading;


  Future<List<Type>> loadAllTypes() async {
    _isLoading=true;
    //notifyListeners();

    _types  = await repository.loadAll();
    _isLoading = false;
    notifyListeners();

    return _types;
  }

  Future<Type> loadType(String id) async {
    final result = await repository.load(id);
    if (result == null) {
      throw Exception('Type with id $id not found');
    }
    notifyListeners();
    return result;
  }

  Future<List<Type>> loadTypesByCategory(Category category) async {
    final result = await repository.loadByCategory(category);
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
