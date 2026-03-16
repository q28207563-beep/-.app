import 'package:flutter/material.dart';
import 'package:my_time_tracker/database/database_helper.dart';
import 'package:my_time_tracker/models/habit.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  // 加载所有习惯
  Future<void> loadHabits() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('habits');
    
    _habits = List.generate(maps.length, (i) {
      return Habit.fromMap(maps[i]);
    });
    
    // 按创建时间排序
    _habits.sort((a, b) => b.startDate.compareTo(a.startDate));
    
    notifyListeners();
  }

  // 添加习惯
  Future<void> addHabit(Habit habit) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('habits', habit.toMap());
    _habits.add(habit);
    notifyListeners();
  }

  // 更新习惯
  Future<void> updateHabit(Habit habit) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
    
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      notifyListeners();
    }
  }

  // 删除习惯
  Future<void> deleteHabit(String habitId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [habitId],
    );
    
    _habits.removeWhere((habit) => habit.id == habitId);
    notifyListeners();
  }

  // 习惯打卡
  Future<void> toggleHabitCompletion(String habitId) async {
    final db = await DatabaseHelper.instance.database;
    
    // 检查今天是否已经打卡
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final List<Map<String, dynamic>> results = await db.query(
      'habit_completions',
      where: 'habit_id = ? AND completed_date >= ?',
      whereArgs: [habitId, today.millisecondsSinceEpoch],
    );
    
    if (results.isNotEmpty) {
      // 今天已经打卡，取消打卡
      await db.delete(
        'habit_completions',
        where: 'id = ?',
        whereArgs: [results.first['id']],
      );
    } else {
      // 今天未打卡，添加打卡记录
      await db.insert(
        'habit_completions',
        {
          'id': const Uuid().v4(),
          'habit_id': habitId,
          'completed_date': now.millisecondsSinceEpoch,
        },
      );
    }
    
    notifyListeners();
  }

  // 获取已完成的习惯数
  int get completedHabitsCount {
    // 需要结合habit_completions表的数据
    // 这里暂时返回0，实际实现时需要查询数据库
    return 0;
  }

  // 获取习惯的连续打卡天数
  Future<int> getHabitStreak(String habitId) async {
    final db = await DatabaseHelper.instance.database;
    
    // 查询该习惯的所有打卡记录
    final List<Map<String, dynamic>> results = await db.query(
      'habit_completions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'completed_date DESC',
    );
    
    if (results.isEmpty) return 0;
    
    // 计算连续打卡天数
    int streak = 0;
    final now = DateTime.now();
    DateTime currentDate = DateTime(now.year, now.month, now.day);
    
    for (var result in results) {
      final completedDate = DateTime.fromMillisecondsSinceEpoch(result['completed_date']);
      final date = DateTime(completedDate.year, completedDate.month, completedDate.day);
      
      if (date == currentDate) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(currentDate)) {
        break;
      }
    }
    
    return streak;
  }

  // 获取习惯的完成率
  Future<double> getHabitCompletionRate(String habitId) async {
    final db = await DatabaseHelper.instance.database;
    
    // 查询该习惯的所有打卡记录
    final List<Map<String, dynamic>> results = await db.query(
      'habit_completions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
    
    // 查询习惯信息
    final habit = _habits.firstWhere((h) => h.id == habitId);
    final totalDays = DateTime.now().difference(habit.startDate).inDays;
    
    if (totalDays == 0) return 0.0;
    
    return results.length / totalDays;
  }
}