import 'package:flutter/material.dart';
import '../data/model/direction.dart';
import '../data/repository/direction.dart';


class DirectionProvider extends ChangeNotifier {
  final DirectionRepository repository;
  DirectionProvider(this.repository);

  Future<Direction?> loadDirection(String id) async {   
    return await repository.load(id);   
  }
  Future<String> insertDirection(Direction direction) async {
    await repository.insert(direction);
    notifyListeners();
    return direction.id;
  }  

  Future<void> updateDirection(Direction direction) async {
    await repository.updateDirection(direction);
    notifyListeners();
  }

  Future<void> deleteDirection(String id) async {
    await repository.deleteDirection(id);
    notifyListeners();
  }

  Future saveDirections(String recipeId, List<Direction> directions) async {
    await repository.saveDirections(recipeId, directions);
    notifyListeners();
  }

  Future<List<Direction>> getDirections(String recipeId, String lang) async {
    return await repository.getDirectionsByRecipeId(recipeId);
  }

  Future<void> deleteDirectionsByRecipeId(String recipeId) async {
    await repository.deleteDirectionsByRecipeId(recipeId);
    notifyListeners();
  }

}