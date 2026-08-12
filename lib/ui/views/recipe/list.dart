import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/model/recipe.dart';
import '../../../data/model/type.dart';
import '../../../provider/recipe.dart';
import '../../../provider/type.dart';
import '../../core/nav_bottom.dart';
import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
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
      final recipes = await context.read<RecipeProvider>().loadAllRecipes();
      final types = await context.read<TypeProvider>().loadAllTypes();
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
    return recipe.copyWith(isFavorite: isFavorite);
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    final index = _recipes.indexWhere((item) => item.id == recipe.id);
    if (index == -1) return;

    final currentRecipe = _recipes[index];
    final newFavorite = !(currentRecipe.isFavorite ?? false);
    final updatedRecipe = _recipeWithFavorite(currentRecipe, newFavorite);

    setState(() {
      _recipes[index] = updatedRecipe;
    });

    try {
      await context
          .read<RecipeProvider>()
          .updateRecipeFavorite(updatedRecipe.id, newFavorite);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final rollbackIndex = _recipes.indexWhere(
          (item) => item.id == recipe.id,
        );
        if (rollbackIndex != -1) {
          _recipes[rollbackIndex] = currentRecipe;
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
      // ignore: use_build_context_synchronously
      await context.read<RecipeProvider>().deleteRecipe(recipe.id);
      _refreshRecipes();
    }
  }

  Category _categoryForRecipe(Recipe recipe) {
    final matching = _types.where((type) => type.id == recipe.typeId);
    return matching.isEmpty ? Category.dough : matching.first.category;
  }

  List<Recipe> _recipesByCategory(Category category) {
    return _recipes
        .where((recipe) => _categoryForRecipe(recipe) == category)
        .toList();
  }

  Widget _buildRecipeList(List<Recipe> recipes, String lang) {
    if (recipes.isEmpty) {
      return Center(child: Text(AppStrings.get('noRecipesAvailable', lang)));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: recipes.length,
      separatorBuilder: (context, index) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        final recipeCategory = _categoryForRecipe(recipe);
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
                    color: recipe.isFavorite == true ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => _toggleFavorite(recipe),
                  tooltip: recipe.isFavorite == true ? 'Unfavorite' : 'Favorite',
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
    );
  }

  Widget _buildBody(String lang) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    return TabBarView(
      children: [
        _buildRecipeList(_recipesByCategory(Category.dough), lang),
        _buildRecipeList(_recipesByCategory(Category.filling), lang),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('recipe_list_title', lang)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.cookie),
                text: AppStrings.get('dough', lang),
              ),
              Tab(
                icon: const Icon(Icons.icecream),
                text: AppStrings.get('filling', lang),
              ),
            ],
          ),
        ),
        body: _buildBody(lang),
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
          tooltip: AppStrings.get('addRecipe', lang),
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
      ),
    );
  }
}
