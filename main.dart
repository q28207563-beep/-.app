import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_time_tracker/providers/task_provider.dart';
import 'package:my_time_tracker/providers/habit_provider.dart';
import 'package:my_time_tracker/providers/pomodoro_provider.dart';
import 'package:my_time_tracker/screens/home_screen.dart';
import 'package:my_time_tracker/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化数据库
  await DatabaseHelper.instance.initDatabase();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => PomodoroProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '我的时光',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}