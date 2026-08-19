import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../data/model/type.dart';
import '../../../provider/type.dart';
import '../../core/nav_bottom.dart';
import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';

class AddTypePage extends StatefulWidget {
  final Category? initialCategory;

  const AddTypePage({super.key, this.initialCategory});

  @override
  State<AddTypePage> createState() => _AddTypePageState();
}

class _AddTypePageState extends State<AddTypePage> {
  LanguageProvider get languageProvider =>
  Provider.of<LanguageProvider>(context, listen: false);
  String get lang => languageProvider.languageCode;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late Category _category = widget.initialCategory ?? Category.dough;
  bool _isSaving = false;
  String? _imagePath;
  List<Type> _doughTypes = [];
  List<Type> _fillingTypes = [];
  List<Type> _selectedMatchedDoughTypes = [];
  List<Type> _selectedMatchedFillingTypes = [];
  String? _matchedTypeError;

  @override
  void initState() {
    super.initState();
    _loadDoughTypes();
  }

  Future<void> _loadDoughTypes() async {
    try {
      final typeProvider = context.read<TypeProvider>();
      final types = await typeProvider.loadAllTypes();
      final doughTypes = types
          .where((type) => type.category == Category.dough)
          .toList();
      final fillingTypes = types
          .where((type) => type.category == Category.filling)
          .toList();

      if (mounted) {
        setState(() {
          _doughTypes = doughTypes;
          _fillingTypes = fillingTypes;
        });
      }
    } catch (e) {
      print('Error loading dough types: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dough types: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final savedPath = await _copySelectedImage(pickedFile.path);
    if (savedPath != null) {
      setState(() => _imagePath = savedPath);
  
    }
  }

  Future<String?> _copySelectedImage(String sourcePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory(p.join(appDir.path, 'images/types/'));
      await imageDir.create(recursive: true);
      final extension = p.extension(sourcePath);
      final fileName = '${const Uuid().v4()}$extension';
      final destPath = p.join(imageDir.path, fileName);
      await File(sourcePath).copy(destPath);
      return destPath;
    } catch (_) {
      return null;
    }
  }

  void _toggleMatchedDoughType(Type type) {
    setState(() {
      _matchedTypeError = null;
      if (_selectedMatchedDoughTypes.any((item) => item.id == type.id)) {
        _selectedMatchedDoughTypes.removeWhere((item) => item.id == type.id);
      } else {
        _selectedMatchedDoughTypes.add(type);
      }
    });
  }

  void _toggleMatchedFillingType(Type type) {
    setState(() {
      _matchedTypeError = null;
      if (_selectedMatchedFillingTypes.any((item) => item.id == type.id)) {
        _selectedMatchedFillingTypes.removeWhere((item) => item.id == type.id);
      } else {
        _selectedMatchedFillingTypes.add(type);
      }
    });
  }

  Widget _buildImagePreview() {
    if (_imagePath == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(_imagePath!),
          key: ValueKey(_imagePath),
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> _saveType() async {
    if (!_formKey.currentState!.validate()) return;

    if (_category == Category.filling && _selectedMatchedDoughTypes.isEmpty) {
      setState(() {
        _matchedTypeError = AppStrings.get('validMatchedDoughTypesMsg', lang);
      });
      return;
    }
    if (_category == Category.dough && _selectedMatchedFillingTypes.isEmpty) {
      setState(() {
        _matchedTypeError = AppStrings.get('validMatchedFillingTypesMsg', lang);
      });
      return;
    }

    final name = _nameController.text.trim();

    setState(() => _isSaving = true);

    final matchedIds = _category == Category.filling
        ? _selectedMatchedDoughTypes.map((type) => type.id).toList()
        : null;

    final newType = Type(
      id: const Uuid().v4(),
      category: _category,
      name: name,
      imagePath: _imagePath,
      matchedDoughTypeIds: matchedIds,
    );

    try {
      final typeProvider = context.read<TypeProvider>();
      await typeProvider.insertType(newType);

      // When adding a dough type, add its ID into all selected filling types.
      if (_category == Category.dough) {
        for (final filling in _selectedMatchedFillingTypes) {
          final ids = List<String>.from(filling.matchedDoughTypeIds ?? []);
          if (!ids.contains(newType.id)) {
            ids.add(newType.id);
          }
          await typeProvider.updateType(
            Type(
              id: filling.id,
              category: filling.category,
              name: filling.name,
              imagePath: filling.imagePath,
              matchedDoughTypeIds: ids,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error, stackTrace) {
      print('Error saving type: $error');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('addType', lang))),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                DropdownButtonFormField<Category>(
                  initialValue: _category,
                  items: Category.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(AppStrings.get(category.toMap(), lang)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _category = value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: AppStrings.get('type', lang),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Matched Dough Types for Filling
                if (_category == Category.filling) ...[
                  Text(
                    AppStrings.get('matched_dough_types', lang),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_matchedTypeError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _matchedTypeError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (_doughTypes.isEmpty)
                    const Text('No dough types available')
                  else
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
                  const SizedBox(height: 24),
                ],
                // Matched Filling Types for Dough
                if (_category == Category.dough) ...[
                  Text(
                    AppStrings.get('matched_filling_types', lang),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_matchedTypeError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _matchedTypeError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (_fillingTypes.isEmpty)
                    const Text('No filling types available')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _fillingTypes.map((type) {
                        final selected = _selectedMatchedFillingTypes.any(
                          (item) => item.id == type.id,
                        );
                        return FilterChip(
                          label: Text(type.name),
                          selected: selected,
                          onSelected: (_) => _toggleMatchedFillingType(type),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),
                ],
                _buildImagePreview(),
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: Text(AppStrings.get('selectImage', lang)),
                  onPressed: _pickImage,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveType,
                    child: Text(
                      _isSaving
                          ? AppStrings.get('saving', lang)
                          : AppStrings.get('save', lang),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }
}
