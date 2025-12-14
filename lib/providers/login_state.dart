// lib/providers/login_state.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/db_helper.dart';
import '../models/user_model.dart';

// =======================================================
// DEFINISI PROVIDER
// =======================================================

// 1. Provider untuk akses SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // Ini di-override di main.dart
  throw UnimplementedError(); 
});

// 2. StateNotifierProvider untuk manajemen status login
// KOREKSI: State diubah dari 'bool' menjadi 'UserModel?'
final loginStateProvider = StateNotifierProvider<LoginStateNotifier, UserModel?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LoginStateNotifier(prefs);
});

// 3. Provider untuk akses DbHelper (Tambahan)
final dbHelperProvider = Provider<DbHelper>((ref) {
  return DbHelper.instance;
});

// =======================================================
// CLASS NOTIFIER
// =======================================================

// KOREKSI: State diubah dari StateNotifier<bool> menjadi StateNotifier<UserModel?>
class LoginStateNotifier extends StateNotifier<UserModel?> {
  final SharedPreferences _prefs;
  
  // Konstruktor: Inisialisasi state awal
  LoginStateNotifier(this._prefs) : super(null) {
    _loadUserFromPrefs();
  }
  
  // Memuat data user dari SharedPreferences saat aplikasi dimulai
  void _loadUserFromPrefs() {
    final username = _prefs.getString('username');
    final email = _prefs.getString('email');
    final role = _prefs.getString('role');
    final id = _prefs.getInt('id');

    if (username != null && role != null && id != null) {
      // Jika data ada, kembalikan UserModel yang sudah logged in
      state = UserModel(
        id: id,
        username: username,
        email: email, // Email bisa null jika DB lama tidak ada
        password: '', // Password tidak disimpan di SharedPreferences
        role: role,
      );
    } else {
      state = null;
    }
  }


  // Logika Login yang menggunakan DbHelper
  Future<bool> login(String username, String password) async {
    final dbHelper = DbHelper.instance; // Akses DbHelper instance

    // KOREKSI: Menggunakan getUserByCredentials dari DbHelper
    final user = await dbHelper.getUserByCredentials(username, password);
    
    if (user != null) {
      // 1. Update SharedPreferences
      await _prefs.setBool('isLoggedIn', true); // Tetap pertahankan flag ini
      await _prefs.setInt('id', user.id!);
      await _prefs.setString('username', user.username);
      await _prefs.setString('email', user.email ?? ''); // Simpan email
      await _prefs.setString('role', user.role);

      // 2. Update State Notifier
      state = user;
      return true;
    }
    
    return false; // Gagal login
  }

  // Logika Logout
  Future<void> logout() async {
    // 1. Bersihkan SharedPreferences
    await _prefs.remove('isLoggedIn');
    await _prefs.remove('id');
    await _prefs.remove('username');
    await _prefs.remove('email');
    await _prefs.remove('role');

    // 2. Update State Notifier
    state = null; // Set state ke null (logged out)
  }
}