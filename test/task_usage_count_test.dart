import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cake_app2/db/db_helper.dart';
import 'package:moon_cake_app2/db/task.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('counts tasks that use a recipe as dough or filling', () async {
    final service = MCService(databaseName: 'task_usage_count_test.db');

    await service.saveTask(
      Task(
        id: 'task-1',
        doughRecipeId: 'recipe-1',
        fillingRecipeId: 'recipe-2',
        size: 10,
        quantity: 1,
        ratio: 0.5,
        ingredients: [],
      ),
    );

    await service.saveTask(
      Task(
        id: 'task-2',
        doughRecipeId: 'recipe-1',
        fillingRecipeId: 'recipe-3',
        size: 10,
        quantity: 1,
        ratio: 0.5,
        ingredients: [],
      ),
    );

    await service.saveTask(
      Task(
        id: 'task-3',
        doughRecipeId: 'recipe-4',
        fillingRecipeId: 'recipe-2',
        size: 10,
        quantity: 1,
        ratio: 0.5,
        ingredients: [],
      ),
    );

    expect(await service.countTasksUsingRecipe('recipe-1'), 2);
    expect(await service.countTasksUsingRecipe('recipe-2'), 2);
    expect(await service.countTasksUsingRecipe('recipe-9'), 0);

    final tasksForRecipe1 = await service.loadTasksUsingRecipe('recipe-1');
    expect(tasksForRecipe1.map((task) => task.id).toList(), containsAll(['task-1', 'task-2']));
  });
}
