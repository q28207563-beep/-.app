import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:my_time_tracker/models/task.dart';
import 'package:my_time_tracker/providers/task_provider.dart';
import 'package:my_time_tracker/widgets/task_item.dart';
import 'package:my_time_tracker/screens/add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _filter = 'all'; // all, active, completed

  @override
  void initState() {
    super.initState();
    Provider.of<TaskProvider>(context, listen: false).loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterButtons(),
          Expanded(
            child: _buildTaskList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTaskScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('yyyy年MM月dd日').format(DateTime.now()),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '我的任务',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildFilterButton('全部', 'all'),
        _buildFilterButton('进行中', 'active'),
        _buildFilterButton('已完成', 'completed'),
      ],
    );
  }

  Widget _buildFilterButton(String text, String filter) {
    return ElevatedButton(
      onPressed: () => setState(() => _filter = filter),
      style: ElevatedButton.styleFrom(
        backgroundColor: _filter == filter ? Colors.blue : Colors.grey[200],
        foregroundColor: _filter == filter ? Colors.white : Colors.black,
      ),
      child: Text(text),
    );
  }

  Widget _buildTaskList() {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        List<Task> filteredTasks = _filterTasks(provider.tasks);
        
        if (filteredTasks.isEmpty) {
          return const Center(
            child: Text('暂无任务'),
          );
        }

        return ListView.builder(
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            Task task = filteredTasks[index];
            return TaskItem(task: task);
          },
        );
      },
    );
  }

  List<Task> _filterTasks(List<Task> tasks) {
    switch (_filter) {
      case 'active':
        return tasks.where((task) => !task.completed).toList();
      case 'completed':
        return tasks.where((task) => task.completed).toList();
      default:
        return tasks;
    }
  }

  void _navigateToAddTaskScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );
    Provider.of<TaskProvider>(context, listen: false).loadTasks();
  }
}