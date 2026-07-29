import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../core/nav_bottom.dart';
import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
import 'package:provider/provider.dart';
import '../../../db/task.dart';
import '../../../db/recipe.dart';
import '../../../db/db_helper.dart';
import 'details.dart';


class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final MCService _mcService = MCService();
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    //initializeDateFormatting();
    _tasksFuture = _mcService.loadTasks();
  }

  void _showTaskDetailsModal(Task task, String lang) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm', lang == 'zh' ? 'zh_CN' : 'en_US');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${task.doughRecipeId} ',
          style: const TextStyle(fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormat.format(task.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              _buildTaskInfo('Size', '${task.size}g'),
              _buildTaskInfo('Quantity', '${task.quantity} cakes'),
              _buildTaskInfo('Ratio', task.ratio.toStringAsFixed(2)),
              const SizedBox(height: 16),
              _buildRecipeLink(task.doughRecipeId, 'Dough', lang),
              const SizedBox(height: 8),
              _buildRecipeLink(task.fillingRecipeId, 'Filling', lang),
              const SizedBox(height: 16),
              const Text(
                'Calculated Ingredients',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
    
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('close', lang)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeLink(String recipeId, String sectionTitle, String lang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          sectionTitle,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        GestureDetector(
          onTap: () => _showRecipeDetailModal(recipeId, lang),
          child: FutureBuilder<Recipe?>(
            future: _mcService.loadRecipe(recipeId),
            builder: (context, snapshot) {
              final recipeName = snapshot.data?.name ?? recipeId;
              return Text(
                recipeName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showRecipeDetailModal(String recipeId, String lang) async {
    final recipe = await _mcService.loadRecipe(recipeId);

    if (recipe == null) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Recipe not found'),
          content: Text('Could not find recipe with id: $recipeId'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.get('close', lang)),
            ),
          ],
        ),
      );
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(recipe.name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipe.typeId != null && recipe.typeId!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('Type: ${recipe.typeId}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ),
                if (recipe.description != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('Description: ${recipe.description}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ),
                const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                ...recipe.ingredients.map((ingredient) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${ingredient.name}: ${ingredient.amount} ${ingredient.unit}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.get('close', lang)),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTaskInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

 
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm', lang == 'zh' ? 'zh_CN' : 'en_US');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),   
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return Center(
              child: Text(
                AppStrings.get('noTasks', lang),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    '${task.doughRecipeId} + ${task.fillingRecipeId}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    dateFormat.format(task.createdAt),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTaskDetailsModal(task, lang),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: 1),
    );
  }
}
