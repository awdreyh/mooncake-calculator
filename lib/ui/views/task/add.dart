import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../../data/model/recipe.dart';
import '../../../data/model/type.dart';
import '../../../data/repository/task.dart';
import '../../../provider/recipe.dart';
import '../../../provider/type.dart';
import '../../../provider/task.dart';
import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
import '../../utils/helper.dart';
import '../recipe/add.dart';
import 'details.dart';
import '../../widgets/image_button.dart';
import '../../widgets/selection_buttons.dart';
import '../../widgets/text.dart';
import '../../core/app_theme.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> with WidgetsBindingObserver {
  LanguageProvider get languageProvider =>
      Provider.of<LanguageProvider>(context, listen: false);
  String get lang => languageProvider.languageCode;
  TextTheme get text => Theme.of(context).textTheme;
  bool _isSaving = false;
  Type? _selectedDoughType;
  Recipe? _selectedDoughRecipe;
  Type? _selectedFillingType;
  Recipe? _selectedFillingRecipe;
  int? _selectedQuantity;
  int? _selectedSize; 
  double? _selectedRatio;

  final TextEditingController _quantityController = TextEditingController(
    text: '8',
  );
  final TextEditingController _sizeController = TextEditingController(
    text: '100',
  );
  final TextEditingController _ratioController = TextEditingController(
    text: '4:6',
  );

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
    WidgetsBinding.instance.addObserver(this);
    _selectedQuantity = int.tryParse(_quantityController.text);
    _selectedSize = int.tryParse(_sizeController.text);
    _selectedRatio = Helper.stringToRatio(_ratioController.text);
    _loadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // no-op; route-resume is handled by didPopNext via RouteAware
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload whenever this route becomes the top route again (e.g. after Navigator.pop from recipe/type pages)
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent && _allTypes.isNotEmpty) {
      _loadData();
    }
  }

  void _applyDefaultSelections(List<Type> types, List<Recipe> recipes) {
    if (_selectedDoughType == null && types.isNotEmpty) {
      final doughType = types
          .where((type) => type.category == Category.dough)
          .firstOrNull;
      if (doughType != null) {
        _selectedDoughType = doughType;
      }
    }

    if (_selectedDoughType != null) {
      final doughRecipes = recipes
          .where((recipe) => recipe.typeId == _selectedDoughType!.id)
          .toList();
      if (_selectedDoughRecipe == null && doughRecipes.isNotEmpty) {
        _selectedDoughRecipe = doughRecipes.first;
      }
    }

    if (_selectedFillingType == null && types.isNotEmpty) {
      final fillingType = types
          .where((type) => type.category == Category.filling)
          .firstOrNull;
      if (fillingType != null) {
        _selectedFillingType = fillingType;
      }
    }

    if (_selectedFillingType != null) {
      final fillingRecipes = recipes
          .where((recipe) => recipe.typeId == _selectedFillingType!.id)
          .toList();
      if (_selectedFillingRecipe == null && fillingRecipes.isNotEmpty) {
        _selectedFillingRecipe = fillingRecipes.first;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _quantityController.dispose();
    _sizeController.dispose();
    _ratioController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final typeProvider = context.read<TypeProvider>();
    final recipeProvider = context.read<RecipeProvider>();

    final types = await typeProvider.loadAllTypes();
    final recipes = await recipeProvider.loadAllRecipes();

    if (!mounted) return;
    setState(() {
      _allRecipes = recipes;
      _allTypes = types;
      _applyDefaultSelections(types, recipes);
    });
  }

  List<Type> get _doughTypes =>
      _allTypes.where((type) => type.category == Category.dough).toList();

  List<Type> get _fillingTypes {
    if (_selectedDoughType == null) {
      return _allTypes
          .where((type) => type.category == Category.filling)
          .toList();
    }
    return _allTypes.where((type) {
      if (type.category != Category.filling) return false;
      return type.matchedDoughTypeIds?.any(
            (matched) => matched == _selectedDoughType!.id,
          ) ??
          type.category ==
              Category
                  .filling; // If matchedDoughTypeIds is null, consider it as a general filling type
    }).toList();
  }

  List<Recipe> get _doughRecipes {
    if (_selectedDoughType == null) return [];
    return _allRecipes
        .where((recipe) => recipe.typeId == _selectedDoughType!.id)
        .toList();
  }

  List<Recipe> get _fillingRecipes {
    if (_selectedFillingType == null) return [];
    return _allRecipes
        .where((recipe) => recipe.typeId == _selectedFillingType!.id)
        .toList();
  }

  void _setQuantity(int value) {
    setState(() {
      _selectedQuantity = value;
      _quantityController.text = value.toString();
    });
  }

  void _setSize(int value) {
    setState(() {
      _selectedSize = value;
      _sizeController.text = value.toString();
    });
  }

  void _setRatio(String value) {
    setState(() {
      _selectedRatio = Helper.stringToRatio(value);
      _ratioController.text = value;
    });
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
    final validationErrors = _validateSelections(lang);

    setState(() {
      _doughTypeError = validationErrors['doughType'];
      _doughRecipeError = validationErrors['doughRecipe'];
      _fillingTypeError = validationErrors['fillingType'];
      _fillingRecipeError = validationErrors['fillingRecipe'];
    });

    if (validationErrors.values.any(
      (message) => message != null && message.isNotEmpty,
    )) {
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
      final provider = context.read<TaskProvider>();
      await provider.insertTask(newTask);

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TaskDetailsPage(taskId: newTask.id)),
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
        Text(label, style: text.titleSmall),
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
        SizedBox(
          height: 150,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 4),
            scrollDirection: Axis.horizontal,
            itemCount: types.length,
            itemBuilder: (context, index) {
              final type = types[index];
              final selected = selectedType?.id == type.id;
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 8, right: 0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 3 - 8,
                  child: StyleImageButton(
                    title: type.name,
                    type: type,
                    selected: selected,
                    onTap: () => onSelected(type),
                  ),
                ),
              );
            },
          ),
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
    Type? selectedType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: text.titleSmall),
        const SizedBox(height: 8),
        if (errorText != null && errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              errorText,
              style: text.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        if (recipes.isEmpty)
          Card(
            child: InkWell(
              onTap: selectedType == null
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AddRecipePage(initialType: selectedType),
                        ),
                      );
                    },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  AppStrings.get(
                    'noRecipesForType',
                    lang,
                  ).replaceAll('{type}', selectedType?.name ?? ''),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    //decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: recipes.map((recipe) {
              final selected = selectedRecipe?.id == recipe.id;
              return OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: selected
                      ? AppColors.sectionBg
                      : null,   
                  foregroundColor: selected
                      ? AppColors.textSecondary
                      : AppColors.textSecondary,       
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onPressed: () => onSelected(recipe),
                icon: Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,                 
                  // color: selected
                  //     ? AppColors.textOnDark
                  //     : Theme.of(context).colorScheme.outline,
                  size: 20,
                ),
                label: Text(
                  recipe.name,
                  style: TextStyle(
                    color: selected
                        ? AppColors.textSecondary
                        : AppColors.textSecondary,
                  ),
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
    int? selectedValue,
  }) {
    return OptionButtons(
      values: values,
      onSelected: onSelected,
      selectedValue: selectedValue,
    );
  }

  Widget _buildRatioButtons({String? selectedValue}) {
    return RatioButtons(onSelected: _setRatio, selectedValue: selectedValue);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().languageCode;

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
                    _selectedDoughRecipe = _doughRecipes.firstOrNull;
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
                selectedType: _selectedDoughType,
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
                    _selectedFillingRecipe = _fillingRecipes.firstOrNull;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildRecipeSelection(
                label: AppStrings.get('lblwhichFillingRecipe', lang),
                recipes: _fillingRecipes,
                selectedRecipe: _selectedFillingRecipe,
                errorText: _fillingRecipeError,
                selectedType: _selectedFillingType,
                onSelected: (recipe) {
                  setState(() {
                    _fillingRecipeError = null;
                    _selectedFillingRecipe = recipe;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [                             
                   Text(
                      AppStrings.get('quantity', lang),
                       style: text.titleSmall,
                    ),
                  
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(),
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildOptionButtons(
                values: [4, 8, 10, 16],
                onSelected: _setQuantity,
                selectedValue: _selectedQuantity,
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [               
                  
                   Text(
                      AppStrings.get('size', lang),
                      style: text.titleSmall,
                    ),
                 
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(),
                      controller: _sizeController,
                      keyboardType: TextInputType.number,
                      style: text.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildOptionButtons(
                values: [35, 50, 75, 100],
                onSelected: _setSize,
                selectedValue: _selectedSize,
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      AppStrings.get('ratio', lang),
                      style: text.titleSmall,
                    ),
                
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _ratioController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(),
                      style: text.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildRatioButtons(selectedValue: _selectedRatio != null ? Helper.ratioToString(_selectedRatio!) : null),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isCalculating ? null : _calculateTask,
                  icon: _isCalculating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.calculate),
                  label: Text(
                    _isCalculating
                        ? AppStrings.get('calculating', lang)
                        : AppStrings.get('calculateSave', lang),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
