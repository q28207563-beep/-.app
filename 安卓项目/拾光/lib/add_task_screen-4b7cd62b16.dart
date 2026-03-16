import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_time_tracker/models/task.dart';
import 'package:my_time_tracker/providers/task_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  int _priority = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加任务'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '任务标题',
                  hintText: '请输入任务标题',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入任务标题';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '任务描述',
                  hintText: '请输入任务描述（可选）',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _dueDate != null
                      ? DateFormat('yyyy年MM月dd日 HH:mm').format(_dueDate!)
                      : '设置截止日期',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _showDatePicker,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('优先级'),
                trailing: DropdownButton<int>(
                  value: _priority,
                  items: const [
                    DropdownMenuItem(
                      value: 0,
                      child: Text('普通'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('重要'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('紧急'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _priority = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text('保存任务'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      Task task = Task(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        dueDate: _dueDate,
        priority: _priority,
        completed: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Provider.of<TaskProvider>(context, listen: false).addTask(task);
      Navigator.pop(context);
    }
  }
}