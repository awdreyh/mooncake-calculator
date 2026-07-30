import 'package:flutter/material.dart';
import 'package:moon_cake_app2/ui/utils/app_strings.dart';
import 'package:uuid/uuid.dart';
import 'package:moon_cake_app2/db/ingredient.dart';
import '../../core/nav_bottom.dart';
import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
import 'package:provider/provider.dart';
import '../../../db/recipe.dart';
import '../../../db/db_helper.dart';


class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _IngredientInput {
  final TextEditingController nameController;
  final TextEditingController amountController;

  _IngredientInput({String name = '', String amount = ''})
    : nameController = TextEditingController(text: name),
      amountController = TextEditingController(text: amount);

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final MCService _mcService = MCService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nameCategory = TextEditingController();
  final TextEditingController _fillingTypeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _ratioController = TextEditingController();
  final List<_IngredientInput> _ingredients = List.generate(
    3,
    (_) => _IngredientInput(),
  );
  String _recipeType = 'Dough';
  String _doughStyle = 'Cantonese style';
  bool _isFavorite = false;
  double _rating = 0.0;
  bool _isSaving = false;
  
  Recipe? get recipe => null;

  @override
  void dispose() {
    _nameController.dispose();
    _fillingTypeController.dispose();
    _quantityController.dispose();
    _sizeController.dispose();
    _ratioController.dispose();
    for (final ingredient in _ingredients) {
      ingredient.dispose();
    }
    super.dispose();
  }

  Widget _buildDoughStyleImageButton(

    String title,
    String styleValue,
    String assetName,
  ) {
    final selected = _doughStyle == styleValue;
    final imageAsset = 'assets/${assetName}${selected ? '2' : ''}.jpg';

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          setState(() {
            _doughStyle = styleValue;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Image.asset(imageAsset, height: 100, fit: BoxFit.cover),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14),
                  ),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(_IngredientInput());
    });
  }

  void _removeIngredient(int index) {
    if (_ingredients.length <= 1) {
      return;
    }
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final uuid = const Uuid();
    final ingredients = _ingredients
        .where((input) => input.nameController.text.trim().isNotEmpty)
        .map(
          (input) => Ingredient(
            id: uuid.v4(),
            name: input.nameController.text.trim(),
            amount: double.parse(input.amountController.text.trim()),
            unit: UnitType.g,
            category: IngredientCategory.recipe,
          ),
        )
        .toList();

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one ingredient.')),
      );
      return;
    }

    final recipe = Recipe(
      id: uuid.v4(),
      name: _nameController.text.trim(),
      typeId: _nameCategory.text,
      quantity: _quantityController.text.trim().isEmpty
          ? 8
          : int.parse(_quantityController.text.trim()),
      size: _sizeController.text.trim().isEmpty
          ? 100
          : int.parse(_sizeController.text.trim()),
      ratio: _ratioController.text.trim().isEmpty
          ? 0.4
          : double.parse(_ratioController.text.trim()),

      description: 'Custom recipe for ${_nameController.text.trim()}',
      ingredients: ingredients,
      isFavorite: _isFavorite,
      rating: _rating,
    );

    setState(() {
      _isSaving = true;
    });

    try {
       
      final confirmMessage = await _mcService.saveRecipe(recipe);
      if (!mounted) {
        return;
      }
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final lang = languageProvider.languageCode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('recipeSaveSuccessfulMsg', lang)),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final lang = languageProvider.languageCode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('failedToSaveRecipe', lang) + ' $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
     final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    return Scaffold(
      appBar: AppBar(title:  Text(AppStrings.get('addRecipe', lang))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('name', lang),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a recipe name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
               Text(AppStrings.get('type', lang) , style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _recipeType == 'Dough'
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                      ),
                      onPressed: () {
                        setState(() {
                          _recipeType = 'Dough';
                        });
                      },
                      child: Text(
                        'Dough',
                        style: TextStyle(
                          color: _recipeType == 'Dough'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _recipeType == 'Filling'
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                      ),
                      onPressed: () {
                        setState(() {
                          _recipeType = 'Filling';
                        });
                      },
                      child: Text(
                        'Filling',
                        style: TextStyle(
                          color: _recipeType == 'Filling'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_recipeType == 'Dough') ...[
                const Text(
                  'Style',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildDoughStyleImageButton(
                      'Cantonese style',
                      'Cantonese style',
                      'cantoneseStyle',
                    ),
                    const SizedBox(width: 12),
                    _buildDoughStyleImageButton(
                      'Snow skin',
                      'Snow skin',
                      'snowSkin',
                    ),
                  ],
                ),
              ],
              if (_recipeType == 'Filling') ...[
                const Text(
                  'Filling type',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fillingTypeController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('fillingType', lang),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_recipeType == 'Filling' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please enter a filling type.';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),           
              
             
              const Text(
                'Ingredients',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._ingredients.asMap().entries.map((entry) {
                final index = entry.key;
                final ingredient = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: ingredient.nameController,
                          decoration: InputDecoration(
                            labelText: '${AppStrings.get('ingredient', lang)} ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter ingredient name.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: ingredient.amountController,
                          decoration: InputDecoration(
                            labelText: AppStrings.get('amount', lang),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter amount.';
                            }
                            if (double.tryParse(value.trim()) == null) {
                              return 'Invalid number.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('g'),
                      ),
                      const SizedBox(width: 8),
                      if (_ingredients.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removeIngredient(index),
                        ),
                    ],
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add),
                  label: const Text('Add ingredient'),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveRecipe,
                      child: _isSaving
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    );
  }
}
