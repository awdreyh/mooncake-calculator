import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../utils/language_provider.dart';
import '../../utils/app_strings.dart';
import '../../utils/seeds_strings.dart';
import '../../core/nav_bottom.dart';
import '../../utils/helper.dart';
import '../../../data/model/task.dart';
import '../../../data/model/recipe.dart';
import '../../../data/model/ingredient.dart';
import '../../../provider/recipe.dart';
import '../../../provider/task.dart';
import '../../core/app_theme.dart';
import '../../widgets/info_chips.dart';
import '../recipe/details.dart';
import '../../widgets/full_image.dart';

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
  double _selectedRating = 0;

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
        var titleDough = SeedsStrings.get(typeNames[0], lang)?.isNotEmpty == true ? SeedsStrings.get(typeNames[0], lang) : typeNames[0];
        var titleFilling = SeedsStrings.get(typeNames[1], lang)?.isNotEmpty == true ? SeedsStrings.get(typeNames[1], lang) : typeNames[1];
          title = '$titleDough + $titleFilling ';
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
        _selectedRating = task?.rating ?? 0;
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

    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
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
    final updatedRating = _selectedRating;
    if (_task == null) return;
    setState(() => _isSaving = true);

    final updatedTask = _task!.copyWith(
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
      isCompleted: _isCompleted,
      updatedAt: DateTime.now(),
      rating: updatedRating > 0 ? updatedRating : null,
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

  Future<void> _deleteTask() async {
    if (_task == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.get('delete_task', lang),
          style: const TextStyle(fontSize: 18),
        ),
        content: Text(AppStrings.get('confirm_delete_task', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppStrings.get('delete_task', lang),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await context.read<TaskProvider>().deleteTask(_task!.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('failed_to_update_changes', lang)),
        ),
      );
    }
  }

  Widget _buildIngredientSection(
    String title,
    Recipe recipe,
    List<Ingredient> ingredients,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            ActionChip(
              label: Text(SeedsStrings.get(recipe.name, lang).isNotEmpty ? SeedsStrings.get(recipe.name, lang) : recipe.name),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailsPage(recipe: recipe),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 4),
        if (ingredients.isEmpty)
          Text(AppStrings.get('noIngredients', lang))
        else
          ...ingredients.map((ingredient) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(SeedsStrings.get(ingredient.name, lang).isNotEmpty ? SeedsStrings.get(ingredient.name, lang) : ingredient.name)),
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
      return Scaffold(
        body: Center(child: Text(AppStrings.get('noTasks', lang))),
      );
    }
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          toolbarHeight: 32,
          systemOverlayStyle: SystemUiOverlayStyle(
            // background of the top bar
            statusBarIconBrightness: Brightness.dark, // icons become white
            systemNavigationBarColor: AppColors.espressoLight,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          title: Text(AppStrings.get('task_details_title', lang)),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: _deleteTask,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: AppColors.accent,

                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.cream,
                          ),
                        ),
                        Text(
                          ' ${_task!.createdAt.toLocal().toString().split('.').first}',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.cream,
                          ),
                        ),
                        const SizedBox(height: 16),
                        InfoChips(
                          qty: _task!.quantity,
                          size: _task!.size,
                          ratio: Helper.ratioToString(_task!.ratio),
                        ),
                      ],
                    ),
                  ),
                ),
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
                      onChanged: (value) async {
                        setState(() => _isCompleted = value);
                        if (_task == null) return;
                        final updatedTask = _task!.copyWith(
                          isCompleted: value,
                          updatedAt: DateTime.now(),
                        );
                        try {
                          await context.read<TaskProvider>().updateTask(
                            updatedTask,
                          );
                          if (!mounted) return;
                          setState(() => _task = updatedTask);
                        } catch (error) {
                          if (!mounted) return;
                          setState(() => _isCompleted = !value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppStrings.get(
                                  'failed_to_update_changes',
                                  lang,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),

              // const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.get('ingredients_sheet', lang),
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_task!.ingredients.isEmpty)
                          Text(AppStrings.get('noIngredients', lang))
                        else ...[
                          _buildIngredientSection(
                            AppStrings.get('dough', lang),
                            _doughRecipe!,
                            _task!.ingredients
                                .take(_doughRecipe?.ingredients.length ?? 0)
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          _buildIngredientSection(
                            AppStrings.get('filling', lang),
                            _fillingRecipe!,
                            _task!.ingredients
                                .skip(_doughRecipe?.ingredients.length ?? 0)
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Rating
              Text(
                AppStrings.get('satisfaction', lang),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          final starValue = index + 1;
                          final isSelected = _selectedRating >= starValue;
                          return IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isSelected
                                  ? Icons.sentiment_satisfied_rounded
                                  : Icons.sentiment_satisfied_outlined,
                              color: isSelected ? Colors.amber : Colors.grey,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedRating = starValue.toDouble();
                              });
                              _saveTask();
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedRating > 0
                            ? '$_selectedRating / 5.0'
                            : AppStrings.get('no_rating', lang),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Divider(color: AppColors.borderLight, thickness: 0.5),
              const SizedBox(height: 16),
              Text(
                AppStrings.get('comment', lang),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveTask,
                  label: Text(AppStrings.get('save', lang)),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                AppStrings.get('image_title', lang),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_imagePaths.isEmpty)
                Text(AppStrings.get('no_image_uploaded', lang))
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

                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullImageView(imagePath: path),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),

                        // Delete button
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _imagePaths.removeAt(index);
                                _saveTask(); // Save the task after removing the image
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white.withValues(alpha: 0.4),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSavingImages ? null : _pickImages,
                      icon: const Icon(Icons.photo_library),
                      label: Text(
                        _isSavingImages ? AppStrings.get('uploading', lang) : AppStrings.get('selectImage', lang),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
      ),
    );
  }
}
