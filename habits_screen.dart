import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_time_tracker/providers/habit_provider.dart';
import 'package:my_time_tracker/screens/add_habit_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<HabitProvider>(context, listen: false).loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildHabitsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddHabitScreen(),
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
            '我的习惯',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Consumer<HabitProvider>(
            builder: (context, provider, child) {
              return Text(
                '已养成 ${provider.completedHabitsCount} 个习惯',
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

  Widget _buildHabitsList() {
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        if (provider.habits.isEmpty) {
          return const Center(
            child: Text('暂无习惯'),
          );
        }

        return ListView.builder(
          itemCount: provider.habits.length,
          itemBuilder: (context, index) {
            final habit = provider.habits[index];
            return HabitItem(habit: habit);
          },
        );
      },
    );
  }

  void _navigateToAddHabitScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );
    Provider.of<HabitProvider>(context, listen: false).loadHabits();
  }
}

class HabitItem extends StatelessWidget {
  final Habit habit;

  const HabitItem({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Color(habit.color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      title: Text(habit.title),
      subtitle: Text(habit.description ?? ''),
      trailing: ElevatedButton(
        onPressed: () => _toggleHabitCompletion(context),
        child: const Text('打卡'),
      ),
      onTap: () => _navigateToHabitDetailScreen(context),
    );
  }

  void _toggleHabitCompletion(BuildContext context) {
    Provider.of<HabitProvider>(context, listen: false).toggleHabitCompletion(habit.id);
  }

  void _navigateToHabitDetailScreen(BuildContext context) {
    // 导航到习惯详情屏幕
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => HabitDetailScreen(habit: habit),
    //   ),
    // );
  }
}