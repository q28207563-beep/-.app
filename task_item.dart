import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:my_time_tracker/models/task.dart';
import 'package:my_time_tracker/providers/task_provider.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _deleteTask(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '删除',
          ),
        ],
      ),
      child: ListTile(
        leading: _buildPriorityIndicator(),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
            fontSize: 16,
          ),
        ),
        subtitle: _buildSubtitle(),
        trailing: Checkbox(
          value: task.completed,
          onChanged: (value) => _toggleTaskCompletion(context),
        ),
        onTap: () => _navigateToEditTaskScreen(context),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    Color color;
    switch (task.priority) {
      case 0:
        color = Colors.grey;
        break;
      case 1:
        color = Colors.blue;
        break;
      case 2:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget? _buildSubtitle() {
    List<Widget> subtitleParts = [];

    if (task.description != null && task.description!.isNotEmpty) {
      subtitleParts.add(
        Text(
          task.description!,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    if (task.dueDate != null) {
      subtitleParts.add(
        Text(
          DateFormat('MM-dd HH:mm').format(task.dueDate!),
          style: TextStyle(
            fontSize: 14,
            color: _getDueDateColor(),
          ),
        ),
      );
    }

    if (subtitleParts.isEmpty) {
      return null;
    }

    return Row(
      children: subtitleParts.map((part) {
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: part,
        );
      }).toList(),
    );
  }

  Color _getDueDateColor() {
    if (task.dueDate == null) return Colors.grey;
    
    final now = DateTime.now();
    final difference = task.dueDate!.difference(now);
    
    if (difference.isNegative) {
      return Colors.red; // 已过期
    } else if (difference.inHours < 24) {
      return Colors.orange; // 24小时内到期
    } else {
      return Colors.grey; // 正常
    }
  }

  void _toggleTaskCompletion(BuildContext context) {
    Task updatedTask = task.copyWith(
      completed: !task.completed,
      updatedAt: DateTime.now(),
    );
    Provider.of<TaskProvider>(context, listen: false).updateTask(updatedTask);
  }

  void _deleteTask(BuildContext context) {
    Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
  }

  void _navigateToEditTaskScreen(BuildContext context) {
    // 导航到编辑任务屏幕
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => EditTaskScreen(task: task),
    //   ),
    // );
  }
}