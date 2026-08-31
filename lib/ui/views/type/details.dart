import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../data/model/type.dart';
import '../../../provider/type.dart';
import '../../core/nav_bottom.dart';
import '../../utils/app_strings.dart';
import '../../utils/seeds_strings.dart';
import '../../utils/language_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../core/app_theme.dart';
import '../recipe/list.dart';
import '../../widgets/full_image.dart';

class TypeDetailsPage extends StatefulWidget {
  final Type type;
  const TypeDetailsPage({super.key, required this.type});

  @override
  State<TypeDetailsPage> createState() => _TypeDetailsPageState();
}

class _TypeDetailsPageState extends State<TypeDetailsPage> {
  static const _placeholderImage = 'assets/images/types/placeholder.jpg';
  String _typeName = '';
  Category? _category;
  String? _imagePath;
  List<Type> _doughTypes = [];
  List<Type> _fillingTypes = [];
  List<Type> _selectedMatchedDoughTypes = [];
  List<Type> _selectedMatchedFillingTypes = [];

  LanguageProvider get languageProvider =>
      Provider.of<LanguageProvider>(context, listen: false);
  String get lang => languageProvider.languageCode;
  int _recipeUsageCount = 0;
  String? _matchedTypeError;

  @override
  void initState() {
    super.initState();
    _typeName = widget.type.name;
    _category = widget.type.category;
    _imagePath = widget.type.imagePath;
    _loadDoughTypes();
    _loadSelectedMatchedDoughTypes();
    _loadFillingTypes();
    _loadRecipeUsageCount();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadDoughTypes() async {
    try {
      final typeProvider = context.read<TypeProvider>();
      final types = await typeProvider.loadAllTypes();
      final doughTypes = types
          .where((type) => type.category == Category.dough)
          .toList();

      if (mounted) {
        setState(() {
          _doughTypes = doughTypes;
        });
      }
    } catch (e) {
     
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dough types: $e')),
        );
      }
    }
  }

  Future<void> _loadRecipeUsageCount() async {
    if (!mounted) return;
    final typeProvider = context.read<TypeProvider>();
    final count = await typeProvider.countRecipesUsingType(widget.type.id);
    if (!mounted) return;
    setState(() {
      _recipeUsageCount = count;
    });
  }

  void _openRelatedRecipes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeListPage(typeId: widget.type.id),
      ),
    );
  }

  Future<void> _loadSelectedMatchedDoughTypes() async {
    try {
      final typeProvider = context.read<TypeProvider>();
      final matchedTypes = await typeProvider.loadMatchedDoughTypes(
        widget.type.id,
      );

      if (mounted) {
        setState(() {
          _selectedMatchedDoughTypes = matchedTypes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load selected matched dough types: $e')),
        );
      }
    }
  }

  Future<void> _loadFillingTypes() async {
    try {
      final typeProvider = context.read<TypeProvider>();
      final types = await typeProvider.loadAllTypes();
      final fillingTypes = types
          .where((type) => type.category == Category.filling)
          .toList();
      final matchedFillingTypes = fillingTypes
          .where(
            (type) =>
                type.matchedDoughTypeIds?.contains(widget.type.id) ?? false,
          )
          .toList();

      if (mounted) {
        setState(() {
          _fillingTypes = fillingTypes;
          _selectedMatchedFillingTypes = matchedFillingTypes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load filling types: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    final savedPath = await _copySelectedImage(pickedFile.path);
    if (savedPath != null) {
      setState(() => _imagePath = savedPath);
    }
  }

  Future<String?> _copySelectedImage(String sourcePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory(p.join(appDir.path, 'type_images'));
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
      if (_selectedMatchedDoughTypes.any((item) => item.id == type.id)) {
        _selectedMatchedDoughTypes.removeWhere((item) => item.id == type.id);
      } else {
        _selectedMatchedDoughTypes.add(type);
      }
    });
  }

  void _toggleMatchedFillingType(Type type) {
    setState(() {
      if (_selectedMatchedFillingTypes.any((item) => item.id == type.id)) {
        _selectedMatchedFillingTypes.removeWhere((item) => item.id == type.id);
      } else {
        _selectedMatchedFillingTypes.add(type);
      }
    });
  }
  Widget _buildImagePreview() {
    final imagePath = _imagePath ?? widget.type.imagePath?.trim();
    final isLocalFile =
        imagePath != null &&
        imagePath.isNotEmpty &&
        !imagePath.startsWith('assets/');

    final image = isLocalFile
        ? Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Image.asset(_placeholderImage, fit: BoxFit.cover),
          )
        : Image.asset(
            imagePath?.isNotEmpty == true ? imagePath! : _placeholderImage,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Image.asset(_placeholderImage, fit: BoxFit.cover),
          );
         

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullImageView(
              imagePath: imagePath?.isNotEmpty == true
                  ? imagePath!
                  : _placeholderImage,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(width: double.infinity, height: 180, child: image),
      ),
    );
  }

  Future<void> _saveType() async {
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

    final matchedIds = _category == Category.filling
        ? _selectedMatchedDoughTypes.map((type) => type.id).toList()
        : null;

    final updatedType = Type(
      id: widget.type.id,
      category: _category ?? Category.dough,
      name: _typeName,
      imagePath: _imagePath,
      matchedDoughTypeIds: matchedIds,
    );

    try {
      final typeProvider = context.read<TypeProvider>();
      await typeProvider.updateType(updatedType);

      // When this is a dough type, sync its ID into selected filling types
      // and remove it from deselected ones.
      if (updatedType.category == Category.dough) {
        for (final filling in _fillingTypes) {
          final wasSelected =
              filling.matchedDoughTypeIds?.contains(widget.type.id) ?? false;
          final isSelected = _selectedMatchedFillingTypes.any(
            (item) => item.id == filling.id,
          );
          if (wasSelected == isSelected) continue;

          final ids = List<String>.from(filling.matchedDoughTypeIds ?? []);
          if (isSelected) {
            ids.add(widget.type.id);
          } else {
            ids.remove(widget.type.id);
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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('changes_saved', lang))),
      );
      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
     

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('type_details_title', lang))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            child: _category == Category.filling
                                ? Icon(
                                    Icons.egg_alt,
                                    size: 24,
                                    color: AppColors.accentRed,
                                  )
                                : _category == Category.dough
                                ? Icon(
                                    Icons.cookie,
                                    size: 24,
                                    color: AppColors.accent,
                                  )
                                : const SizedBox.shrink(),
                          ),

                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  SeedsStrings.get(_typeName, lang).isNotEmpty
                                      ? SeedsStrings.get(_typeName, lang)
                                      : _typeName,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                if (_recipeUsageCount > 0)
                                  GestureDetector(
                                    onTap: _openRelatedRecipes,
                                    child: Text(
                                      AppStrings.get(
                                        'used_in_recipes',
                                        lang,
                                      ).replaceAll(
                                        '{count}',
                                        _recipeUsageCount.toString(),
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
                                      'used_in_recipes',
                                      lang,
                                    ).replaceAll(
                                      '{count}',
                                      _recipeUsageCount.toString(),
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
              const SizedBox(height: 24),
              if (_category == Category.filling) ...[
                Text(
                  AppStrings.get('matched_dough_types', lang),
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
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
                        label: Text(
                          SeedsStrings.get(type.name, lang).isNotEmpty
                              ? SeedsStrings.get(type.name, lang)
                              : type.name,
                        ),
                        selectedColor: AppColors.accent,
                        backgroundColor: AppColors.cream,
                        labelStyle: TextStyle(
                          color: selected
                              ? AppColors.cream
                              : AppColors.textPrimary,
                        ),
                        checkmarkColor: AppColors.cream,
                        selected: selected,
                        onSelected: (_) => _toggleMatchedDoughType(type),
                      );
                    }).toList(),
                  ),
              ],
              if (_category == Category.dough) ...[
                Text(
                  AppStrings.get('matched_filling_types', lang),
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
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
                        label: Text(
                          SeedsStrings.get(type.name, lang).isNotEmpty
                              ? SeedsStrings.get(type.name, lang)
                              : type.name,
                        ),
                        selectedColor: AppColors.accent,
                        backgroundColor: AppColors.cream,
                        labelStyle: TextStyle(
                          color: selected
                              ? AppColors.cream
                              : AppColors.textPrimary,
                        ),
                        checkmarkColor: AppColors.cream,
                        selected: selected,
                        onSelected: (_) => _toggleMatchedFillingType(type),
                      );
                    }).toList(),
                  ),
              ],
              if (_matchedTypeError != null) ...[
                Text(
                  _matchedTypeError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
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
                  onPressed: _saveType,
                  child: Text(AppStrings.get('save', lang)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }
}
