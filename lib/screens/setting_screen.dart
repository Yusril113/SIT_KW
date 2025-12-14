import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/login_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mengambil data user yang sedang login untuk ditampilkan (opsional)
    final currentUser = ref.watch(loginStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Section 1: Informasi Akun ---
            ListTile(
              title: const Text('Akun'),
              subtitle: Text(currentUser?.email ?? 'Tidak ada email'),
              leading: const Icon(Icons.person),
            ),

            const Divider(),

            const SizedBox(height: 20),

            // --- Section 2: Tombol Logout ---
            ElevatedButton(
              onPressed: () {
                // 1. Panggil fungsi logout dari provider (Mengubah state login menjadi null)
                ref.read(loginStateProvider.notifier).logout();
                
                // 2. NAVIGASI EKSPLISIT: Arahkan ke LoginScreen dan hapus semua rute sebelumnya.
                // Ini memastikan layar Dashboard dan Settings hilang dari tumpukan.
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/login', 
                  (Route<dynamic> route) => false, // Predicate: Hapus semua rute
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Biasanya logout berwarna merah
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Log out',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const Spacer(),

            // --- Section 3: Informasi Aplikasi ---
            const Center(
              child: Text(
                'EcoPatrol App - Versi 1.0.0',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}