import 'package:flutter/material.dart';
import '../../../db/type.dart';
import '../../core/nav_bottom.dart';
import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
import 'package:provider/provider.dart';
import '../../../db/recipe.dart';
import '../../../db/db_helper.dart';
import 'add.dart';
import 'details.dart';


class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  late Future<Map<String, dynamic>> _dataFuture;
  final MCService _mcService = MCService();

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadRecipeData();
  }

  Future<Map<String, dynamic>> _loadRecipeData() async {
    final recipes = await _mcService.loadRecipes();
    final types = await _mcService.loadTypes();
    return {'recipes': recipes, 'types': types};
  }

  void _refreshRecipes() {
    setState(() {
      _dataFuture = _loadRecipeData();
    });
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    await _mcService.updateRecipeFavorite(recipe.id, !(recipe.isFavorite ?? false));
    _refreshRecipes();
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final lang = languageProvider.languageCode;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.get('delete_recipe', lang)),
        content: Text(AppStrings.get('confirm_delete_recipe', lang).replaceFirst('{recipe_name}', recipe.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppStrings.get('delete', lang),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _mcService.deleteRecipe(recipe.id);
      _refreshRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    return Scaffold(
      appBar: AppBar(
        title:  Text(AppStrings.get('recipe_list_title', lang)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading recipes: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!['recipes'] == null || (snapshot.data!['recipes'] as List).isEmpty) {
            return Center(child: Text(AppStrings.get('no_recipes_available', lang)));
          }

          final recipes = snapshot.data!['recipes'] as List<Recipe>;
          final types = snapshot.data!['types'] as List<Type>;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: recipes.length,
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final recipeCategory = Type.categoryById(recipe.typeId, types: types);
              final categoryIcon = recipeCategory == Category.filling ? Icons.icecream : Icons.cookie;
              final categoryLabel = recipeCategory == Category.filling
                  ? AppStrings.get('filling', lang)
                  : AppStrings.get('dough', lang);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: recipeCategory == Category.filling
                      ? Colors.pink.shade50
                      : Colors.orange.shade50,
                  child: Icon(categoryIcon,
                    color: recipeCategory == Category.filling ? Colors.pink : Colors.orange,
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
                          recipe.isFavorite == true ? Icons.favorite : Icons.favorite_border,
                          color: recipe.isFavorite == true ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => _toggleFavorite(recipe),
                        tooltip: recipe.isFavorite == true ? 'Unfavorite' : 'Favorite',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
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