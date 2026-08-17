import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../utils/language_provider.dart';
import '../../utils/app_strings.dart';
import '../../core/nav_bottom.dart';
import '../../utils/helper.dart';

import '../../../data/model/task.dart';
import '../../../data/model/recipe.dart';
import '../../../data/model/ingredient.dart';

import '../../../provider/recipe.dart';
import '../../../provider/task.dart';

class TaskDetailsPage extends StatefulWidget {
  final String taskId;

  const TaskDetailsPage({super.key, required this.taskId});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  LanguageProvider get languageProvider =>
      Provider.of<LanguageProvider>(context, listen: false);
  String get lang => languageProvider.languageCode;

  Task? _task;
  Recipe? _doughRecipe;
  Recipe? _fillingRecipe;
  bool _isLoading = true;
  bool _isSavingImages = false;
  bool _isSaving = false;
  List<String> _imagePaths = [];
  String _title = '';
  late TextEditingController _commentController;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _loadTask();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadTask() async {
    try {
      final taskProvider = context.read<TaskProvider>();
      final recipeProvider = context.read<RecipeProvider>();
      final task = await taskProvider.loadTask(widget.taskId);
      if (!mounted) return;

      Recipe? doughRecipe;
      Recipe? fillingRecipe;
      String title = 'Task Details';

      if (task != null) {
        try {
          doughRecipe = await recipeProvider.loadRecipe(task.doughRecipeId);
        } catch (error, stackTrace) {
          debugPrint(
            'Failed to load dough recipe ${task.doughRecipeId}: $error\n$stackTrace',
          );
        }

        try {
          fillingRecipe = await recipeProvider.loadRecipe(task.fillingRecipeId);
        } catch (error, stackTrace) {
          debugPrint(
            'Failed to load filling recipe ${task.fillingRecipeId}: $error\n$stackTrace',
          );
        }

        try {
          final typeNames = await Future.wait([
            recipeProvider.loadType(task.doughRecipeId),
            recipeProvider.loadType(task.fillingRecipeId),
          ]);
          title = '${typeNames[0]} + ${typeNames[1]}';
        } catch (error, stackTrace) {
          debugPrint(
            'Failed to load type names for task ${task.id}: $error\n$stackTrace',
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _task = task;
        _imagePaths = task?.imagePaths ?? [];
        _doughRecipe = doughRecipe;
        _fillingRecipe = fillingRecipe;
        _title = title;
        _isCompleted = task?.isCompleted ?? false;
        _commentController.text = task?.comment ?? '';
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('Failed to load task ${widget.taskId}: $error\n$stackTrace');
      setState(() {
        _task = null;
        _imagePaths = [];
        _doughRecipe = null;
        _fillingRecipe = null;
        _isLoading = false;
      });
    }
  }

  Future<String?> _saveSelectedImage(String sourcePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory(p.join(appDir.path, 'images/tasks/'));
      await imageDir.create(recursive: true);
      final extension = p.extension(sourcePath);
      final destPath = p.join(imageDir.path, '${const Uuid().v4()}$extension');
      await File(sourcePath).copy(destPath);
      return destPath;
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isEmpty) {
      return;
    }

    setState(() => _isSavingImages = true);
    final copiedPaths = <String>[];
    for (final pickedFile in pickedFiles) {
      final savedPath = await _saveSelectedImage(pickedFile.path);
      if (savedPath != null) {
        copiedPaths.add(savedPath);
      }
    }

    final updatedPaths = [..._imagePaths, ...copiedPaths];
    if (_task != null) {
      final updatedTask = _task!.copyWith(
        imagePaths: updatedPaths,
        updatedAt: DateTime.now(),
      );
      final taskProvider = context.read<TaskProvider>();
      await taskProvider.updateTask(updatedTask);
      if (!mounted) return;
      setState(() {
        _task = updatedTask;
        _imagePaths = updatedPaths;
        _isSavingImages = false;
      });
    } else {
      setState(() => _isSavingImages = false);
    }
  }

  Future<void> _saveTask() async {
    if (_task == null) return;
    setState(() => _isSaving = true);

    final updatedTask = _task!.copyWith(
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
      isCompleted: _isCompleted,
      updatedAt: DateTime.now(),
    );

    try {
      final taskProvider = context.read<TaskProvider>();
      await taskProvider.updateTask(updatedTask);
      if (!mounted) return;
      setState(() {
        _task = updatedTask;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('changes_saved', lang))),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('failed_to_update_changes', lang)),
        ),
      );
    }
  }

  Widget _buildIngredientSection(String title, List<Ingredient> ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        if (ingredients.isEmpty)
          const Text('No ingredients were calculated.')
        else
          ...ingredients.map((ingredient) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(ingredient.name)),
                  Text(
                    '${ingredient.amount.toStringAsFixed(2)} ${ingredient.unit.toMap()}',
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_task == null) {
      return const Scaffold(body: Center(child: Text('Task not found')));
    }
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('task_details_title', lang)),actions: [
          if (!_isSaving)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.green),
              onPressed: _saveTask,
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
        ],),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title,
               style: textTheme.titleLarge,
            ),
            Text(
              ' ${_task!.createdAt.toLocal().toString().split('.').first}',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              spacing: 4,
              children: [
                Flexible(
                  child: Chip(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: Text(
                      ' ${_task!.quantity} pcs',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: -4,
                    ),
                  ),
                ),
                Flexible(
                  child: Chip(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: Text(
                      ' ${_task!.size} g',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: Colors.grey.shade200,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: -4,
                    ),
                  ),
                ),
                Flexible(
                  child: Chip(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: Text(
                      ' ${Helper.ratioToString(_task!.ratio)}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: Colors.grey.shade200,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: -4,
                    ),
                  ),
                ),
              ],
            ),

            ListTile(
              contentPadding: EdgeInsets.zero, // removes left/right padding
              title: Text(AppStrings.get('lblCompleted', lang)),
              trailing: SizedBox(
                height: 36,
                width: 80,
                child: FittedBox(
                  child: Switch(
                    value: _isCompleted,
                    onChanged: (value) => setState(() => _isCompleted = value),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
  width: double.infinity,
              child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('used_recipe_details', lang),
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Dough recipe: ${_doughRecipe?.name ?? _task!.doughRecipeId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Filling recipe: ${_fillingRecipe?.name ?? _task!.fillingRecipeId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            ),
            const SizedBox(height: 16),        


            Text(
              AppStrings.get('ingredients', lang),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_task!.ingredients.isEmpty)
              const Text('No ingredients were calculated.')
            else ...[
              _buildIngredientSection(
                'Dough: ${_doughRecipe?.name ?? _task!.doughRecipeId}',
                _task!.ingredients
                    .take(_doughRecipe?.ingredients.length ?? 0)
                    .toList(),
              ),
              const SizedBox(height: 16),
              _buildIngredientSection(
                'Filling: ${_fillingRecipe?.name ?? _task!.fillingRecipeId}',
                _task!.ingredients
                    .skip(_doughRecipe?.ingredients.length ?? 0)
                    .toList(),
              ),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSavingImages ? null : _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: Text(
                      _isSavingImages ? 'Uploading...' : 'Upload Images',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_imagePaths.isEmpty)
              const Text('No images uploaded for this task yet.')
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: _imagePaths.length,
                itemBuilder: (context, index) {
                  final path = _imagePaths[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(path), fit: BoxFit.cover),
                  );
                },
              ),
            const SizedBox(height: 24),
            Text(
              AppStrings.get('comment', lang),
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: AppStrings.get('enter_comment', lang),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton.icon(
            //     onPressed: _isSaving ? null : _saveTask,
            //     icon: _isSaving
            //         ? const SizedBox(
            //             width: 16,
            //             height: 16,
            //             child: CircularProgressIndicator(strokeWidth: 2),
            //           )
            //         : const Icon(Icons.save),
            //     label: Text(AppStrings.get('save', lang)),
            //   ),
            // ),
            // const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
    );
  }
}
