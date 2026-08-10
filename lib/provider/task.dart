import 'package:flutter/material.dart';
import '../data/model/task.dart';
import '../data/repository/task.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository repository;
  TaskProvider(this.repository);


  Future<List<Task>> loadAllTasks() async {
    List<Task> result = await repository.loadAll();
    notifyListeners();
    return result;
  }

  Future<Task?> loadTask(String id) async {  
    Task? result = await repository.load(id);    
    notifyListeners(); 
    return result;

  }

  Future<void> insertTask(Task task) async {
    await repository.insert(task);  
    await loadTask(task.id); 
  }

  Future<void> deleteTask(String id) async {
     await repository.delete(id);
     await loadTask(id); 
   
  }

  Future<void> updateTask(Task task) async {
    await repository.update(task);   
    await loadTask(task.id);     
  }

}