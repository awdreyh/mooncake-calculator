import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../db/db_helper.dart';
import '../../../db/model/type.dart';
import '../../../db/repository/type.dart';
import '../../../provider/type.dart';
import '../../core/nav_bottom.dart';
import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';

class TypeDetailsPage extends StatefulWidget {
  final Type type;
  const TypeDetailsPage({super.key, required this.type});

  @override
  State<TypeDetailsPage> createState() => _TypeDetailsPageState();
}

class _TypeDetailsPageState extends State<TypeDetailsPage> {
  late final TextEditingController _nameController;
  Category? _category;
  String? _imagePath;
  bool _isSaving = false;
  List<String> _matchedDoughTypeIds = [];
  List<Type> _allTypes = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.type.name);
    _category = widget.type.category;
    _imagePath = widget.type.imagePath;
    _matchedDoughTypeIds = List<String>.from(widget.type.matchedDoughTypeIds ?? const <String>[]);
    _loadTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _matchedDoughTypeIds.clear();
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

  Widget _buildImagePreview() {
    if (_imagePath == null) return const SizedBox.shrink();

    final file = File(_imagePath!);
    if (!file.existsSync()) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          file,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> _loadTypes() async {
    final provider = TypeProvider(TypeRepository(MCDatabase.instance));
    final types = await provider.loadAllTypes();
    if (!mounted) return;
    setState(() {
      _allTypes = types;
    });
  }

  void _toggleMatchedDoughType(Type type) {
    setState(() {
      if (_matchedDoughTypeIds.contains(type.id)) {
        _matchedDoughTypeIds.remove(type.id);
      } else {
        _matchedDoughTypeIds.add(type.id);
      }
    });
  }

  Future<void> _saveType() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final lang = languageProvider.languageCode;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('validRecipeNameMsg', lang))),
      );
      return;
    }

    setState(() => _isSaving = true);
    final updatedType = Type(
      id: widget.type.id,
      category: _category ?? Category.dough,
      name: name,
      imagePath: _imagePath,
      matchedDoughTypeIds: _category == Category.filling ? _matchedDoughTypeIds : null,
    );

    final provider = TypeProvider(TypeRepository(MCDatabase.instance));
    await provider.updateType(updatedType);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('typeDetails', lang)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePreview(),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.photo),
                      label: Text(AppStrings.get('selectImage', lang)),
                      onPressed: _pickImage,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: AppStrings.get('name', lang),
                      ),
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
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _category = value);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: AppStrings.get('type', lang),
                      ),
                    ),
                    if (_category == Category.filling) ...[
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.get('matched_dough_types', lang),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allTypes
                            .where((type) => type.category == Category.dough)
                            .map((type) {
                              final selected = _matchedDoughTypeIds.contains(type.id);
                              return FilterChip(
                                label: Text(type.name),
                                selected: selected,
                                onSelected: (_) => _toggleMatchedDoughType(type),
                              );
                            })
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveType,
                        child: Text(_isSaving
                            ? AppStrings.get('saving', lang)
                            : AppStrings.get('save', lang)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }
}
