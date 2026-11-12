import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../config/app_constants.dart';

/// SQLite Database Manager for offline caching of employee attendance records.
class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();

  Database? _database;

  AppDatabase._internal();

  factory AppDatabase() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await init();
    return _database!;
  }

  Future<Database> init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.databaseName);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableAttendanceRecords} (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        work_date TEXT NOT NULL,
        check_in_at TEXT,
        check_in_lat REAL,
        check_in_lng REAL,
        check_out_at TEXT,
        check_out_lat REAL,
        check_out_lng REAL,
        created_at TEXT
      );
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_emp_work_date 
      ON ${AppConstants.tableAttendanceRecords} (employee_id, work_date);
    ''');
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration logic for future schema increments
  }

  /// Upserts a single attendance record by id / (employee_id, work_date).
  Future<void> upsertRecord(Map<String, dynamic> record) async {
    final db = await database;
    await db.insert(
      AppConstants.tableAttendanceRecords,
      record,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Batch upserts attendance records within a single transaction.
  Future<void> upsertRecordsBatch(List<Map<String, dynamic>> records) async {
    if (records.isEmpty) return;
    final db = await database;
    final batch = db.batch();
    for (final record in records) {
      batch.insert(
        AppConstants.tableAttendanceRecords,
        record,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Returns today's record for a specific employee if present.
  Future<Map<String, dynamic>?> getTodayRecord(String employeeId, String workDate) async {
    final db = await database;
    final results = await db.query(
      AppConstants.tableAttendanceRecords,
      where: 'employee_id = ? AND work_date = ?',
      whereArgs: [employeeId, workDate],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  /// Returns all cached attendance records for an employee ordered by date descending.
  Future<List<Map<String, dynamic>>> getAllRecords(String employeeId) async {
    final db = await database;
    return db.query(
      AppConstants.tableAttendanceRecords,
      where: 'employee_id = ?',
      whereArgs: [employeeId],
      orderBy: 'work_date DESC',
    );
  }

  /// Wipes all cached attendance records (called on user logout).
  Future<void> clearAll() async {
    final db = await database;
    await db.delete(AppConstants.tableAttendanceRecords);
  }

  /// Closes database connection.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

