import 'package:flutter/material.dart';
import '../data/model/recipe.dart';
import '../data/repository/recipe.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository repository;
  RecipeProvider(this.repository);

  Future<Recipe?> loadRecipe(String id) async { 
    Recipe? result = await repository.load(id);
    notifyListeners();
    return result;   
  }

  Future<List<Recipe>> loadAllRecipes() async {
    List<Recipe> result = await repository.loadAll();
    notifyListeners();
    return result;
  }

  Future<void> insertRecipe(Recipe recipe) async {
    await repository.insert(recipe);
    await loadRecipe(recipe.id); 
  }

  Future<void> deleteRecipe(String id) async {
     await repository.delete(id);
     await loadRecipe(id); 
   
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await repository.update(recipe);
    await loadRecipe(recipe.id); 
  }

  Future<void> updateRecipeFavorite(String recipeId, bool isFavorite) async {
    await repository.updateFavorite(recipeId, isFavorite);
    notifyListeners();
  }

  Future<int> countTasksUsingRecipe(String recipeId) async {
    return await repository.countTasksUsingRecipe(recipeId);
  }

 


}
