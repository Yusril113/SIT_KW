import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/report_model.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._privateConstructor();
  static Database? _database;

  DbHelper._privateConstructor();

  // =======================
  // DATABASE INITIALIZATION
  // =======================

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ecopatrol.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('✅ Database dibuat (v$version)');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        status TEXT NOT NULL,
        officerNotes TEXT,
        officerImagePath TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      print('⬆️ Upgrade database $oldVersion → $newVersion');

      await db.execute('DROP TABLE IF EXISTS users');
      await db.execute('DROP TABLE IF EXISTS reports');

      await _onCreate(db, newVersion);
    }
  }

  // =======================
  // REPORTS CRUD
  // =======================

  Future<int> insertReport(ReportModel report) async {
    final db = await database;
    return db.insert(
      'reports',
      report.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ReportModel>> readAllReports() async {
    final db = await database;
    final maps = await db.query('reports', orderBy: 'id DESC');
    return maps.map(ReportModel.fromMap).toList();
  }

  Future<int> updateReport(ReportModel report) async {
    if (report.id == null) return 0;
    final db = await database;
    return db.update(
      'reports',
      report.toMap(),
      where: 'id = ?',
      whereArgs: [report.id],
    );
  }

  Future<int> deleteReport(int id) async {
    final db = await database;
    return db.delete('reports', where: 'id = ?', whereArgs: [id]);
  }

  // =======================
  // USERS CRUD
  // =======================

  Future<int> insertUser(String username, String password) async {
    final db = await database;
    return db.insert(
      'users',
      {'username': username, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 10,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> validateUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // =======================
  // DEV ONLY
  // =======================

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ecopatrol.db');
    await deleteDatabase(path);
    _database = null;
    print('🧹 Database di-reset');
  }
}
