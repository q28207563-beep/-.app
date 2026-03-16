import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_time_tracker/models/habit.dart';
import 'package:my_time_tracker/providers/habit_provider.dart';
import 'package:uuid/uuid.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _frequency = 'daily';
  int _color = 0xFF42A5F5;

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
        title: const Text('添加习惯'),
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
                  labelText: '习惯名称',
                  hintText: '请输入习惯名称',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入习惯名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '习惯描述',
                  hintText: '请输入习惯描述（可选）',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('频率'),
                trailing: DropdownButton<String>(
                  value: _frequency,
                  items: const [
                    DropdownMenuItem(
                      value: 'daily',
                      child: Text('每天'),
                    ),
                    DropdownMenuItem(
                      value: 'weekly',
                      child: Text('每周'),
                    ),
                    DropdownMenuItem(
                      value: 'monthly',
                      child: Text('每月'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _frequency = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('颜色'),
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(_color),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onTap: _showColorPicker,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveHabit,
                child: const Text('保存习惯'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker() async {
    Color? pickedColor = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择颜色'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: Color(_color),
            onColorChanged: (color) {
              setState(() {
                _color = color.value;
              });
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (pickedColor != null) {
      setState(() {
        _color = pickedColor.value;
      });
    }
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      Habit habit = Habit(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        frequency: _frequency,
        startDate: DateTime.now(),
        color: _color,
      );

      Provider.of<HabitProvider>(context, listen: false).addHabit(habit);
      Navigator.pop(context);
    }
  }
}