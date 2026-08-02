import 'package:flutter/material.dart';
import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
import 'package:provider/provider.dart';
import '../../../db/recipe.dart';
import '../../../db/type.dart';
import '../../../db/db_helper.dart';
import '../../../ui/utils/helper.dart';
import '../task/list.dart';

class RecipeDetailsPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  late Recipe _recipe;
  final MCService _mcService = MCService();
  List<Type> _types = [];
  bool _changed = false;
  int _taskUsageCount = 0;
  final TextEditingController _commentController = TextEditingController();
  List<Type> _selectedMatchedDoughTypes = [];
  bool _isSaving = false;
  double _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    _commentController.text = _recipe.comment ?? '';
    _selectedRating = _recipe.rating ?? 0;
    _loadTypes();
    _loadTaskUsageCount();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadTypes() async {
    final types = await _mcService.loadTypes();
    if (!mounted) return;
    setState(() {
      _types = types;
      _selectedMatchedDoughTypes = Type.matchedDoughTypesById(
        _recipe.typeId,
        types: _types,
      );
    });
  }

  Future<void> _loadTaskUsageCount() async {
    final count = await _mcService.countTasksUsingRecipe(_recipe.id);
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

  void _toggleFavorite() async {
    final newStatus = !(_recipe.isFavorite ?? false);
    await _mcService.updateRecipeFavorite(_recipe.id, newStatus);
    _changed = true;
    setState(() {
      _recipe = Recipe(
        id: _recipe.id,
        name: _recipe.name,
        typeId: _recipe.typeId,
        quantity: _recipe.quantity,
        size: _recipe.size,
        ratio: _recipe.ratio,
        description: _recipe.description,
        ingredients: _recipe.ingredients,
        isFavorite: newStatus,
        rating: _recipe.rating,
        url: _recipe.url,
        comment: _recipe.comment,
      );
    });
  }

  void _toggleMatchedDoughType(Type type) {
    setState(() {
      if (_selectedMatchedDoughTypes.any((item) => item.id == type.id)) {
        _selectedMatchedDoughTypes.removeWhere((item) => item.id == type.id);
      } else {
        _selectedMatchedDoughTypes.add(type);
      }
    });
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    final updatedRating = _selectedRating;
    final updatedComment = _commentController.text.trim();
    final updatedRecipe = Recipe(
      id: _recipe.id,
      name: _recipe.name,
      typeId: _recipe.typeId,
      quantity: _recipe.quantity,
      size: _recipe.size,
      ratio: _recipe.ratio,
      description: _recipe.description,
      ingredients: _recipe.ingredients,
      isFavorite: _recipe.isFavorite,
      rating: updatedRating != null && updatedRating > 0 ? updatedRating : null,
      url: _recipe.url,
      comment: updatedComment.isEmpty ? null : updatedComment,
      directions: _recipe.directions,
      createdAt: _recipe.createdAt,
      updatedAt: _recipe.updatedAt,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await _mcService.updateRecipeDetails(updatedRecipe);

      final currentRecipeType = _types.firstWhere(
        (type) => type.id == _recipe.typeId,
        orElse: () => Type(
          id: _recipe.typeId ?? '',
          category: Category.dough,
          name: '',
        ),
      );

      if (currentRecipeType.category == Category.filling) {
        await _mcService.updateTypeMatchedDoughTypes(
          _recipe.typeId ?? '',
          _selectedMatchedDoughTypes.map((type) => type.id).toList(),
        );
      }

      if (!mounted) return;
      setState(() {
        _recipe = updatedRecipe;
        _changed = true;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes: $e')),
      );
    }
  }

  void _deleteRecipe() async {
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
          ).replaceAll('{recipe_name}', _recipe.name),
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
      await _mcService.deleteRecipe(_recipe.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    final ratioString = Helper.ratioToString(_recipe.ratio ?? 0.0);
    final matchedDoughTypes = _selectedMatchedDoughTypes;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('viewDetails', lang)),
        actions: [
          IconButton(
            icon: Icon(
              _recipe.isFavorite ?? false
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteRecipe,
          ),
          if (!_isSaving)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.green),
              onPressed: _saveChanges,
            )
          else
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.grain),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _recipe.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Builder(
                                builder: (context) {
                                  final recipeType = _types.firstWhere(
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

                                  final typeName = Type.nameById(
                                    _recipe.typeId,
                                    types: _types,
                                  );
                                  return Text(
                                    '${AppStrings.get(labelKey, lang)}: ${typeName.isEmpty ? AppStrings.get('unknown', lang) : typeName}',
                                    style: const TextStyle(
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
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                             
                              if (matchedDoughTypes.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${AppStrings.get('matched_dough_types', lang)}: ${matchedDoughTypes.map((type) => type.name).join(', ')}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              if (matchedDoughTypes.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _types
                                      .where((type) => type.category == Category.dough)
                                      .map((type) {
                                        final selected = _selectedMatchedDoughTypes.any(
                                          (item) => item.id == type.id,
                                        );
                                        return FilterChip(
                                          label: Text(type.name),
                                          selected: selected,
                                          onSelected: (_) => _toggleMatchedDoughType(type),
                                        );
                                      })
                                      .toList(),
                                ),
                              if (_taskUsageCount > 0)
                                GestureDetector(
                                  onTap: _openRelatedTasks,
                                  child: Text(
                                    AppStrings.get('used_in_tasks', lang).replaceAll(
                                      '{count}',
                                      _taskUsageCount.toString(),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  AppStrings.get('used_in_tasks', lang).replaceAll(
                                    '{count}',
                                    _taskUsageCount.toString(),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.blueGrey,
                                  ),
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
            const SizedBox(height: 16),
            Text(
              AppStrings.get('moonCakeWeight', lang),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppStrings.get('size', lang)}: ${_recipe.size}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppStrings.get('quantity', lang)}: ${_recipe.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        '${AppStrings.get('ratio', lang)}: $ratioString',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

           
            // Ingredients
              const SizedBox(height: 16),
            Text(
              AppStrings.get('ingredients', lang),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_recipe.ingredients.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(AppStrings.get('noIngredients', lang)),
                ),
              )
            else
             ListView.separated(
                  shrinkWrap: true,                  
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recipe.ingredients.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                   
                  itemBuilder: (context, index) {
                    final ingredient = _recipe.ingredients[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                        
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(ingredient.name)),
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
           
         // Rating
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('rating', lang),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: AppStrings.get('no_comment', lang),
                        border: InputBorder.none,
                      ),
                    ),
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
                  const Text(
                    'Reference URL',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }
}
