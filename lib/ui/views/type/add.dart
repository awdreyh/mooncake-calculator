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

class AddTypePage extends StatefulWidget {
  const AddTypePage({super.key});

  @override
  State<AddTypePage> createState() => _AddTypePageState();
}

class _AddTypePageState extends State<AddTypePage> {
  final _nameController = TextEditingController();
  Category _category = Category.dough;
  String? _imagePath;
  bool _isSaving = false;

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
    if (_imagePath == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(_imagePath!),
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
        ),
      ),
    );
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

    final newType = Type(
      id: const Uuid().v4(),
      category: _category,
      name: name,
      imagePath: _imagePath,
      matchedDoughTypeIds: _category == Category.filling ? <String>[] : null,
    );

    final provider = TypeProvider(TypeRepository(MCDatabase.instance));
    await provider.insertType(newType);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('addType', lang)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }
}
