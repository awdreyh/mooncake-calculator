import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

import '../../../data/database/db_helper.dart';
import '../../../data/model/recipe.dart';
import '../../../data/model/type.dart';
import '../../../data/model/ingredient.dart';


import '../../../data/repository/recipe.dart';
import '../../../provider/recipe.dart';
import '../../../provider/type.dart';

import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
import '../../widgets/image_button.dart';
import '../../widgets/selection_buttons.dart';
import '../../core/nav_bottom.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key, this.initialType});

  final Type? initialType;

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _IngredientInput {
  final TextEditingController nameController;
  final TextEditingController amountController;
  UnitType unit = UnitType.g;

  _IngredientInput({String name = '', String amount = ''})
    : nameController = TextEditingController(text: name),
      amountController = TextEditingController(text: amount);

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class _CategoryOption {
  final Category category;
  final String label;
  const _CategoryOption({required this.category, required this.label});
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final provider = RecipeProvider(RecipeRepository(MCDatabase.instance));

  Category _recipeCategory = Category.dough;
  Type? _selectedType;
  List<Type> _selectedMatchedDoughTypes = [];
  List<Type> _allTypes = [];
  final bool _isFavorite = false;
  final double _rating = 0.0;
  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(
    text: '8',
  );
  final TextEditingController _sizeController = TextEditingController(
    text: '100',
  );
  final TextEditingController _ratioController = TextEditingController(
    text: '4:6',
  );
  final List<_IngredientInput> _ingredients = List.generate(
    3,
    (_) => _IngredientInput(),
  );

  Recipe? get recipe => null;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _sizeController.dispose();
    _ratioController.dispose();
    for (final ingredient in _ingredients) {
      ingredient.dispose();
    }
    super.dispose();
  }

  Future<void> _loadTypes() async {
    final typeProvider = context.read<TypeProvider>();
    final types = await typeProvider.loadAllTypes();
    if (!mounted) return;
    setState(() {
      _allTypes = types;
      if (_selectedType == null ||
          !_allTypes.any((type) => type.id == _selectedType!.id)) {
        _selectedType = _getDefaultType(_recipeCategory);
      }
      final initial = widget.initialType;
      if (initial != null &&
          _allTypes.any((type) => type.id == initial.id)) {
        _recipeCategory = initial.category;
        _selectedType = _allTypes.firstWhere(
          (type) => type.id == initial.id,
        );
      }
    });
  }

  Type _getDefaultType(Category category) {
    final matchingTypes = _allTypes.where(
      (type) => type.category == category,
    );
    return matchingTypes.isNotEmpty ? matchingTypes.first : Type(id: '', category: category, name: '');
  }

  List<Type> get _doughTypes =>
      _allTypes.where((type) => type.category == Category.dough).toList();

  List<Type> get _fillingTypes =>
      _allTypes.where((type) => type.category == Category.filling).toList();

  List<_CategoryOption> _categoryOptions(String lang) => Category.values
      .map(
        (category) => _CategoryOption(
          category: category,
          label: category == Category.dough
              ? AppStrings.get('dough', lang)
              : AppStrings.get('filling', lang),
        ),
      )
      .toList();

  void _selectCategory(Category category) {
    setState(() {
      _recipeCategory = category;
      _selectedType = _getDefaultType(category);
      if (category == Category.dough) {
        _selectedMatchedDoughTypes = [];
      }
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

  void _setQuantity(int value) {
    _quantityController.text = value.toString();
  }

  void _setSize(int value) {
    _sizeController.text = value.toString();
  }

  void _setRatio(String value) {
    _ratioController.text = value;
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
            unit: input.unit,
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

    setState(() {
      _isSaving = true;
    });

    try {
      final name = _nameController.text.trim();
      final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
      final size = int.tryParse(_sizeController.text.trim()) ?? 1;
      final ratio = double.tryParse(_ratioController.text.trim()) ?? 0.4;

      final newRecipe = Recipe(
        id: const Uuid().v4(),
        name: name,
        typeId: _selectedType?.id,
        quantity: quantity,
        size: size,
        ratio: ratio,
        ingredients: ingredients,
        description: '',
        isFavorite: _isFavorite,
        rating: _rating > 0 ? _rating : null,
      );

    final provider = RecipeProvider(RecipeRepository(MCDatabase.instance));
    await provider.insertRecipe(newRecipe);

      if (!mounted) {
        return;
      }
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      final lang = languageProvider.languageCode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('recipeSaveSuccessfulMsg', lang)),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      final lang = languageProvider.languageCode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.get('failedToSaveRecipe', lang)} $error'),
        ),
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
    bool isDoughtTypeSelected = _recipeCategory == Category.dough;
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('addRecipe', lang))),
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
                    return AppStrings.get('validRecipeNameMsg', lang);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.get('type', lang),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: _categoryOptions(lang).map((option) {
                  final isSelected = _recipeCategory == option.category;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300],
                        ),
                        onPressed: () => _selectCategory(option.category),
                        child: Text(
                          option.label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              ...[
                StyleTypeSelectionSection(
                  title: isDoughtTypeSelected
                      ? AppStrings.get('type', lang)
                      : AppStrings.get('fillingType', lang),
                  types: isDoughtTypeSelected ? _doughTypes : _fillingTypes,
                  selectedType: _selectedType,
                  onTypeSelected: (type) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  showMatchedDoughTypes: isDoughtTypeSelected ? false : true,
                  matchedDoughLabel: isDoughtTypeSelected
                      ? ''
                      : AppStrings.get('matched_dough_types', lang),
                  doughTypes: _doughTypes,
                  selectedMatchedDoughTypes: _selectedMatchedDoughTypes,
                  onMatchedDoughTypeToggled: _toggleMatchedDoughType,
                ),
              ],
              SizedBox(height: 16),

              Text(AppStrings.get('qty',lang), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                validator: (value) => value != null && value.isNotEmpty
                    ? null
                    : AppStrings.get('validQuantityMsg', lang),
              ),
              const SizedBox(height: 8),
              OptionButtons(
                values: [4, 8, 10, 16],
                onSelected: _setQuantity,
              ),
              const SizedBox(height: 20),
              Text(AppStrings.get('size',lang), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _sizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                validator: (value) => value != null && value.isNotEmpty
                    ? null
                    : AppStrings.get('validSizeMsg', lang),
              ),
              const SizedBox(height: 8),
              OptionButtons(
                values: [50, 75, 100],
                onSelected: _setSize,
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.get('ratio', lang),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ratioController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                validator: (value) => value != null && value.isNotEmpty
                    ? null
                    : AppStrings.get('validRatioMsg', lang),
              ),
              const SizedBox(height: 8),
              RatioButtons(
                onSelected: _setRatio,
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.get('ingredients', lang),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._ingredients.asMap().entries.map((entry) {
                final index = entry.key;
                final ingredient = entry.value;
                UnitType? selectedUnitType = UnitType.g;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: ingredient.nameController,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            labelText:
                                '${AppStrings.get('ingredient', lang)} ${index + 1}',
                            labelStyle: const TextStyle(fontSize: 11),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppStrings.get(
                                'validIngredientNameMsg',
                                lang,
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: ingredient.amountController,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            labelText: AppStrings.get('amount', lang),
                            labelStyle: const TextStyle(fontSize: 11),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppStrings.get(
                                'validIngredientAmountMsg',
                                lang,
                              );
                            }
                            if (double.tryParse(value.trim()) == null) {
                              return AppStrings.get('invalidNumber', lang);
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<UnitType>(
                          initialValue: selectedUnitType,
                          icon: const SizedBox.shrink(),
                          iconSize: 0,
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(221, 180, 18, 18),
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 7,
                            ),
                          ),
                          items: UnitType.values
                              .map(
                                (unit) => DropdownMenuItem<UnitType>(
                                  value: unit,
                                  child: Text(
                                    unit.name,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              ingredient.unit = value ?? UnitType.g;
                              selectedUnitType = value;
                            });
                          },
                        ),
                      ),

                      if (_ingredients.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removeIngredient(index),
                          iconSize: 20,
                        ),
                    ],
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(AppStrings.get('addIngredient', lang)),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(AppStrings.get('cancel', lang)),
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
                          : Text(AppStrings.get('save', lang)),
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
