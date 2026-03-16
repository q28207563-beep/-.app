import 'package:flutter/material.dart';
import 'package:my_time_tracker/database/database_helper.dart';

enum PomodoroMode {
  focus,
  breakTime,
}

class Pomodoro {
  final String id;
  final String? taskId;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration;
  final bool completed;

  Pomodoro({
    required this.id,
    this.taskId,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.completed = false,
  });

  // 从Map转换为Pomodoro对象
  Pomodoro.fromMap(Map<String, dynamic> map) :
    id = map['id'],
    taskId = map['task_id'],
    startTime = DateTime.fromMillisecondsSinceEpoch(map['start_time']),
    endTime = map['end_time'] != null ? DateTime.fromMillisecondsSinceEpoch(map['end_time']) : null,
    duration = map['duration'],
    completed = map['completed'] == 1;

  // 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'duration': duration,
      'completed': completed ? 1 : 0,
    };
  }

  // 复制对象
  Pomodoro copyWith({
    String? id,
    String? taskId,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    bool? completed,
  }) {
    return Pomodoro(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      completed: completed ?? this.completed,
    );
  }

  // 计算专注时长（分钟）
  int get focusMinutes {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMinutes;
  }

  // 判断是否是今天的番茄专注
  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
           startTime.month == now.month &&
           startTime.day == now.day;
  }
}