import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'my_time_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建任务表
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        due_date INTEGER,
        priority INTEGER DEFAULT 0,
        completed INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建番茄专注表
    await db.execute('''
      CREATE TABLE pomodoros (
        id TEXT PRIMARY KEY,
        task_id TEXT,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        duration INTEGER NOT NULL,
        completed INTEGER DEFAULT 0,
        FOREIGN KEY (task_id) REFERENCES tasks (id)
      )
    ''');

    // 创建时光足迹表
    await db.execute('''
      CREATE TABLE time_tracks (
        id TEXT PRIMARY KEY,
        activity TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        duration INTEGER,
        category TEXT
      )
    ''');

    // 创建习惯表
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        frequency TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        color INTEGER DEFAULT 0xFF42A5F5
      )
    ''');

    // 创建习惯完成记录表
    await db.execute('''
      CREATE TABLE habit_completions (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        completed_date INTEGER NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits (id)
      )
    ''');

    // 创建日程表
    await db.execute('''
      CREATE TABLE schedules (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        repeat TEXT
      )
    ''');

    // 创建倒数日表
    await db.execute('''
      CREATE TABLE countdowns (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        target_date INTEGER NOT NULL,
        description TEXT
      )
    ''');

    // 创建生日表
    await db.execute('''
      CREATE TABLE birthdays (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        birthday INTEGER NOT NULL,
        reminder_days INTEGER DEFAULT 1
      )
    ''');

    // 创建笔记表
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建设置表
    await db.execute('''
      CREATE TABLE settings (
        id TEXT PRIMARY KEY,
        theme TEXT DEFAULT 'light',
        language TEXT DEFAULT 'zh',
        notification_enabled INTEGER DEFAULT 1
      )
    ''');
  }

  // 通用插入方法
  Future<int> insert(String table, Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(table, row);
  }

  // 通用查询方法
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    Database db = await database;
    return await db.query(table);
  }

  // 通用查询单条方法
  Future<Map<String, dynamic>?> queryById(String table, String id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // 通用更新方法
  Future<int> update(String table, Map<String, dynamic> row) async {
    Database db = await database;
    String id = row['id'];
    return await db.update(
      table,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 通用删除方法
  Future<int> delete(String table, String id) async {
    Database db = await database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 通用计数方法
  Future<int> count(String table) async {
    Database db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'))!;
  }
}