class Habit {
  final String id;
  final String title;
  final String? description;
  final String frequency; // daily, weekly, monthly
  final DateTime startDate;
  final int color;

  Habit({
    required this.id,
    required this.title,
    this.description,
    required this.frequency,
    required this.startDate,
    this.color = 0xFF42A5F5,
  });

  // 从Map转换为Habit对象
  Habit.fromMap(Map<String, dynamic> map) :
    id = map['id'],
    title = map['title'],
    description = map['description'],
    frequency = map['frequency'],
    startDate = DateTime.fromMillisecondsSinceEpoch(map['start_date']),
    color = map['color'] ?? 0xFF42A5F5;

  // 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'frequency': frequency,
      'start_date': startDate.millisecondsSinceEpoch,
      'color': color,
    };
  }

  // 复制对象
  Habit copyWith({
    String? id,
    String? title,
    String? description,
    String? frequency,
    DateTime? startDate,
    int? color,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      color: color ?? this.color,
    );
  }

  // 计算已坚持天数
  int get streakDays {
    final now = DateTime.now();
    final difference = now.difference(startDate);
    return difference.inDays;
  }

  // 计算完成率
  double get completionRate {
    // 需要结合habit_completions表的数据
    // 这里暂时返回0.0，实际实现时需要查询数据库
    return 0.0;
  }
}