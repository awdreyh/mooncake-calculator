import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../db/db_helper.dart';
import '../../../db/model/recipe.dart';
import '../../../db/model/task.dart';

import '../../../db/repository/task.dart';
import '../../../provider/recipe.dart';
import '../../../db/repository/recipe.dart';
import '../../../provider/task.dart';

class TaskDetailsPage extends StatefulWidget {
  final String taskId;

  const TaskDetailsPage({super.key, required this.taskId});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  final taskProvider = TaskProvider(TaskRepository(MCDatabase.instance));
  final recipeProvider = RecipeProvider(RecipeRepository(MCDatabase.instance));
  
  Task? _task;
  Recipe? _doughRecipe;
  Recipe? _fillingRecipe;
  bool _isLoading = true;
  bool _isSavingImages = false;
  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    try {
      final task = await taskProvider.loadTask(widget.taskId);
      if (!mounted) return;

      Recipe? doughRecipe;
      Recipe? fillingRecipe;

      if (task != null) {
        try {
          doughRecipe = await recipeProvider.loadRecipe(task.doughRecipeId);
        } catch (error, stackTrace) {
          debugPrint('Failed to load dough recipe ${task.doughRecipeId}: $error\n$stackTrace');
        }

        try {
          fillingRecipe = await recipeProvider.loadRecipe(task.fillingRecipeId);
        } catch (error, stackTrace) {
          debugPrint('Failed to load filling recipe ${task.fillingRecipeId}: $error\n$stackTrace');
        }
      }

      if (!mounted) return;
      setState(() {
        _task = task;
        _imagePaths = task?.imagePaths ?? [];
        _doughRecipe = doughRecipe;
        _fillingRecipe = fillingRecipe;
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
      final imageDir = Directory(p.join(appDir.path, 'task_images'));
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
      await TaskProvider(TaskRepository(MCDatabase.instance)).updateTask(updatedTask);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_task == null) {
      return const Scaffold(body: Center(child: Text('Task not found')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dough recipe: ${_doughRecipe?.name ?? _task!.doughRecipeId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Filling recipe: ${_fillingRecipe?.name ?? _task!.fillingRecipeId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSavingImages ? null : _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: Text(_isSavingImages ? 'Uploading...' : 'Upload Images'),
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
                    child: Image.file(
                      File(path),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            Text('Qty: ${_task!.quantity}'),
            Text('Size: ${_task!.size}'),
            Text('Ratio: ${_task!.ratio.toStringAsFixed(2)}'),
            const SizedBox(height: 24),
            const Text(
              'Ingredients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_task!.ingredients.isEmpty)
              const Text('No ingredients were calculated.')
            else
              ..._task!.ingredients.map((ingredient) {
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
        ),
      ),
    );
  }
}
