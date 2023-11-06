import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';



class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'thai2023.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE offline_imgcap (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Pname TEXT,
        Beforeafter INT,
        Product TEXT,
        Sof1 INTEGER,
        Sof2 INTEGER,
        Images TEXT
      )
    ''');
  }

  // Add your database CRUD operations here
  Future<List<Map<String, dynamic>>> getAllData() async {
  final db = await database;
  final results = await db.query('offline_imgcap');
  return results;
}
}
