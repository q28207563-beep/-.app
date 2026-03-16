import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_time_tracker/providers/task_provider.dart';
import 'package:my_time_tracker/providers/habit_provider.dart';
import 'package:my_time_tracker/providers/pomodoro_provider.dart';
import 'package:my_time_tracker/screens/tasks_screen.dart';
import 'package:my_time_tracker/screens/habits_screen.dart';
import 'package:my_time_tracker/screens/pomodoro_screen.dart';
import 'package:my_time_tracker/screens/time_track_screen.dart';
import 'package:my_time_tracker/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    TasksScreen(),
    HabitsScreen(),
    PomodoroScreen(),
    TimeTrackScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的时光'),
        centerTitle: true,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: '任务',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: '习惯',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: '专注',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: '足迹',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}