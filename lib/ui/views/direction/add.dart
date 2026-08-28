import 'package:flutter/material.dart';
import '../../../provider/direction.dart';
import '../../../data/model/direction.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import '../../utils/language_provider.dart';
import 'package:provider/provider.dart';
import '../../utils/app_strings.dart';
import '../../core/app_theme.dart';

class AddDirectionPage extends StatefulWidget {
  final String recipeId;
  const AddDirectionPage({super.key, required this.recipeId});

  @override
  State<AddDirectionPage> createState() => _AddDirectionPageState();
}

class _DirectionInput {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String stepIndex;
  String? _imagePath;

  _DirectionInput({
    String title = '',
    String description = '',
    this._imagePath,
    required this.stepIndex,
  }) : titleController = TextEditingController(text: title),
       descriptionController = TextEditingController(text: description);

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
  }
}

class _AddDirectionPageState extends State<AddDirectionPage> {
  LanguageProvider get languageProvider =>
      Provider.of<LanguageProvider>(context, listen: false);
  String get lang => languageProvider.languageCode;
  TextTheme get text => Theme.of(context).textTheme;
  final _formKey = GlobalKey<FormState>();
  ColorScheme get color => Theme.of(context).colorScheme;
  final List<_DirectionInput> _directions = List.generate(
    1,
    (index) => _DirectionInput(stepIndex: "${index + 1}"),
  );

  @override
  void dispose() {
    for (final direction in _directions) {
      direction.dispose();
    }
    super.dispose();
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

  Future<void> _pickImage(_DirectionInput step) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final savedPath = await _copySelectedImage(pickedFile.path);
    if (savedPath != null) {
      setState(() => step._imagePath = savedPath);
    }
  }

  void _addStep() {
    setState(() {
      _directions.add(_DirectionInput(stepIndex: "${_directions.length + 1}"));
    });
  }

  void _removeStep(int index) {
    if (_directions.length <= 1) {
      return;
    }
    setState(() {
      _directions.removeAt(index);
      for (int i = 0; i < _directions.length; i++) {
        _directions[i] = _DirectionInput(
          title: _directions[i].titleController.text,
          description: _directions[i].descriptionController.text,
          imagePath: _directions[i]._imagePath,
          stepIndex: "${i + 1}",
        );
      }
    });
  }

  void _reorderSteps(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;

      final item = _directions.removeAt(oldIndex);
      _directions.insert(newIndex, item);

      for (int i = 0; i < _directions.length; i++) {
        _directions[i] = _DirectionInput(
          title: _directions[i].titleController.text,
          description: _directions[i].descriptionController.text,
          imagePath: _directions[i]._imagePath,
          stepIndex: "${i + 1}",
        );
      }
    });
  }

  Future<void> _saveDirectionsToRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final directionProvider = Provider.of<DirectionProvider>(
        context,
        listen: false,
      );
      await directionProvider.saveDirections(
        widget.recipeId,
        _directions
            .map(
              (direction) => Direction(
                id: const Uuid().v4(),
                stepTitle: direction.titleController.text,
                stepDescription: direction.descriptionController.text,
                stepIndex: direction.stepIndex,
                stepImagePath: direction._imagePath,
                recipeId: widget.recipeId,
              ),
            )
            .toList(),
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error saving directions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('add_directions', lang)),
          actions: [],
        ),

        // floatingActionButton: FloatingActionButton(
        //   onPressed: _addStep,
        //   child: const Icon(Icons.add),
        // ),
        body: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height - 200,
                      ),
                      child: ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _directions.length + 1, // +1 for the Add Step button
                onReorderItem: _reorderSteps,
                itemBuilder: (context, index) {
                  // If last item → show Add Step button
                  if (index == _directions.length) {
                    return Card(
                      color: AppColors.sectionBg,
                      key: ValueKey(AppStrings.get('add_step', lang)),
                      child: TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text(AppStrings.get('add_step', lang)),
                        onPressed: _addStep,
                      ),
                    );
                  }

                  // Otherwise → show normal step card
                  final step = _directions[index];

                  return Card(
                    key: ValueKey(step.stepIndex),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.sectionBg,
                                foregroundColor: AppColors.textPrimary,
                                radius: 14,
                                child: FittedBox(
                                  child: Text(
                                    step.stepIndex,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => _removeStep(index),
                              ),
                              const Icon(Icons.drag_indicator),
                            ],
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: step.titleController,
                            maxLength: 50,
                            decoration: InputDecoration(
                              labelText: AppStrings.get('step_title', lang),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: step.descriptionController,
                            decoration: InputDecoration(
                              labelText: AppStrings.get(
                                'step_description',
                                lang,
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            maxLength: 500,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppStrings.get(
                                  'validStepDescriptionMsg',
                                  lang,
                                );
                              }
                              return null;
                            },
                            maxLines: 5,
                          ),
                          
                          const SizedBox(height: 12),
                          if (step._imagePath != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(step._imagePath!),
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.photo),
                            label: Text(AppStrings.get('selectImage', lang)),
                            onPressed: () => _pickImage(step),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDirectionsToRecipe,
                child: Text(AppStrings.get('save', lang)),
              ),
            ),
            const SizedBox(height: 46),
          ],
        ),
      ),
    
      ),
    );
  }
}
