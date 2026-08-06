import 'package:flutter/material.dart';
import '../db/model/ingredient.dart';
import '../db/repository/ingredient.dart';


class IngredientProvider extends ChangeNotifier {
  final IngredientRepository repository;
 // List<Ingredient> ingredients = [];
  IngredientProvider(this.repository);

  Future<Ingredient?> loadIngredient(String id) async {   
    return await repository.load(id);   
  }
  Future<String> insertIngredient(Ingredient ingredient) async {
    await repository.insert(ingredient);
    notifyListeners();
    return ingredient.id;
  }

}