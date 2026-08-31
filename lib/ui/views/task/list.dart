import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/task.dart';
import '../../../provider/recipe.dart';
import '../../../provider/type.dart';
import '../../../data/model/task.dart';
import '../../../data/model/type.dart' as mc;

import '../../core/nav_bottom.dart';
import '../../utils/app_strings.dart';
import '../../utils/seeds_strings.dart';
import '../../utils/language_provider.dart';
import '../../core/app_theme.dart';
import 'details.dart';
import '../../widgets/info_chips.dart';

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
  // taskId -> dough/filling type id, used for filtering
  final Map<String, String?> _doughTypeIds = {};
  final Map<String, String?> _fillingTypeIds = {};
  List<mc.Type> _doughTypes = [];
  List<mc.Type> _fillingTypes = [];
  String? _selectedDoughTypeId;
  String? _selectedFillingTypeId;

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
      final typeProvider = context.read<TypeProvider>();
      var tasks = await context.read<TaskProvider>().loadAllTasks();

      final recipeId = widget.recipeId;
      if (recipeId != null && recipeId.isNotEmpty) {
        tasks = tasks
            .where(
              (task) =>
                  task.doughRecipeId == recipeId ||
                  task.fillingRecipeId == recipeId,
            )
            .toList();
      }

      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final allTypes = await typeProvider.loadAllTypes();
      final typesById = {for (final type in allTypes) type.id: type};
      final doughTypes = allTypes
          .where((type) => type.category == mc.Category.dough)
          .toList();
      final fillingTypes = allTypes
          .where((type) => type.category == mc.Category.filling)
          .toList();

      final doughTypeIds = <String, String?>{};
      final fillingTypeIds = <String, String?>{};
      final entries = await Future.wait(
        tasks.map((task) async {
          final results = await Future.wait([
            recipeProvider.loadRecipe(task.doughRecipeId),
            recipeProvider.loadRecipe(task.fillingRecipeId),
          ]);
          final doughType = typesById[results[0]?.typeId];
          final fillingType = typesById[results[1]?.typeId];
          doughTypeIds[task.id] = doughType?.id;
          fillingTypeIds[task.id] = fillingType?.id;
          return MapEntry(
            task.id,
            '${SeedsStrings.get(doughType?.name ?? '', lang).isNotEmpty ? SeedsStrings.get(doughType?.name ?? '', lang) : doughType?.name ?? ''} + ${SeedsStrings.get(fillingType?.name ?? '', lang).isNotEmpty ? SeedsStrings.get(fillingType?.name ?? '', lang) : fillingType?.name ?? ''}',
           // '${doughType?.name ?? ''} + ${fillingType?.name ?? ''}',
          );
        }),
      );

      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _titles
          ..clear()
          ..addEntries(entries);
        _doughTypeIds
          ..clear()
          ..addAll(doughTypeIds);
        _fillingTypeIds
          ..clear()
          ..addAll(fillingTypeIds);
        _doughTypes = doughTypes;
        _fillingTypes = fillingTypes;
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

  List<Task> get _filteredTasks => _tasks.where((task) {
    if (_selectedDoughTypeId != null &&
        _doughTypeIds[task.id] != _selectedDoughTypeId) {
      return false;
    }
    if (_selectedFillingTypeId != null &&
        _fillingTypeIds[task.id] != _selectedFillingTypeId) {
      return false;
    }
    return true;
  }).toList();

  Widget _buildTypeFilter({
    required String label,
    required List<mc.Type> types,
    required String? selectedTypeId,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String?>(
      initialValue: selectedTypeId,
      isExpanded: true,
      style: Theme.of(context).textTheme.bodySmall,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodySmall,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      ),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(AppStrings.get('all', lang)),
        ),
        ...types.map(
          (type) => DropdownMenuItem<String?>(
            value: type.id,
            child: Text(SeedsStrings.get(type.name, lang).isNotEmpty ? SeedsStrings.get(type.name, lang) : type.name, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeFilter(
              label: AppStrings.get('dough_type', lang),
              types: _doughTypes,
              selectedTypeId: _selectedDoughTypeId,
              onChanged: (value) {
                setState(() {
                  _selectedDoughTypeId = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTypeFilter(
              label: AppStrings.get('filling_type', lang),
              types: _fillingTypes,
              selectedTypeId: _selectedFillingTypeId,
              onChanged: (value) {
                setState(() {
                  _selectedFillingTypeId = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(Task task) {
    final createdAt = task.createdAt;
    final createdDate =
        '${createdAt.year.toString().padLeft(4, '0')}-'
        '${createdAt.month.toString().padLeft(2, '0')}-'
        '${createdAt.day.toString().padLeft(2, '0')}';

    return Card(
      // clipBehavior: Clip.none,
      child: Stack(
        //   clipBehavior: Clip.none,
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
                  Divider(
                    color: AppColors.borderLight.withValues(alpha: 0.2),
                    height: 12,
                  ),
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
                  InfoChips(
                    qty: task.quantity,
                    size: task.size,
                   // ratio: Helper.ratioToString(task.ratio),
                 
                  ),

                  Divider(
                    color: AppColors.borderLight.withValues(alpha: 0.2),
                    height: 18,
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        final isSelected = (task.rating ?? 0) >= starValue;

                        return GestureDetector(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                            ), // ← tiny spacing
                            child: Icon(
                              isSelected
                                  ? Icons.sentiment_satisfied_rounded
                                  : Icons.sentiment_satisfied_outlined,
                              color: isSelected ? Colors.amber : Colors.grey,
                              size: 18, // ← adjust as needed
                            ),
                          ),
                        );
                      }),
                    ),
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
          : Column(
              children: [
                _buildFilterBar(),
                SizedBox(height: 8),
                Divider(color: AppColors.borderLight, height: 1),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/bg.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      _filteredTasks.isEmpty
                          ? Center(child: Text(AppStrings.get('noTasks', lang)))
                          : RefreshIndicator(
                              onRefresh: _loadTasks,
                              child: GridView.builder(
                                padding: const EdgeInsets.all(12),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      childAspectRatio: 0.9,
                                    ),
                                itemCount: _filteredTasks.length,
                                itemBuilder: (_, index) =>
                                    _buildTaskTile(_filteredTasks[index]),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
