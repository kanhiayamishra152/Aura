import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;
  final Uuid _uuid = const Uuid();

  List<TaskModel> _tasks =[];
  bool _isLoading = false;

  TaskProvider(this._taskService) {
    _loadTasks();
  }

  List<TaskModel> get tasks => _tasks;
  List<TaskModel> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<TaskModel> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  bool get isLoading => _isLoading;

  Future<void> _loadTasks() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _taskService.getTasks();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(String title, {String? description}) async {
    if (title.trim().isEmpty) return;

    final newTask = TaskModel(
      id: _uuid.v4(),
      title: title.trim(),
      description: description?.trim(),
      createdAt: DateTime.now(),
    );

    // Optimistic UI update
    _tasks.insert(0, newTask);
    notifyListeners();

    final success = await _taskService.addTask(newTask);
    if (!success) {
      // Revert on failure
      _tasks.removeWhere((t) => t.id == newTask.id);
      notifyListeners();
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final task = _tasks[index];
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);

    // Optimistic UI update
    _tasks[index] = updatedTask;
    notifyListeners();

    final success = await _taskService.updateTask(updatedTask);
    if (!success) {
      // Revert
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> addTimeSpent(String id, int seconds) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final task = _tasks[index];
    final updatedTask = task.copyWith(timeSpentSeconds: task.timeSpentSeconds + seconds);

    _tasks[index] = updatedTask;
    notifyListeners();

    await _taskService.updateTask(updatedTask);
  }

  Future<void> deleteTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final taskToRemove = _tasks[index];
    
    // Optimistic UI update
    _tasks.removeAt(index);
    notifyListeners();

    final success = await _taskService.deleteTask(id);
    if (!success) {
      // Revert
      _tasks.insert(index, taskToRemove);
      notifyListeners();
    }
  }
}
