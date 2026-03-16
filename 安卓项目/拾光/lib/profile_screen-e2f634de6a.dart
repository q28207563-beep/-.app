import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_time_tracker/providers/task_provider.dart';
import 'package:my_time_tracker/providers/habit_provider.dart';
import 'package:my_time_tracker/providers/pomodoro_provider.dart';
import 'package:my_time_tracker/providers/time_track_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildStats(),
          _buildSettings(),
        ],
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
            '我的',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Consumer<TaskProvider>(
            builder: (context, provider, child) {
              return Text(
                '已完成 ${provider.completedTaskCount} 个任务',
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

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('任务', '120 个'),
          _buildStatItem('习惯', '10 个'),
          _buildStatItem('专注', '240 小时'),
          _buildStatItem('足迹', '1200 小时'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSettings() {
    return Expanded(
      child: ListView(
        children: [
          ListTile(
            title: const Text('主题设置'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateToThemeSettingsScreen(),
          ),
          ListTile(
            title: const Text('通知设置'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateToNotificationSettingsScreen(),
          ),
          ListTile(
            title: const Text('数据备份'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateToDataBackupScreen(),
          ),
          ListTile(
            title: const Text('关于我们'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateToAboutScreen(),
          ),
        ],
      ),
    );
  }

  void _navigateToThemeSettingsScreen() {
    // 导航到主题设置屏幕
  }

  void _navigateToNotificationSettingsScreen() {
    // 导航到通知设置屏幕
  }

  void _navigateToDataBackupScreen() {
    // 导航到数据备份屏幕
  }

  void _navigateToAboutScreen() {
    // 导航到关于我们屏幕
  }
}