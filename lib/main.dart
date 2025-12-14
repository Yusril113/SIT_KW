// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/login_state.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'helpers/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // PERBAIKAN: Hapus atau komentari resetDatabase() untuk mengizinkan data persisten.
  // Kode ini HANYA digunakan saat pengembangan untuk membersihkan data secara paksa.
  // await DbHelper.instance.resetDatabase(); // <-- Hapus atau komentari baris ini!
  
  // Pastikan database terinisialisasi (dan menjalankan _onCreate jika baru)
  await DbHelper.instance.database;

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

/// =======================
/// ROOT APPLICATION
/// =======================
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cek apakah state tidak null (berarti ada user yang login)
    final currentUser = ref.watch(loginStateProvider);
    final isLoggedIn = currentUser != null; 

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoPatrol',
      theme: ThemeData(primarySwatch: Colors.green),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
      // Navigasi berdasarkan apakah currentUser tidak null
      home: isLoggedIn
          ? const DashboardScreen()
          : const LoginScreen(),
    );
  }
}