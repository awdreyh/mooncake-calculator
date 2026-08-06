import 'package:flutter/material.dart';
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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.type.name);
    _category = widget.type.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
      imageName: widget.type.imageName,
      matchedDoughTypeIds: widget.type.matchedDoughTypeIds,
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
        title: Text(AppStrings.get('typeDetails', lang) ?? 'Type Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppStrings.get('name', lang),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Category>(
              value: _category,
              items: Category.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.toMap()),
                );
              }).toList(),
              onChanged: (value) => setState(() => _category = value),
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
                    ? AppStrings.get('saving', lang) ?? 'Saving...'
                    : AppStrings.get('save', lang)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    );
  }
}
