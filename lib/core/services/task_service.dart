import 'dart:async';
import 'database_service.dart';
import '../models/task_model.dart';
import 'package:flutter/foundation.dart';

class TaskService {
  final DatabaseService _databaseService;
  static const String _tableName = 'tasks';

  TaskService(this._databaseService);

  Future<List<TaskModel>> getTasks() async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'createdAt DESC',
      );
      return maps.map((map) => TaskModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('TaskService getTasks Error: $e');
      return[];
    }
  }

  Future<bool> addTask(TaskModel task) async {
    try {
      final db = await _databaseService.database;
      await db.insert(_tableName, task.toMap());
      return true;
    } catch (e) {
      debugPrint('TaskService addTask Error: $e');
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    try {
      final db = await _databaseService.database;
      await db.update(
        _tableName,
        task.toMap(),
        where: 'id = ?',
        whereArgs:[task.id],
      );
      return true;
    } catch (e) {
      debugPrint('TaskService updateTask Error: $e');
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      final db = await _databaseService.database;
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      debugPrint('TaskService deleteTask Error: $e');
      return false;
    }
  }
}
