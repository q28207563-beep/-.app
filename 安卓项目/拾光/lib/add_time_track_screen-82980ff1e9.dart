import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_time_tracker/models/time_track.dart';
import 'package:my_time_tracker/providers/time_track_provider.dart';
import 'package:uuid/uuid.dart';

class AddTimeTrackScreen extends StatefulWidget {
  const AddTimeTrackScreen({super.key});

  @override
  State<AddTimeTrackScreen> createState() => _AddTimeTrackScreenState();
}

class _AddTimeTrackScreenState extends State<AddTimeTrackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _activityController = TextEditingController();
  String? _category;
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void dispose() {
    _activityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加时光足迹'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _activityController,
                decoration: const InputDecoration(
                  labelText: '活动名称',
                  hintText: '请输入活动名称',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入活动名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('类别'),
                trailing: DropdownButton<String>(
                  value: _category,
                  hint: const Text('选择类别'),
                  items: const [
                    DropdownMenuItem(
                      value: '学习',
                      child: Text('学习'),
                    ),
                    DropdownMenuItem(
                      value: '工作',
                      child: Text('工作'),
                    ),
                    DropdownMenuItem(
                      value: '运动',
                      child: Text('运动'),
                    ),
                    DropdownMenuItem(
                      value: '娱乐',
                      child: Text('娱乐'),
                    ),
                    DropdownMenuItem(
                      value: '休息',
                      child: Text('休息'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _category = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _startTime != null
                      ? '开始时间: ${_formatDateTime(_startTime!)}'
                      : '设置开始时间',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _showDateTimePicker(true),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _endTime != null
                      ? '结束时间: ${_formatDateTime(_endTime!)}'
                      : '设置结束时间',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _showDateTimePicker(false),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTimeTrack,
                child: const Text('保存时光足迹'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour}:${dateTime.minute}';
  }

  void _showDateTimePicker(bool isStartTime) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          final dateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStartTime) {
            _startTime = dateTime;
          } else {
            _endTime = dateTime;
          }
        });
      }
    }
  }

  void _saveTimeTrack() {
    if (_formKey.currentState!.validate()) {
      if (_startTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请设置开始时间')),
        );
        return;
      }

      if (_endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请设置结束时间')),
        );
        return;
      }

      if (_endTime!.isBefore(_startTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('结束时间不能早于开始时间')),
        );
        return;
      }

      final duration = ((_endTime!.millisecondsSinceEpoch - _startTime!.millisecondsSinceEpoch) / 1000 / 60).round();

      TimeTrack timeTrack = TimeTrack(
        id: const Uuid().v4(),
        activity: _activityController.text,
        startTime: _startTime!.millisecondsSinceEpoch,
        endTime: _endTime!.millisecondsSinceEpoch,
        duration: duration,
        category: _category,
      );

      Provider.of<TimeTrackProvider>(context, listen: false).addTimeTrack(timeTrack);
      Navigator.pop(context);
    }
  }
}