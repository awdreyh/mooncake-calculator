import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../data/model/type.dart';
import '../../../provider/type.dart';
import '../../core/nav_bottom.dart';
import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class TypeDetailsPage extends StatefulWidget {
  final Type type;
  const TypeDetailsPage({super.key, required this.type});

  @override
  State<TypeDetailsPage> createState() => _TypeDetailsPageState();
}

class _TypeDetailsPageState extends State<TypeDetailsPage> {
  late final TextEditingController _nameController;
  static const _placeholderImage = 'assets/images/types/placeholder.jpg';
  Category? _category;
  String? _imagePath;
  List<Type> _doughTypes = [];
  List<Type> _selectedMatchedDoughTypes = [];
  bool _isSaving = false;
  LanguageProvider get languageProvider =>
      Provider.of<LanguageProvider>(context, listen: false);
  String get lang => languageProvider.languageCode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.type.name);
    _category = widget.type.category;
    _imagePath = widget.type.imagePath;
    _loadDoughTypes();
    _loadSelectedMatchedDoughTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      print('Error loading dough types: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dough types: $e')),
        );
      }
    }
  }

  Future<void> _loadSelectedMatchedDoughTypes() async {
    try {
      final typeProvider = context.read<TypeProvider>();
      final matchedTypes = await typeProvider.loadMatchedDoughTypes(widget.type.id);
      
      if (mounted) {
        setState(() {
          _selectedMatchedDoughTypes = matchedTypes;
        });
      }
    } catch (e) {
      print('Error loading selected matched dough types: $e');
    }
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

  Widget _buildImagePreview() {
    final imagePath = widget.type.imagePath?.trim();
    final isLocalFile = imagePath != null &&
        imagePath.isNotEmpty &&
        !imagePath.startsWith('assets/');

    final image = isLocalFile
        ? Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Image.asset(
              _placeholderImage,
              fit: BoxFit.cover,
            ),
          )
        : Image.asset(
            imagePath?.isNotEmpty == true ? imagePath! : _placeholderImage,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Image.asset(
              _placeholderImage,
              fit: BoxFit.cover,
            ),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: double.infinity,
        height: 180,
        child: image,
      ),
    );
  }

  Future<void> _saveType() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('validRecipeNameMsg', lang))),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    final matchedIds = _category == Category.filling 
        ? _selectedMatchedDoughTypes.map((type) => type.id).toList() 
        : null;

    final updatedType = Type(
      id: widget.type.id,
      category: _category ?? Category.dough,
      name: name,
      imagePath: _imagePath,
      matchedDoughTypeIds: matchedIds,
    );

    try {
      print('Updating type: $updatedType');
      print('Matched IDs: $matchedIds');
      
      await context.read<TypeProvider>().updateType(updatedType);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('changes_saved', lang))),
      );
      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      print('Error updating type: $error');
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
      appBar: AppBar(
        title: Text(AppStrings.get('type_details_title', lang)),
        actions: [
          if (!_isSaving)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.green),
              onPressed: _saveType,
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
                    child: Text(category.toMap()),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _category = value),
                decoration: InputDecoration(
                  labelText: AppStrings.get('type', lang),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              if (_category == Category.filling) ...[
                Text(
                  AppStrings.get('matched_dough_types', lang),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        label: Text(type.name),
                        selected: selected,
                        onSelected: (_) => _toggleMatchedDoughType(type),
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
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }
}
