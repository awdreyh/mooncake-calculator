import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/model/recipe.dart';
import '../../../data/model/type.dart';
import '../../../data/model/ingredient.dart';
import '../../../provider/recipe.dart';
import '../../../provider/type.dart';
import '../../../provider/ingredient.dart';
import '../../utils/app_strings.dart';
import '../../utils/seeds_strings.dart';
import '../../utils/helper.dart';
import '../../utils/language_provider.dart';
import "../../core/nav_bottom.dart";
import '../task/list.dart';
import '../../core/app_theme.dart';
import '../../widgets/info_chips.dart';


class RecipeDetailsPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  LanguageProvider get languageProvider =>
      Provider.of<LanguageProvider>(context, listen: false);
  String get lang => languageProvider.languageCode;

  late Recipe _recipe;
  List<Ingredient> _ingredients = [];
  RecipeProvider get receipeProvider => context.read<RecipeProvider>();
  TypeProvider get typeProvider => context.read<TypeProvider>();
  IngredientProvider get ingredientProvider =>
      context.read<IngredientProvider>();

  List<Type> _allTypes = [];
  bool _changed = false;
  String _typeName = '';
  int _taskUsageCount = 0;
  bool _isSaving = false;
  double _selectedRating = 0;
  bool _isFavorite = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    _ingredients = _recipe.ingredients;
    _typeName = '';
    _commentController.text = _recipe.comment ?? '';
    _selectedRating = _recipe.rating ?? 0;
    _isFavorite = _recipe.isFavorite ?? false;
    _loadTypes();
    _loadTaskUsageCount();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadTypes() async {
    final types = await typeProvider.loadAllTypes();

    if (_recipe.typeId != null) {
      final type = await typeProvider.loadType(_recipe.typeId!);
      if (!mounted) return;
      setState(() {
        _typeName = type.name;
      });
    }

    if (!mounted) return;
    setState(() {
      _allTypes = types;
    });
  }

  Future<void> _loadTaskUsageCount() async {
    if (!mounted) return;
    final count = await receipeProvider.countTasksUsingRecipe(_recipe.id);
    if (!mounted) return;
    setState(() {
      _taskUsageCount = count;
    });
  }

  void _openRelatedTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskListPage(recipeId: _recipe.id),
      ),
    );
  }

  void _toggleFavorite() {
    if (_isSaving) return;

    final newStatus = !_isFavorite;
    setState(() {
      _isFavorite = newStatus;
    });
    _saveChanges();
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    final updatedRating = _selectedRating;
    final updatedComment = _commentController.text.trim();
    final updatedRecipe = _recipe.copyWith(
      isFavorite: _isFavorite,
      rating: updatedRating > 0 ? updatedRating : null,
      url: _recipe.url,
      comment: updatedComment.isEmpty ? null : updatedComment,
      directions: _recipe.directions,
      updatedAt: _recipe.updatedAt,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await receipeProvider.updateRecipe(updatedRecipe);

      if (!mounted) return;
      setState(() {
        _recipe = updatedRecipe;
        _changed = true;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('changes_saved', lang))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.get('failed_to_update_changes', lang)}: $e',
          ),
        ),
      );
    }
  }

  void _deleteRecipe() async {
    if (_taskUsageCount > 0) {
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
          ).replaceAll('{recipe_name}', SeedsStrings.get(_recipe.name, lang).isNotEmpty ? SeedsStrings.get(_recipe.name, lang) : _recipe.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppStrings.get('delete_recipe', lang),
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await receipeProvider.deleteRecipe(_recipe.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;   

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _changed);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('viewDetails', lang)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _changed),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: _toggleFavorite,
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: _taskUsageCount > 0 ? Colors.grey : Colors.red,
              ),
              onPressed: _deleteRecipe,
            ),
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type and Sub-type Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.brown.shade50,
                            child: Icon(
                              Icons.egg_alt,
                              size: 24,
                              color: AppColors.accentRed,
                            ),
                          ),

                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(SeedsStrings.get(_recipe.name, lang).isNotEmpty ? SeedsStrings.get(_recipe.name, lang) : _recipe.name,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Builder(
                                  builder: (context) {
                                    final recipeType = _allTypes.firstWhere(
                                      (type) => type.id == _recipe.typeId,
                                      orElse: () => Type(
                                        id: _recipe.typeId ?? '',
                                        category: Category.dough,
                                        name: '',
                                      ),
                                    );
                                    final labelKey =
                                        recipeType.category == Category.filling
                                        ? 'filling_type'
                                        : 'dough_type';

                                    return Text(
                                      '${AppStrings.get(labelKey, lang)}:${_typeName.isNotEmpty ? _typeName : SeedsStrings.get(_typeName, lang)}',
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 4),
                                // Description
                                if (_recipe.description != null &&
                                    _recipe.description!.isNotEmpty)
                                  Text(
                                    _recipe.description!,
                                    style: textTheme.bodyMedium,
                                  ),

                                if (_taskUsageCount > 0)
                                  GestureDetector(
                                    onTap: _openRelatedTasks,
                                    child: Text(
                                      AppStrings.get(
                                        'used_in_tasks',
                                        lang,
                                      ).replaceAll(
                                        '{count}',
                                        _taskUsageCount.toString(),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    AppStrings.get(
                                      'used_in_tasks',
                                      lang,
                                    ).replaceAll(
                                      '{count}',
                                      _taskUsageCount.toString(),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                InfoChips(
                                  qty: _recipe.quantity,
                                  size: _recipe.size,
                                  ratio: Helper.ratioToString(_recipe.ratio!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Ingredients
              const SizedBox(height: 16),
              Text(
                AppStrings.get('ingredients', lang),
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_ingredients.isEmpty)
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(AppStrings.get('noIngredients', lang)),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _ingredients.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),

                    itemBuilder: (context, index) {
                      final ingredient = _ingredients[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(SeedsStrings.get(ingredient.name, lang).isNotEmpty ? SeedsStrings.get(ingredient.name, lang) : ingredient.name)),
                            Text(
                              '${ingredient.amount} ${ingredient.unit.toMap()}',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ),
                const SizedBox(height: 16),
              // Rating
              Text(
                        AppStrings.get('rating', lang),
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Row(
                        children: List.generate(5, (index) {
                          final starValue = index + 1;
                          final isSelected = _selectedRating >= starValue;
                          return IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isSelected ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedRating = starValue.toDouble();
                              });
                              _saveChanges();
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedRating > 0
                            ? '$_selectedRating / 5.0'
                            : AppStrings.get('no_rating', lang),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Comment
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get('comment', lang),
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                 TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: AppStrings.get('no_comment', lang),
                           border: const OutlineInputBorder(),
                        ),
                      ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveChanges,
                     
                      label: Text(AppStrings.get('save', lang)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

              // URL
              if (_recipe.url != null && _recipe.url!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('reference_url', lang),
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card( 
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SelectableText(
                          _recipe.url!,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
      ),
    );
  }
}
