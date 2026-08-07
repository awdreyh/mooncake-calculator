import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

import '../../../db/db_helper.dart';
import '../../../db/model/recipe.dart';
import '../../../db/model/type.dart';

import '../../../db/repository/task.dart';
import '../../../db/repository/type.dart';
import '../../../db/repository/recipe.dart';
import '../../../provider/recipe.dart';
import '../../../provider/type.dart';
import '../../../provider/task.dart';

import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
import '../../utils/helper.dart';
import 'details.dart';
import '../../widgets/image_button.dart';
import '../../widgets/selection_buttons.dart';
import '../../widgets/text.dart';


class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}


class _AddTaskPageState extends State<AddTaskPage> {
  Type? _selectedDoughType;
  Recipe? _selectedDoughRecipe;
  Type? _selectedFillingType;
  Recipe? _selectedFillingRecipe;

  final TextEditingController _quantityController = TextEditingController(text: '8');
  final TextEditingController _sizeController = TextEditingController(text: '100');
  final TextEditingController _ratioController = TextEditingController(text: '4:6');

  bool _isCalculating = false;
  List<Recipe> _allRecipes = [];
  List<Type> _allTypes = [];
  String? _doughTypeError;
  String? _doughRecipeError;
  String? _fillingTypeError;
  String? _fillingRecipeError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _applyDefaultSelections(List<Type> types, List<Recipe> recipes) {
    if (_selectedDoughType == null && types.isNotEmpty) {
      final doughType = types.where((type) => type.category == Category.dough).firstOrNull;
      if (doughType != null) {
        _selectedDoughType = doughType;
      }
    }

    if (_selectedDoughType != null) {
      final doughRecipes = recipes.where((recipe) => recipe.typeId == _selectedDoughType!.id).toList();
      if (_selectedDoughRecipe == null && doughRecipes.isNotEmpty) {
        _selectedDoughRecipe = doughRecipes.first;
      }
    }

    if (_selectedFillingType == null && types.isNotEmpty) {
      final fillingType = types.where((type) => type.category == Category.filling).firstOrNull;
      if (fillingType != null) {
        _selectedFillingType = fillingType;
      }
    }

    if (_selectedFillingType != null) {
      final fillingRecipes = recipes.where((recipe) => recipe.typeId == _selectedFillingType!.id).toList();
      if (_selectedFillingRecipe == null && fillingRecipes.isNotEmpty) {
        _selectedFillingRecipe = fillingRecipes.first;
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _sizeController.dispose();
    _ratioController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
     final typeProvider = TypeProvider(TypeRepository(MCDatabase.instance));
     final recipeProvider = RecipeProvider(RecipeRepository(MCDatabase.instance));

    final types = await typeProvider.loadAllTypes();
    final recipes = await recipeProvider.loadAllRecipes();
   
    if (!mounted) return;
    setState(() {
      _allRecipes = recipes;
      _allTypes = types;
      _applyDefaultSelections(types, recipes);
    });
  }

  List<Type> get _doughTypes => _allTypes.where((type) => type.category == Category.dough).toList();

  List<Type> get _fillingTypes {
    if (_selectedDoughType == null) return [];
    return _allTypes.where((type) {
      if (type.category != Category.filling) return false;
      return type.matchedDoughTypeIds?.any((matched) => matched == _selectedDoughType!.id) ?? false;
    }).toList();
  }

  List<Recipe> get _doughRecipes {
    if (_selectedDoughType == null) return [];
    return _allRecipes.where((recipe) => recipe.typeId == _selectedDoughType!.id).toList();
  }

  List<Recipe> get _fillingRecipes {
    if (_selectedFillingType == null) return [];
    return _allRecipes.where((recipe) => recipe.typeId == _selectedFillingType!.id).toList();
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

  Map<String, String?> _validateSelections(String lang) {
    return {
      'doughType': _selectedDoughType == null
          ? AppStrings.get('validRecipeTypeMsg', lang) 
          : null,
      'doughRecipe': _selectedDoughRecipe == null
          ? AppStrings.get('validDoughRecipeMsg', lang) 
          : null,
      'fillingType': _selectedFillingType == null
          ? AppStrings.get('validFillingTypeMsg', lang)
          : null,
      'fillingRecipe': _selectedFillingRecipe == null
          ? AppStrings.get('validFillingRecipeMsg', lang)
          : null,
    };
  }

  Future<void> _calculateTask() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final lang = languageProvider.languageCode;
    final validationErrors = _validateSelections(lang);

    setState(() {
      _doughTypeError = validationErrors['doughType'];
      _doughRecipeError = validationErrors['doughRecipe'];
      _fillingTypeError = validationErrors['fillingType'];
      _fillingRecipeError = validationErrors['fillingRecipe'];
    });

    if (validationErrors.values.any((message) => message != null && message.isNotEmpty)) {
      return;
    }

    setState(() => _isCalculating = true);

    try {
      final ratio = Helper.stringToRatio(_ratioController.text.trim());
      final newTask = TaskRepository.createFromRecipes(
        id: const Uuid().v4(),
        doughRecipe: _selectedDoughRecipe!,
        fillingRecipe: _selectedFillingRecipe!,
        quantity: int.parse(_quantityController.text.trim()),
        size: int.parse(_sizeController.text.trim()),
        ratio: ratio,
      );
    final provider = TaskProvider(TaskRepository(MCDatabase.instance));
    await provider.insertTask(newTask);

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TaskDetailsPage(taskId: newTask.id),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCalculating = false);
      }
    }
  }

