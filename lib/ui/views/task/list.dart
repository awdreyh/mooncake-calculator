import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/task.dart';
import '../../../provider/recipe.dart';
import '../../../data/model/task.dart';

import '../../core/nav_bottom.dart';
import '../../utils/app_strings.dart';
import '../../utils/helper.dart';
import '../../utils/language_provider.dart';
import '../../core/app_theme.dart';
import 'details.dart';

class TaskListPage extends StatefulWidget {
  final String? recipeId;
  const TaskListPage({super.key, this.recipeId});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  String get lang => context.read<LanguageProvider>().languageCode;

  bool _isLoading = true;
  String? _errorMessage;
  List<Task> _tasks = [];
  // taskId -> "Dough Type + Filling Type"
  final Map<String, String> _titles = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final recipeProvider = context.read<RecipeProvider>();
      final tasks = await context.read<TaskProvider>().loadAllTasks();
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final entries = await Future.wait(
        tasks.map((task) async {
          final results = await Future.wait([
            recipeProvider.loadType(task.doughRecipeId),
            recipeProvider.loadType(task.fillingRecipeId),
          ]);
          return MapEntry(task.id, '${results[0]} + ${results[1]}');
        }),
      );

      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _titles
          ..clear()
          ..addEntries(entries);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildTaskTile(Task task) {
    final createdAt = task.createdAt;
    final createdDate =
        '${createdAt.year.toString().padLeft(4, '0')}-'
        '${createdAt.month.toString().padLeft(2, '0')}-'
        '${createdAt.day.toString().padLeft(2, '0')}';

    return 
     
       Card(
        clipBehavior: Clip.none,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: () async {
                await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => TaskDetailsPage(taskId: task.id),
                  ),
                );
                await _loadTasks();
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: Text(
                      _titles[task.id] ?? '',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      textHeightBehavior: TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                    ),
                      const SizedBox(height: 6),
                      Row(
                        spacing: 4,
                        children: [
                          Flexible(
                            child: Chip(
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              label: Text(
                                '${task.quantity} pcs',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: -4,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Chip(
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              label: Text(
                                '${task.size} g',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                              backgroundColor: Colors.grey.shade200,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: -4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Divider(color: AppColors.borderLight, height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          createdDate,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Icon(
                          task.isCompleted == true
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: task.isCompleted == true
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                  
                ),
              ),
            ),
          ],
              ),
      );
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('tasks', lang)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _tasks.isEmpty
          ? Center(child: Text(AppStrings.get('noTasks', lang)))
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: _tasks.length,
                itemBuilder: (_, index) => _buildTaskTile(_tasks[index]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.of(context).popUntil((route) => route.isFirst);
          await _loadTasks();
        },
        tooltip: AppStrings.get('saveTask', lang),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
    );
  }
}
