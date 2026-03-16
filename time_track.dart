class TimeTrack {
  final String id;
  final String activity;
  final int startTime;
  final int? endTime;
  final int? duration;
  final String? category;

  TimeTrack({
    required this.id,
    required this.activity,
    required this.startTime,
    this.endTime,
    this.duration,
    this.category,
  });

  // 从Map转换为TimeTrack对象
  TimeTrack.fromMap(Map<String, dynamic> map) :
    id = map['id'],
    activity = map['activity'],
    startTime = map['start_time'],
    endTime = map['end_time'],
    duration = map['duration'],
    category = map['category'];

  // 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activity': activity,
      'start_time': startTime,
      'end_time': endTime,
      'duration': duration,
      'category': category,
    };
  }

  // 复制对象
  TimeTrack copyWith({
    String? id,
    String? activity,
    int? startTime,
    int? endTime,
    int? duration,
    String? category,
  }) {
    return TimeTrack(
      id: id ?? this.id,
      activity: activity ?? this.activity,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      category: category ?? this.category,
    );
  }

  // 计算时长（分钟）
  int get durationMinutes {
    if (duration != null) return duration!;
    if (endTime != null) {
      return ((endTime! - startTime) / 1000 / 60).round();
    }
    return 0;
  }

  // 判断是否是今天的时光足迹
  bool get isToday {
    final now = DateTime.now();
    final trackDate = DateTime.fromMillisecondsSinceEpoch(startTime);
    return trackDate.year == now.year &&
           trackDate.month == now.month &&
           trackDate.day == now.day;
  }

  // 判断是否是本周的时光足迹
  bool get isThisWeek {
    final now = DateTime.now();
    final trackDate = DateTime.fromMillisecondsSinceEpoch(startTime);
    final weekStart = DateTime(now.year, now.month, now.day - now.weekday + 1);
    return trackDate.isAfter(weekStart);
  }

  // 判断是否是本月的时光足迹
  bool get isThisMonth {
    final now = DateTime.now();
    final trackDate = DateTime.fromMillisecondsSinceEpoch(startTime);
    return trackDate.year == now.year &&
           trackDate.month == now.month;
  }
}