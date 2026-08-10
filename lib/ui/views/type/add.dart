import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
//import '../../../data/database/db_helper.dart';
import '../../../data/model/type.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Category _category = Category.dough;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveType() async {
     if (!_formKey.currentState!.validate()) return;
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
      imagePath: null,
      matchedDoughTypeIds: _category == Category.filling ? <String>[] : null,
    );

    try {
      await context.read<TypeProvider>().insertType(newType);
      if (mounted) {
        Navigator.of(context).pop(true);
      } }catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.get('errorSavingType', lang)}: $error')),
        );

    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  
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
