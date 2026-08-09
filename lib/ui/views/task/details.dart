import 'package:flutter/material.dart';
import '../../../data/database/db_helper.dart';
import '../../../data/model/recipe.dart';
import '../../../data/model/task.dart';

import '../../../data/repository/task.dart';
import '../../../provider/recipe.dart';
import '../../../data/repository/recipe.dart';
import '../../../provider/task.dart';

import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
import '../../utils/helper.dart';
import 'details.dart';
import '../../widgets/image_button.dart';
import '../../widgets/selection_buttons.dart';
import '../../widgets/text.dart';

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

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    final task = await taskProvider.loadTask(widget.taskId);
    if (!mounted) return;

    Recipe? doughRecipe;
    Recipe? fillingRecipe;

    if (task != null) {
      doughRecipe = await recipeProvider.loadRecipe(task.doughRecipeId);
      fillingRecipe = await recipeProvider.loadRecipe(task.fillingRecipeId);
    }

    setState(() {
      _task = task;
      _doughRecipe = doughRecipe;
      _fillingRecipe = fillingRecipe;
      _isLoading = false;
    });
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
