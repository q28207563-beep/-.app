import 'package:flutter/material.dart';
import 'package:my_time_tracker/database/database_helper.dart';
import 'package:my_time_tracker/models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  // 加载所有任务
  Future<void> loadTasks() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    
    _tasks = List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
    
    // 按优先级和创建时间排序
    _tasks.sort((a, b) {
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    
    notifyListeners();
  }

  // 添加任务
  Future<void> addTask(Task task) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('tasks', task.toMap());
    _tasks.add(task);
    notifyListeners();
  }

  // 更新任务
  Future<void> updateTask(Task task) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  // 删除任务
  Future<void> deleteTask(String taskId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );
    
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  // 获取进行中的任务数
  int get activeTaskCount {
    return _tasks.where((task) => !task.completed).length;
  }

  // 获取已完成的任务数
  int get completedTaskCount {
    return _tasks.where((task) => task.completed).length;
  }

  // 按日期筛选任务
  List<Task> getTasksByDate(DateTime date) {
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == date.year &&
             task.dueDate!.month == date.month &&
             task.dueDate!.day == date.day;
    }).toList();
  }

  // 按优先级筛选任务
  List<Task> getTasksByPriority(int priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  // 按状态筛选任务
  List<Task> getTasksByStatus(bool completed) {
    return _tasks.where((task) => task.completed == completed).toList();
  }

  // 标记所有任务为已完成
  Future<void> markAllTasksAsCompleted() async {
    final db = await DatabaseHelper.instance.database;
    
    for (var task in _tasks) {
      if (!task.completed) {
        Task updatedTask = task.copyWith(
          completed: true,
          updatedAt: DateTime.now(),
        );
        await db.update(
          'tasks',
          updatedTask.toMap(),
          where: 'id = ?',
          whereArgs: [task.id],
        );
        _tasks[_tasks.indexOf(task)] = updatedTask;
      }
    }
    
    notifyListeners();
  }

  // 清除已完成的任务
  Future<void> clearCompletedTasks() async {
    final db = await DatabaseHelper.instance.database;
    
    for (var task in _tasks) {
      if (task.completed) {
        await db.delete(
          'tasks',
          where: 'id = ?',
          whereArgs: [task.id],
        );
      }
    }
    
    _tasks.removeWhere((task) => task.completed);
    notifyListeners();
  }
}