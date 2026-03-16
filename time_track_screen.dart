import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_time_tracker/providers/time_track_provider.dart';
import 'package:my_time_tracker/screens/add_time_track_screen.dart';

class TimeTrackScreen extends StatefulWidget {
  const TimeTrackScreen({super.key});

  @override
  State<TimeTrackScreen> createState() => _TimeTrackScreenState();
}

class _TimeTrackScreenState extends State<TimeTrackScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<TimeTrackProvider>(context, listen: false).loadTimeTracks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildTimeTracksList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTimeTrackScreen(),
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
          const Text(
            '时光足迹',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Consumer<TimeTrackProvider>(
            builder: (context, provider, child) {
              return Text(
                '今日已记录 ${provider.todayTrackedMinutes} 分钟',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTracksList() {
    return Consumer<TimeTrackProvider>(
      builder: (context, provider, child) {
        if (provider.timeTracks.isEmpty) {
          return const Center(
            child: Text('暂无时光足迹'),
          );
        }

        return ListView.builder(
          itemCount: provider.timeTracks.length,
          itemBuilder: (context, index) {
            final timeTrack = provider.timeTracks[index];
            return TimeTrackItem(timeTrack: timeTrack);
          },
        );
      },
    );
  }

  void _navigateToAddTimeTrackScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTimeTrackScreen()),
    );
    Provider.of<TimeTrackProvider>(context, listen: false).loadTimeTracks();
  }
}

class TimeTrackItem extends StatelessWidget {
  final TimeTrack timeTrack;

  const TimeTrackItem({super.key, required this.timeTrack});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getCategoryColor(timeTrack.category),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(_getCategoryIcon(timeTrack.category), color: Colors.white),
      ),
      title: Text(timeTrack.activity),
      subtitle: Text(_buildSubtitle()),
      trailing: Text('${timeTrack.duration} 分钟'),
      onTap: () => _navigateToEditTimeTrackScreen(context),
    );
  }

  String _buildSubtitle() {
    final startDate = DateTime.fromMillisecondsSinceEpoch(timeTrack.startTime);
    return '${startDate.year}年${startDate.month}月${startDate.day}日 ${startDate.hour}:${startDate.minute}';
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case '学习':
        return Colors.blue;
      case '工作':
        return Colors.green;
      case '运动':
        return Colors.red;
      case '娱乐':
        return Colors.orange;
      case '休息':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case '学习':
        return Icons.book;
      case '工作':
        return Icons.work;
      case '运动':
        return Icons.fitness_center;
      case '娱乐':
        return Icons.movie;
      case '休息':
        return Icons.bed;
      default:
        return Icons.timelapse;
    }
  }

  void _navigateToEditTimeTrackScreen(BuildContext context) {
    // 导航到编辑时光足迹屏幕
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => EditTimeTrackScreen(timeTrack: timeTrack),
    //   ),
    // );
  }
}