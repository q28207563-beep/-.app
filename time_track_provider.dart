import 'package:flutter/material.dart';
import 'package:my_time_tracker/database/database_helper.dart';
import 'package:my_time_tracker/models/time_track.dart';
import 'package:uuid/uuid.dart';

class TimeTrackProvider with ChangeNotifier {
  List<TimeTrack> _timeTracks = [];

  List<TimeTrack> get timeTracks => _timeTracks;

  // 加载所有时光足迹记录
  Future<void> loadTimeTracks() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('time_tracks');
    
    _timeTracks = List.generate(maps.length, (i) {
      return TimeTrack.fromMap(maps[i]);
    });
    
    // 按创建时间排序
    _timeTracks.sort((a, b) => b.startTime.compareTo(a.startTime));
    
    notifyListeners();
  }

  // 添加时光足迹记录
  Future<void> addTimeTrack(TimeTrack timeTrack) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('time_tracks', timeTrack.toMap());
    _timeTracks.add(timeTrack);
    notifyListeners();
  }

  // 更新时光足迹记录
  Future<void> updateTimeTrack(TimeTrack timeTrack) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'time_tracks',
      timeTrack.toMap(),
      where: 'id = ?',
      whereArgs: [timeTrack.id],
    );
    
    final index = _timeTracks.indexWhere((t) => t.id == timeTrack.id);
    if (index != -1) {
      _timeTracks[index] = timeTrack;
      notifyListeners();
    }
  }

  // 删除时光足迹记录
  Future<void> deleteTimeTrack(String timeTrackId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'time_tracks',
      where: 'id = ?',
      whereArgs: [timeTrackId],
    );
    
    _timeTracks.removeWhere((timeTrack) => timeTrack.id == timeTrackId);
    notifyListeners();
  }

  // 开始计时
  Future<void> startTracking(String activity, String? category) async {
    final timeTrack = TimeTrack(
      id: const Uuid().v4(),
      activity: activity,
      startTime: DateTime.now().millisecondsSinceEpoch,
      category: category,
    );
    await addTimeTrack(timeTrack);
  }

  // 结束计时
  Future<void> stopTracking(String timeTrackId) async {
    final index = _timeTracks.indexWhere((t) => t.id == timeTrackId);
    if (index != -1) {
      final timeTrack = _timeTracks[index];
      final now = DateTime.now().millisecondsSinceEpoch;
      final duration = ((now - timeTrack.startTime) / 1000 / 60).round();
      
      final updatedTimeTrack = timeTrack.copyWith(
        endTime: now,
        duration: duration,
      );
      
      await updateTimeTrack(updatedTimeTrack);
    }
  }

  // 获取今日记录时长（分钟）
  int get todayTrackedMinutes {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int totalMinutes = 0;
    for (var timeTrack in _timeTracks) {
      if (timeTrack.isToday) {
        totalMinutes += timeTrack.durationMinutes;
      }
    }
    
    return totalMinutes;
  }

  // 获取本周记录时长（分钟）
  int get weekTrackedMinutes {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - now.weekday + 1);
    
    int totalMinutes = 0;
    for (var timeTrack in _timeTracks) {
      if (timeTrack.isThisWeek) {
        totalMinutes += timeTrack.durationMinutes;
      }
    }
    
    return totalMinutes;
  }

  // 获取本月记录时长（分钟）
  int get monthTrackedMinutes {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    int totalMinutes = 0;
    for (var timeTrack in _timeTracks) {
      if (timeTrack.isThisMonth) {
        totalMinutes += timeTrack.durationMinutes;
      }
    }
    
    return totalMinutes;
  }

  // 按类别筛选时光足迹
  List<TimeTrack> getTimeTracksByCategory(String category) {
    return _timeTracks.where((timeTrack) => timeTrack.category == category).toList();
  }

  // 按日期筛选时光足迹
  List<TimeTrack> getTimeTracksByDate(DateTime date) {
    return _timeTracks.where((timeTrack) {
      final trackDate = DateTime.fromMillisecondsSinceEpoch(timeTrack.startTime);
      return trackDate.year == date.year &&
             trackDate.month == date.month &&
             trackDate.day == date.day;
    }).toList();
  }

  // 获取时间分布统计
  Map<String, int> getTimeDistribution() {
    Map<String, int> distribution = {};
    
    for (var timeTrack in _timeTracks) {
      final category = timeTrack.category ?? '其他';
      if (distribution.containsKey(category)) {
        distribution[category] = distribution[category]! + timeTrack.durationMinutes;
      } else {
        distribution[category] = timeTrack.durationMinutes;
      }
    }
    
    return distribution;
  }
}