  Widget _buildTypeSelection({
    required String label,
    required List<Type> types,
    required Type? selectedType,
    required ValueChanged<Type> onSelected,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [ 
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (errorText != null && errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              errorText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        Row(
          spacing: 8,      
          children: types.map((type) {            
            final selected = selectedType?.id == type.id;
            return Expanded(              
              child: StyleImageButton(
                title: type.name,
                type: type,
                selected: selected,
                onTap: () => onSelected(type),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecipeSelection({    

    required String label,
    required List<Recipe> recipes,
    required Recipe? selectedRecipe,
    required ValueChanged<Recipe?> onSelected,
    String? errorText,

  }) {    
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    return Column(      
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabelWithSpacing(label: label),
        if (errorText != null && errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              errorText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        if (recipes.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child:  Text(AppStrings.get('msgNoRecipe', lang), style: const TextStyle(color: Colors.grey)),
          )
        else
          Row(
            spacing: 8,          
            children: recipes.map((recipe) {
              final selected = selectedRecipe?.id == recipe.id;
              return Expanded(              
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: selected ? Theme.of(context).colorScheme.primaryContainer : null,
                    side: BorderSide(
                      color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                    ),
                  ),
                  onPressed: () => onSelected(recipe),
                  child: Text(recipe.name),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildOptionButtons({
    required List<int> values,
    required ValueChanged<int> onSelected,
  }) { 
    return OptionButtons(values: values, onSelected: onSelected);
  }

  Widget _buildRatioButtons() {
    return RatioButtons(onSelected: _setRatio);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;

    return Center(
      child: SingleChildScrollView(
       // padding: const EdgeInsets.all(16),
        child: Form(
        
          child: Column(            
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [          
              _buildTypeSelection(               
                label: AppStrings.get('lblWhichType', lang),
                types: _doughTypes,
                selectedType: _selectedDoughType,
                errorText: _doughTypeError,
                onSelected: (type) {
                  setState(() {
                    _doughTypeError = null;
                    _selectedDoughType = type;
                    _selectedDoughRecipe = null;
                    _selectedFillingType = null;
                    _selectedFillingRecipe = null;
                  });
                },
              ),
              const SizedBox(height: 16),
                         
              _buildRecipeSelection(
                label: AppStrings.get('lblwhichDoughRecipe', lang),
                recipes: _doughRecipes,
                selectedRecipe: _selectedDoughRecipe,
                errorText: _doughRecipeError,
                onSelected: (recipe) {
                  setState(() {
                    _doughRecipeError = null;
                    _selectedDoughRecipe = recipe;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildTypeSelection(
                label: AppStrings.get('lblWhichFillingType', lang),
                types: _fillingTypes,
                selectedType: _selectedFillingType,
                errorText: _fillingTypeError,
                onSelected: (type) {
                  setState(() {
                    _fillingTypeError = null;
                    _selectedFillingType = type;
                    _selectedFillingRecipe = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildRecipeSelection(
                label: AppStrings.get('lblwhichFillingRecipe',lang),
                recipes: _fillingRecipes,
                selectedRecipe: _selectedFillingRecipe,
                errorText: _fillingRecipeError,
                onSelected: (recipe) {
                  setState(() {
                    _fillingRecipeError = null;
                    _selectedFillingRecipe = recipe;
                  });
                },
              ),
              const SizedBox(height: 24),
              LabelWithSpacing(label: AppStrings.get('quantity', lang)),
              _buildOptionButtons(values: [4, 8, 10, 16], onSelected: _setQuantity),
              const SizedBox(height: 20),
              LabelWithSpacing(label: AppStrings.get('size', lang)),
              _buildOptionButtons(values: [50, 75, 100], onSelected: _setSize),
              const SizedBox(height: 20),
             LabelWithSpacing(label: AppStrings.get('ratio', lang)),
              _buildRatioButtons(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isCalculating ? null : _calculateTask,
                  icon: _isCalculating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.calculate),
                  label: Text(_isCalculating ? AppStrings.get('calculating',lang) : AppStrings.get('calculateSave',lang)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Future<String> addTask({
//   required Recipe doughRecipe,
//   required Recipe fillingRecipe,
//   required int quantity,
//   required int size,
//   required double ratio,
//   String? id,
//   String? comment,
//   double? rating,
//   bool? isCompleted,
//   DateTime? createdAt,
//   DateTime? updatedAt,
// }) async {
//   final taskId = id ?? const Uuid().v4();
//   final task = TaskRepository.createFromRecipes(
//     id: taskId,
//     doughRecipe: doughRecipe,
//     fillingRecipe: fillingRecipe,
//     quantity: quantity,
//     size: size,
//     ratio: ratio,
//     comment: comment,
//     rating: rating,
//     isCompleted: isCompleted,
//     createdAt: createdAt,
//     updatedAt: updatedAt,
//   );

//   final mcService = MCService();
//   return mcService.saveTask(task);
// }
