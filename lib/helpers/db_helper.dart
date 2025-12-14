import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/report_model.dart';
import '../models/user_model.dart'; // <<< PASTIKAN INI DIIMPORT

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

    // Versi dinaikkan menjadi 3 karena ada perubahan skema besar
    return await openDatabase(
      path,
      version: 3, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('✅ Database dibuat (v$version)');

    // KOREKSI 1: Menambahkan kolom 'email' dan 'role'
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOTTOR NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'Officer'
      )
    ''');

    // KOREKSI 2: Menambahkan user admin default
    await db.insert('users', {
      'username': 'admin',
      'email': 'admin@ecopatrol.com',
      'password': '123', // PENTING: Dalam aplikasi nyata, gunakan hashing!
      'role': 'Admin',
    });
    
    // KOREKSI 3: Menambahkan user officer default
    await db.insert('users', {
      'username': 'officer1',
      'email': 'officer1@ecopatrol.com',
      'password': '123',
      'role': 'Officer',
    });

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
    // Menghapus tabel lama dan menjalankan ulang _onCreate jika versi lama < 3
    if (oldVersion < 3) {
      print('⬆️ Upgrade database $oldVersion → $newVersion');

      await db.execute('DROP TABLE IF EXISTS users');
      await db.execute('DROP TABLE IF EXISTS reports');

      await _onCreate(db, newVersion);
    }
  }

  // =======================
  // REPORTS CRUD (Tidak ada perubahan)
  // =======================
  // ... (Report CRUD tetap sama) ...
  
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

  // KOREKSI 4: Fungsi insertUser harus menerima email dan menetapkan role default
  Future<int> insertUser(String username, String email, String password) async {
    final db = await database;
    return db.insert(
      'users',
      {
        'username': username, 
        'email': email,
        'password': password,
        'role': 'Officer', // Default role untuk registrasi baru
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1, // Batasi ke 1 karena username harus unik
    );
    // KOREKSI: Menggunakan UserModel.fromMap
    return result.isNotEmpty ? UserModel.fromMap(result.first) : null;
  }

  // KOREKSI 5: Mengganti validateUser menjadi getUserByCredentials
  // Mengembalikan UserModel saat sukses, atau null jika gagal.
  Future<UserModel?> getUserByCredentials(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }
  
  // Fungsi lama validateUser dihapus, ganti semua panggilannya di app Anda ke getUserByCredentials
  /* Future<bool> validateUser(String username, String password) async { ... } */

  Future<int> deleteUser(int id) async {
    final db = await database;
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // =======================
  // DEV ONLY
  // =======================
  // ... (resetDatabase tetap sama)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ecopatrol.db');
    await deleteDatabase(path);
    _database = null;
    print('🧹 Database di-reset');
  }
}