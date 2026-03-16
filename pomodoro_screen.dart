import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_time_tracker/providers/pomodoro_provider.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<PomodoroProvider>(context, listen: false).loadPomodoros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildPomodoroTimer(),
          ),
          _buildStats(),
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
            '番茄专注',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Consumer<PomodoroProvider>(
            builder: (context, provider, child) {
              return Text(
                '今日已专注 ${provider.todayFocusMinutes} 分钟',
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

  Widget _buildPomodoroTimer() {
    return Consumer<PomodoroProvider>(
      builder: (context, provider, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              provider.currentMode == PomodoroMode.focus ? '专注时间' : '休息时间',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              provider.currentTime,
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: provider.isRunning ? null : () => provider.startTimer(),
                  child: const Text('开始'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: provider.isRunning ? () => provider.pauseTimer() : null,
                  child: const Text('暂停'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => provider.resetTimer(),
                  child: const Text('重置'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('总专注时间', '120 小时'),
          _buildStatItem('完成番茄', '240 个'),
          _buildStatItem('平均时长', '25 分钟'),
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
}