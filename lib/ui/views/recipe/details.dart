import 'package:flutter/material.dart';
import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
import 'package:provider/provider.dart';
import '../../../db/recipe.dart';
import '../../../db/type.dart';
import '../../../db/db_helper.dart';
import '../../../ui/utils/helper.dart';

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

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    final types = await _mcService.loadTypes();
    if (!mounted) return;
    setState(() {
      _types = types;
    });
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
              AppStrings.get('delete', lang),
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
            Card(
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

            // Rating
            if (_recipe.rating != null && _recipe.rating! > 0)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Rating: ${_recipe.rating} / 5.0',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Ingredients
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
              Card(
                child: ListView.separated(
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
              ),
            const SizedBox(height: 16),

            // Comment
            if (_recipe.comment != null && _recipe.comment!.isNotEmpty)
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
                      child: Text(_recipe.comment!),
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
