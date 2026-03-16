class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int priority;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 0,
    this.completed = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // 从Map转换为Task对象
  Task.fromMap(Map<String, dynamic> map) :
    id = map['id'],
    title = map['title'],
    description = map['description'],
    dueDate = map['due_date'] != null ? DateTime.fromMillisecondsSinceEpoch(map['due_date']) : null,
    priority = map['priority'] ?? 0,
    completed = map['completed'] == 1,
    createdAt = DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updated_at']);

  // 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate?.millisecondsSinceEpoch,
      'priority': priority,
      'completed': completed ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  // 复制对象
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}