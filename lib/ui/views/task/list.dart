import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/database/db_helper.dart';
import '../../../data/model/task.dart';
import '../../../data/repository/task.dart';
import '../../../provider/task.dart';
import '../../core/nav_bottom.dart';
import '../../utils/app_strings.dart';
import '../../utils/helper.dart';
import '../../utils/language_provider.dart';
import 'add.dart';
import 'details.dart';

class TaskListPage extends StatelessWidget {
  final String? recipeId;
  const TaskListPage({super.key, this.recipeId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskProvider>(
      create: (_) => TaskProvider(TaskRepository(MCDatabase.instance)),
      child: const _TaskListView(),
    );
  }
}

class _TaskListView extends StatefulWidget {
  const _TaskListView({super.key});

  @override
  State<_TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<_TaskListView> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Task> _tasks = [];

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
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final tasks = await taskProvider.loadAllTasks();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTask(Task task) async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final lang = languageProvider.languageCode;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.get('delete_task', lang)),
        content: Text(
          AppStrings.get(
                'confirm_delete_task',
                lang,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppStrings.get('delete_task', lang),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.deleteTask(task.id);
    await _loadTasks();
  }

  Widget _buildTaskTile(Task task, String lang) {
    final subtitle = <String>[];
    final createdAt = task.createdAt;
    final createdDate =
        '${createdAt.year.toString().padLeft(4, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
    subtitle.add('${AppStrings.get('quantity', lang)}: ${task.quantity}');
    subtitle.add('${AppStrings.get('size', lang)}: ${task.size}');
    subtitle.add(
      '${AppStrings.get('ratio', lang)}: ${Helper.ratioToString(task.ratio)}',
    );
    subtitle.add('${AppStrings.get('created_at', lang)}: $createdDate');
    if (task.comment != null && task.comment!.isNotEmpty) {
      subtitle.add(task.comment!);
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      title: Text('Task ${task.id.substring(0, task.id.length.clamp(0, 8))}'),
      subtitle: Text(subtitle.join(' · ')),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.redAccent),
        onPressed: () => _deleteTask(task),
      ),
      leading: Icon(
        task.isCompleted == true ? Icons.check_circle : Icons.pending,
        color: task.isCompleted == true ? Colors.green : Colors.grey,
      ),
      onTap: () async {
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => TaskDetailsPage(taskId: task.id)),
        );
        await _loadTasks();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;

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
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _tasks.length,
                separatorBuilder: (context, index) => const Divider(height: 0),
                itemBuilder: (context, index) =>
                    _buildTaskTile(_tasks[index], lang),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push<bool>(MaterialPageRoute(builder: (_) => const AddTaskPage()));
          await _loadTasks();
        },
        tooltip: AppStrings.get('saveTask', lang),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
    );
  }
}
