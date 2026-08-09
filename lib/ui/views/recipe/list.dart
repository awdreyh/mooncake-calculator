import 'package:flutter/material.dart';
import 'package:moon_cake_app2/provider/type.dart';
import '../../../data/model/type.dart';
import '../../core/nav_bottom.dart';
import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
import 'package:provider/provider.dart';
import '../../../data/model/recipe.dart';
import '../../../data/database/db_helper.dart';
import '../../../data/repository/recipe.dart';
import '../../../data/repository/type.dart';
import '../../../provider/recipe.dart';
import 'add.dart';
import 'details.dart';

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  List<Recipe> _recipes = [];
  String? _errorMessage;
  List<Type> _types = [];
  bool _isLoading = true;
  
  final recipeProvider = RecipeProvider(RecipeRepository(MCDatabase.instance));
  final typeProvider = TypeProvider(TypeRepository(MCDatabase.instance));

  @override
  void initState() {
    super.initState();
    _loadRecipeData();
  }

  Future<void> _loadRecipeData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final recipes = await recipeProvider.loadAllRecipes();
      final types = await typeProvider.loadAllTypes();
      if (!mounted) return;
      setState(() {
        _recipes = recipes;
        _types = types;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  void _refreshRecipes() {
    _loadRecipeData();
  }

  Recipe _recipeWithFavorite(Recipe recipe, bool isFavorite) {
    return Recipe(
      id: recipe.id,
      name: recipe.name,
      typeId: recipe.typeId,
      quantity: recipe.quantity,
      size: recipe.size,
      ratio: recipe.ratio,
      description: recipe.description,
      ingredients: recipe.ingredients,
      isFavorite: isFavorite,
      rating: recipe.rating,
      url: recipe.url,
      comment: recipe.comment,
      directions: recipe.directions,
      createdAt: recipe.createdAt,
      updatedAt: recipe.updatedAt,
    );
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    final newFavorite = !(recipe.isFavorite ?? false);
    final updatedRecipe = _recipeWithFavorite(recipe, newFavorite);

    setState(() {
      final index = _recipes.indexWhere((item) => item.id == recipe.id);
      if (index != -1) {
        _recipes[index] = updatedRecipe;
      }
    });

    try {
      await recipeProvider.updateRecipe(recipe);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final index = _recipes.indexWhere((item) => item.id == recipe.id);
        if (index != -1) {
          _recipes[index] = recipe;
        }
      });
    }
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final lang = languageProvider.languageCode;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.get('delete_recipe', lang)),
        content: Text(
          AppStrings.get(
            'confirm_delete_recipe',
            lang,
          ).replaceFirst('{recipe_name}', recipe.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppStrings.get('delete_recipe', lang),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await recipeProvider.deleteRecipe(recipe.id);
      _refreshRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('recipe_list_title', lang)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recipes.isEmpty
          ? Center(child: Text(AppStrings.get('no_recipes_available', lang)))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _recipes.length,
              separatorBuilder: (context, index) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final recipe = _recipes[index];
                final matching = _types.where(
                  (type) => type.id == recipe.typeId,
                );
                final recipeCategory = matching.isEmpty
                    ? Category.dough
                    : matching.first.category;
                final categoryIcon = recipeCategory == Category.filling
                    ? Icons.icecream
                    : Icons.cookie;
                final categoryLabel = recipeCategory == Category.filling
                    ? AppStrings.get('filling', lang)
                    : AppStrings.get('dough', lang);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: recipeCategory == Category.filling
                        ? Colors.pink.shade50
                        : Colors.orange.shade50,
                    child: Icon(
                      categoryIcon,
                      color: recipeCategory == Category.filling
                          ? Colors.pink
                          : Colors.orange,
                    ),
                  ),
                  title: Text(recipe.name),
                  subtitle: Text(
                    '${AppStrings.get('category', lang)}: $categoryLabel\n'
                    '${AppStrings.get('quantity', lang)}: ${recipe.quantity}, ${AppStrings.get('size', lang)}: ${recipe.size}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: SizedBox(
                    width: 106,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            recipe.isFavorite == true
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: recipe.isFavorite == true
                                ? Colors.red
                                : Colors.grey,
                          ),
                          onPressed: () => _toggleFavorite(recipe),
                          tooltip: recipe.isFavorite == true
                              ? 'Unfavorite'
                              : 'Favorite',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _deleteRecipe(recipe),
                          tooltip: AppStrings.get('delete_recipe', lang),
                        ),
                      ],
                    ),
                  ),
                  onTap: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailsPage(recipe: recipe),
                      ),
                    );
                    if (result == true) {
                      _refreshRecipes();
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const AddRecipePage()),
          );
          if (result == true) {
            _refreshRecipes();
          }
        },
        tooltip: 'Add Recipe',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    );
  }
}
