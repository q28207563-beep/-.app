import 'package:flutter/material.dart';
import 'package:my_time_tracker/database/database_helper.dart';
import 'package:my_time_tracker/models/pomodoro.dart';
import 'package:uuid/uuid.dart';

class PomodoroProvider with ChangeNotifier {
  List<Pomodoro> _pomodoros = [];
  PomodoroMode _currentMode = PomodoroMode.focus;
  int _focusDuration = 25; // 专注时长（分钟）
  int _breakDuration = 5; // 休息时长（分钟）
  int _currentMinutes = 25;
  int _currentSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;

  List<Pomodoro> get pomodoros => _pomodoros;
  PomodoroMode get currentMode => _currentMode;
  bool get isRunning => _isRunning;
  String get currentTime {
    return '${_currentMinutes.toString().padLeft(2, '0')}:${_currentSeconds.toString().padLeft(2, '0')}';
  }

  // 加载所有番茄专注记录
  Future<void> loadPomodoros() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('pomodoros');
    
    _pomodoros = List.generate(maps.length, (i) {
      return Pomodoro.fromMap(maps[i]);
    });
    
    // 按创建时间排序
    _pomodoros.sort((a, b) => b.startTime.compareTo(a.startTime));
    
    notifyListeners();
  }

  // 添加番茄专注记录
  Future<void> addPomodoro(Pomodoro pomodoro) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('pomodoros', pomodoro.toMap());
    _pomodoros.add(pomodoro);
    notifyListeners();
  }

  // 更新番茄专注记录
  Future<void> updatePomodoro(Pomodoro pomodoro) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'pomodoros',
      pomodoro.toMap(),
      where: 'id = ?',
      whereArgs: [pomodoro.id],
    );
    
    final index = _pomodoros.indexWhere((p) => p.id == pomodoro.id);
    if (index != -1) {
      _pomodoros[index] = pomodoro;
      notifyListeners();
    }
  }

  // 删除番茄专注记录
  Future<void> deletePomodoro(String pomodoroId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'pomodoros',
      where: 'id = ?',
      whereArgs: [pomodoroId],
    );
    
    _pomodoros.removeWhere((pomodoro) => pomodoro.id == pomodoroId);
    notifyListeners();
  }

  // 开始计时器
  void startTimer() {
    if (_isRunning) return;
    
    _isRunning = true;
    
    // 创建新的番茄专注记录
    final pomodoro = Pomodoro(
      id: const Uuid().v4(),
      startTime: DateTime.now(),
      duration: _currentMode == PomodoroMode.focus ? _focusDuration : _breakDuration,
    );
    addPomodoro(pomodoro);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSeconds == 0) {
        if (_currentMinutes == 0) {
          // 时间到，切换模式
          _timer?.cancel();
          _isRunning = false;
          _switchMode();
        } else {
          _currentMinutes--;
          _currentSeconds = 59;
        }
      } else {
        _currentSeconds--;
      }
      notifyListeners();
    });
    
    notifyListeners();
  }

  // 暂停计时器
  void pauseTimer() {
    if (!_isRunning) return;
    
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  // 重置计时器
  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _currentMinutes = _currentMode == PomodoroMode.focus ? _focusDuration : _breakDuration;
    _currentSeconds = 0;
    notifyListeners();
  }

  // 切换模式
  void _switchMode() {
    _currentMode = _currentMode == PomodoroMode.focus ? PomodoroMode.breakTime : PomodoroMode.focus;
    _currentMinutes = _currentMode == PomodoroMode.focus ? _focusDuration : _breakDuration;
    _currentSeconds = 0;
    notifyListeners();
  }

  // 获取今日专注时长（分钟）
  int get todayFocusMinutes {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int totalMinutes = 0;
    for (var pomodoro in _pomodoros) {
      if (pomodoro.isToday && pomodoro.completed) {
        totalMinutes += pomodoro.focusMinutes;
      }
    }
    
    return totalMinutes;
  }

  // 获取本周专注时长（分钟）
  int get weekFocusMinutes {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    int totalMinutes = 0;
    for (var pomodoro in _pomodoros) {
      if (pomodoro.startTime.isAfter(weekStart) && pomodoro.completed) {
        totalMinutes += pomodoro.focusMinutes;
      }
    }
    
    return totalMinutes;
  }

  // 获取本月专注时长（分钟）
  int get monthFocusMinutes {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    int totalMinutes = 0;
    for (var pomodoro in _pomodoros) {
      if (pomodoro.startTime.isAfter(monthStart) && pomodoro.completed) {
        totalMinutes += pomodoro.focusMinutes;
      }
    }
    
    return totalMinutes;
  }

  // 设置专注时长
  void setFocusDuration(int minutes) {
    _focusDuration = minutes;
    if (_currentMode == PomodoroMode.focus && !_isRunning) {
      _currentMinutes = minutes;
      _currentSeconds = 0;
    }
    notifyListeners();
  }

  // 设置休息时长
  void setBreakDuration(int minutes) {
    _breakDuration = minutes;
    if (_currentMode == PomodoroMode.breakTime && !_isRunning) {
      _currentMinutes = minutes;
      _currentSeconds = 0;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}