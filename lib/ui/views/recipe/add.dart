import 'package:flutter/material.dart';
import 'package:moon_cake_app2/ui/utils/app_strings.dart';
import 'package:uuid/uuid.dart';
import 'package:moon_cake_app2/db/ingredient.dart';
import '../../core/nav_bottom.dart';
import '../../utils/language_provider.dart';
import 'package:provider/provider.dart';
import '../../../db/recipe.dart';
import '../../../db/db_helper.dart';
import '../../../db/type.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _IngredientInput {
  final TextEditingController nameController;
  final TextEditingController amountController;
  UnitType unit;

  _IngredientInput({
    String name = '',
    String amount = '',
    UnitType unit = UnitType.g,
  }) : nameController = TextEditingController(text: name),
       amountController = TextEditingController(text: amount),
       unit = unit;

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
  final MCService _mcService = MCService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _ratioController = TextEditingController();
  final List<_IngredientInput> _ingredients = List.generate(
    3,
    (_) => _IngredientInput(),
  );
  Category _recipeCategory = Category.dough;
  Type? _selectedType;
  List<Type> _selectedMatchedDoughTypes = [];
  bool _isFavorite = false;
  double _rating = 0.0;
  bool _isSaving = false;

  Recipe? get recipe => null;

  @override
  void initState() {
    super.initState();
    _selectedType = _getDefaultType(Category.dough);
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

  Type _getDefaultType(Category category) {
    return defaultTypes.firstWhere(
      (type) => type.category == category,
      orElse: () => defaultTypes.first,
    );
  }

  List<Type> get _doughTypes =>
      defaultTypes.where((type) => type.category == Category.dough).toList();

  List<Type> get _fillingTypes =>
      defaultTypes.where((type) => type.category == Category.filling).toList();

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

  Widget _buildStyleImageButton(String title, Type type) {
    final selected = _selectedType?.id == type.id;
    final assetName = (type.imageName ?? 'cantoneseStyle').trim();
    final imageAsset = 'assets/${assetName}${selected ? '2' : ''}.jpg';

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          setState(() {
            _selectedType = type;
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
              if (_recipeCategory == Category.dough) ...[
                Text(
                  AppStrings.get('type', lang),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _doughTypes.map((type) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildStyleImageButton(type.name, type),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (_recipeCategory == Category.filling) ...[
                Text(
                  AppStrings.get('fillingType', lang),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Type>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('fillingType', lang),
                    border: const OutlineInputBorder(),
                  ),
                  items: _fillingTypes
                      .map(
                        (type) => DropdownMenuItem<Type>(
                          value: type,
                          child: Text(type.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                      _selectedMatchedDoughTypes = [];
                    });
                  },
                  validator: (value) {
                    if (_recipeCategory == Category.filling && value == null) {
                      return AppStrings.get('validFillingTypeMsg', lang);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedType != null) ...[
                  Text(
                    AppStrings.get('matched_dough_types', lang),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _doughTypes.map((type) {
                      final selected = _selectedMatchedDoughTypes.any(
                        (item) => item.id == type.id,
                      );
                      return FilterChip(
                        label: Text(type.name),
                        selected: selected,
                        onSelected: (_) => _toggleMatchedDoughType(type),
                      );
                    }).toList(),
                  ),
                ],
              ],
              const SizedBox(height: 16),

              Text(
                AppStrings.get('ingredients', lang),
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
                            labelText:
                                '${AppStrings.get('ingredient', lang)} ${index + 1}',
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
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 90,
                        child: DropdownButtonFormField<UnitType>(
                          initialValue: ingredient.unit,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          items: UnitType.values
                              .map(
                                (unit) => DropdownMenuItem<UnitType>(
                                  value: unit,
                                  child: Text(unit.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              ingredient.unit = value ?? UnitType.g;
                            });
                          },
                        ),
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
                  label: Text(AppStrings.get('addIngredient', lang)),
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
