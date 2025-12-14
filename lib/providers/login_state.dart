// lib/providers/login_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =======================================================
// DEFINISI PROVIDER
// =======================================================

// 1. Provider untuk akses SharedPreferences (Mahasiswa 1)
// KOREKSI: Menggunakan sharedPreferencesProvider (lowerCamelCase)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // Ini di-override di main.dart
  throw UnimplementedError(); 
});

// 2. StateNotifierProvider untuk manajemen status login (Mahasiswa 1)
// KOREKSI SINTAKSIS: Menentukan tipe Notifier (LoginStateNotifier) dan State (bool)
final loginStateProvider = StateNotifierProvider<LoginStateNotifier, bool>((ref) {
  // Gunakan ref.watch untuk mengakses instance SharedPreferences yang di-override di main.dart
  final prefs = ref.watch(sharedPreferencesProvider);
  return LoginStateNotifier(prefs);
});


// =======================================================
// CLASS NOTIFIER
// =======================================================

class LoginStateNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  // KOREKSI: Inisialisasi state awal dari SharedPreferences
  LoginStateNotifier(this._prefs) : super(_prefs.getBool('isLoggedIn') ?? false) {
    _checkLoginStatus();
  }
  
  void _checkLoginStatus() {
    // State sudah diinisialisasi di super(), ini hanya untuk memastikan.
    state = _prefs.getBool('isLoggedIn') ?? false; 
  }

  // Logika Login (Mahasiswa 1)
  // KOREKSI: Mengembalikan Future<bool> agar bisa dicek di login_screen.dart
  Future<bool> login(String username, String password) async {
    // Implementasi login sederhana (Contoh: username 'admin' password '123') 
    if (username == "admin" && password == "123") {
      await _prefs.setBool('isLoggedIn', true);
      state = true;
      return true;
    }
    return false; // Gagal login
  }

  // Logika Logout (Mahasiswa 1)
  Future<void> logout() async {
    await _prefs.setBool('isLoggedIn', false);
    state = false;
  }
}