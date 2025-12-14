// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/login_state.dart'; // Import Provider yang dibutuhkan

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key}); // Tambahkan const constructor

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          children: [
            // --- Section 1: Pengaturan Akun ---
            ListTile(
              title: const Text('Akun'),

              subtitle: const Text(
                'admin@ecopatrol.com ',
              ), // Contoh: Tampilkan data user

              leading: const Icon(Icons.person),
            ),

            const Divider(),

            // --- Section 2: Tombol Logout ---
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),

              title: const Text('Logout', style: TextStyle(color: Colors.red)),

              onTap: () {
                // Tombol Logout memanggil logout dari LoginStateNotifier

                ref.read(loginStateProvider.notifier).logout();

                // Catatan: Setelah logout, main.dart akan otomatis menavigasi ke LoginScreen

                // karena loginStateProvider.state berubah menjadi false.
              },
            ),

            // --- Section 3: Informasi Aplikasi (Opsional) ---
            const Spacer(), // Dorong widget ke bawah

            const Text(
              'EcoPatrol App - Versi 1.0.0',

              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
