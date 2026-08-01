import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

import '../../../db/db_helper.dart';
import '../../../db/recipe.dart';
import '../../../db/task.dart';
import '../../../db/type.dart';
import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
import 'details.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final MCService _mcService = MCService();
  final _formKey = GlobalKey<FormState>();

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _sizeController.dispose();
    _ratioController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final recipes = await _mcService.loadRecipes();
    final types = await _mcService.loadTypes();
    if (!mounted) return;
    setState(() {
      _allRecipes = recipes;
      _allTypes = types;
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

  double _parseRatio(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return 0.4;
    final first = int.tryParse(parts[0].trim()) ?? 0;
    final second = int.tryParse(parts[1].trim()) ?? 0;
    final total = first + second;
    if (total <= 0) return 0.4;
    return (first / total).clamp(0.0, 1.0);
  }

  Future<void> _calculateTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDoughRecipe == null || _selectedFillingRecipe == null) return;

    setState(() => _isCalculating = true);

    try {
      final ratio = _parseRatio(_ratioController.text.trim());
      final task = Task.createFromRecipes(
        id: const Uuid().v4(),
        doughRecipe: _selectedDoughRecipe!,
        fillingRecipe: _selectedFillingRecipe!,
        quantity: int.parse(_quantityController.text.trim()),
        size: int.parse(_sizeController.text.trim()),
        ratio: ratio,
      );

      final savedTaskId = await _mcService.saveTask(task);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TaskDetailsPage(taskId: savedTaskId),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCalculating = false);
      }
    }
  }

  Widget _buildSelectField<T>({
    required String label,
    required List<T> options,
    required T? value,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((option) => DropdownMenuItem<T>(
                value: option,
                child: Text(labelBuilder(option)),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select an option' : null,
    );
  }

  Widget _buildOptionButtons({
    required List<int> values,
    required TextEditingController controller,
    required ValueChanged<int> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      children: values.map((value) {
        return OutlinedButton(
          onPressed: () => onSelected(value),
          child: Text(value.toString()),
        );
      }).toList(),
    );
  }

  Widget _buildRatioButtons() {
    final ratios = ['2:8', '3:7', '4:6', '5:5'];
    return Wrap(
      spacing: 8,
      children: ratios.map((value) {
        return OutlinedButton(
          onPressed: () => _setRatio(value),
          child: Text(value),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('saveTask', lang))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSelectField<Type>(
                label: 'What type of mooncake?',
                options: _doughTypes,
                value: _selectedDoughType,
                labelBuilder: (type) => type.name,
                onChanged: (value) {
                  setState(() {
                    _selectedDoughType = value;
                    _selectedDoughRecipe = null;
                    _selectedFillingType = null;
                    _selectedFillingRecipe = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildSelectField<Recipe>(
                label: 'Which recipe do you want to use?',
                options: _doughRecipes,
                value: _selectedDoughRecipe,
                labelBuilder: (recipe) => recipe.name,
                onChanged: (value) {
                  setState(() => _selectedDoughRecipe = value);
                },
              ),
              const SizedBox(height: 16),
              _buildSelectField<Type>(
                label: 'Which type filling?',
                options: _fillingTypes,
                value: _selectedFillingType,
                labelBuilder: (type) => type.name,
                onChanged: (value) {
                  setState(() {
                    _selectedFillingType = value;
                    _selectedFillingRecipe = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildSelectField<Recipe>(
                label: 'Which recipe do you want to use?',
                options: _fillingRecipes,
                value: _selectedFillingRecipe,
                labelBuilder: (recipe) => recipe.name,
                onChanged: (value) {
                  setState(() => _selectedFillingRecipe = value);
                },
              ),
              const SizedBox(height: 24),
              Text('Qty', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                validator: (value) => value != null && value.isNotEmpty ? null : 'Please enter qty',
              ),
              const SizedBox(height: 8),
              _buildOptionButtons(values: [4, 8, 10, 16], controller: _quantityController, onSelected: _setQuantity),
              const SizedBox(height: 20),
              Text('Size', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _sizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                validator: (value) => value != null && value.isNotEmpty ? null : 'Please enter size',
              ),
              const SizedBox(height: 8),
              _buildOptionButtons(values: [50, 75, 100], controller: _sizeController, onSelected: _setSize),
              const SizedBox(height: 20),
              Text(AppStrings.get('ratio',lang), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ratioController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                validator: (value) => value != null && value.isNotEmpty ? null : 'Please enter ratio',
              ),
              const SizedBox(height: 8),
              _buildRatioButtons(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isCalculating ? null : _calculateTask,
                  icon: _isCalculating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.calculate),
                  label: Text(_isCalculating ? 'Calculating...' : 'Calculate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String> addTask({
  required Recipe doughRecipe,
  required Recipe fillingRecipe,
  required int quantity,
  required int size,
  required double ratio,
  String? id,
  String? comment,
  double? rating,
  bool? isCompleted,
  DateTime? createdAt,
  DateTime? updatedAt,
}) async {
  final taskId = id ?? const Uuid().v4();
  final task = Task.createFromRecipes(
    id: taskId,
    doughRecipe: doughRecipe,
    fillingRecipe: fillingRecipe,
    quantity: quantity,
    size: size,
    ratio: ratio,
    comment: comment,
    rating: rating,
    isCompleted: isCompleted,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  final mcService = MCService();
  return mcService.saveTask(task);
}
