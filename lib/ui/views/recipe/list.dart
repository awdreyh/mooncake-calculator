import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/model/recipe.dart';
import '../../../data/model/type.dart';
import '../../../provider/recipe.dart';
import '../../../provider/type.dart';
import '../../core/nav_bottom.dart';
import '../../core/app_theme.dart';
import '../../utils/app_strings.dart';
import '../../utils/seeds_strings.dart';
import '../../utils/language_provider.dart';
import '../../utils/helper.dart';
import '../../widgets/info_chips.dart';
import 'add.dart';
import 'details.dart';

class RecipeListPage extends StatefulWidget {
  final String? typeId;
  const RecipeListPage({super.key, this.typeId});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  List<Recipe> _recipes = [];
  LanguageProvider get languageProvider =>
      Provider.of<LanguageProvider>(context, listen: false);
  String get lang => languageProvider.languageCode;
  String? _errorMessage;
  List<Type> _types = [];
  bool _isLoading = true;
  // recipeId -> number of tasks using it
  final Map<String, int> _usageCounts = {};
  Type? paraType;
  Category? paraCategory;

  @override
  void initState() {
    super.initState();
    _loadRecipeData();
    _loadParaType();
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
      final counts = await Future.wait(
        recipes.map(
          (r) => context.read<RecipeProvider>().countTasksUsingRecipe(r.id),
        ),
      );
      if (!mounted) return;
      setState(() {
        _recipes = recipes;
        _types = types;
        _usageCounts
          ..clear()
          ..addEntries(
            Iterable.generate(
              recipes.length,
              (i) => MapEntry(recipes[i].id, counts[i]),
            ),
          );
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
    return recipe.copyWith(isFavorite: isFavorite, updatedAt: recipe.updatedAt);
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
      await context.read<RecipeProvider>().updateRecipeFavorite(
        updatedRecipe.id,
        newFavorite,
      );
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
    final usage = _usageCounts[recipe.id] ?? 0;
    if (usage > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('recipe_in_use_cannot_delete', lang)),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.get('delete_recipe', lang)),
        content: Text(
          AppStrings.get(
            'confirm_delete_recipe',
            lang,
          ).replaceFirst('{recipe_name}', SeedsStrings.get(recipe.name, lang).isNotEmpty ? SeedsStrings.get(recipe.name, lang) : recipe.name),
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

  Future<void> _loadParaType() async {
    if (widget.typeId != null) {
      try {
        final type = await context.read<TypeProvider>().loadType(
          widget.typeId!,
        );
        if (!mounted) return;
        setState(() {
          paraType = type;
          paraCategory = type.category;
        });
      } catch (error) {
        if (!mounted) return;
        setState(() {
          _errorMessage = error.toString();
        });
      }
    }
  }

  List<Recipe> _recipesByCategory(Category category) {
    if (widget.typeId != null && paraCategory == category) {
      return _recipes
          .where(
            (recipe) =>
                _categoryForRecipe(recipe) == category &&
                recipe.typeId == widget.typeId,
          )
          .toList();
    }
    return _recipes
        .where((recipe) => _categoryForRecipe(recipe) == category)
        .toList();
  }

  Widget _buildRecipeList(List<Recipe> recipes, String lang) {
    if (recipes.isEmpty) {
      return Center(child: Text(AppStrings.get('noRecipesAvailable', lang)));
    }

    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              SizedBox(height: 12),
              paraType != null &&
                      paraCategory == _categoryForRecipe(recipes.first)
                  ? Text(
                      AppStrings.get('recipes_for_type', lang).replaceFirst(
                        '{type}',
                        SeedsStrings.get(paraType!.name, lang).isNotEmpty? SeedsStrings.get(paraType!.name, lang) : paraType!.name  
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  : SizedBox.shrink(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 72),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    final recipeCategory = _categoryForRecipe(recipe);
                    final categoryIcon = recipeCategory == Category.filling
                        ? Icons.egg_alt
                        : Icons.cookie;
                   // final typeLabel = SeedsStrings.get(_typeNameForRecipe(recipe), lang).isNotEmpty ? SeedsStrings.get(_typeNameForRecipe(recipe), lang) : _typeNameForRecipe(recipe);
                    final inUse = (_usageCounts[recipe.id] ?? 0) > 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RecipeDetailsPage(recipe: recipe),
                              ),
                            );
                            if (result == true) {
                              _refreshRecipes();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor:
                                      recipeCategory == Category.filling
                                      ? Colors.brown.shade50
                                      : Colors.orange.shade50,
                                  child: Icon(
                                    categoryIcon,
                                    color: recipeCategory == Category.filling
                                        ? AppColors.accentRed
                                        : AppColors.accent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        SeedsStrings.get(recipe.name, lang).isNotEmpty ? SeedsStrings.get(recipe.name, lang) : recipe.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      InfoChips(
                                        qty: recipe.quantity,
                                        size: recipe.size,
                                        ratio: Helper.ratioToString(recipe.ratio!),
                                      ),
                                    ],
                                  ),
                                ),
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
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: inUse ? Colors.grey : Colors.red,
                                  ),
                                  onPressed: () => _deleteRecipe(recipe),
                                  tooltip: AppStrings.get(
                                    'delete_recipe',
                                    lang,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody(String lang) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    return Container(
      // color: AppColors.sectionBg,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/bg.png',
          ), // Use NetworkImage('') for URLs
          fit: BoxFit.cover, // Ensures image fills the screen
        ),
      ),
      child: TabBarView(
        children: [
          _buildRecipeList(_recipesByCategory(Category.dough), lang),
          _buildRecipeList(_recipesByCategory(Category.filling), lang),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cookie, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(
            AppStrings.get('dough', lang),
            style: TextStyle(color: AppColors.accent),
          ),
        ],
      ),
    ),
    Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.egg_alt, color: AppColors.accentRed),
          const SizedBox(width: 6),
          Text(
            AppStrings.get('filling', lang),
            style: TextStyle(color: AppColors.accentRed),
          ),
        ],
      ),
    ),
  ],
),
),
        body: _buildBody(lang),

        floatingActionButton: FloatingActionButton.small(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // your custom radius
          ),
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
