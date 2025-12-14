// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/login_state.dart';

// Definisi Provider untuk status loading
final loadingStateProvider = StateProvider.autoDispose<bool>((ref) => false);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _attemptLogin() async {
    // 1. Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Aktifkan loading
    ref.read(loadingStateProvider.notifier).state = true;

    try {
      final success = await ref
          .read(loginStateProvider.notifier)
          .login(
            _usernameController.text.trim(),
            _passwordController.text.trim(),
          );

      if (success) {
        // ✅ NAVIGASI KE DASHBOARD:
        if (mounted) {
          // Navigasi ke Named Route '/dashboard' dan hapus semua rute di bawahnya
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (Route<dynamic> route) => false, // Hapus semua rute lama
          );
        }
      } else if (!success && mounted) {
        // Jika login gagal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login gagal. Username atau password salah.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Tangani error umum
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 3. Matikan loading (hanya terjadi jika login gagal atau ada exception, 
      // karena jika sukses, layar LoginScreen sudah dihapus dari tumpukan)
      ref.read(loadingStateProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Panggil ref.watch() untuk mendengarkan perubahan status loading
    final isLoading = ref.watch(loadingStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoPatrol Login'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.security, size: 80, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'Selamat Datang di EcoPatrol',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 40),

                // Input Username
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Input Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Tombol Login
                ElevatedButton(
                  onPressed: isLoading ? null : _attemptLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),

                const SizedBox(height: 20),

                // Tombol Register
                TextButton(
                  onPressed: () {
                    // Navigasi menggunakan named route '/register'
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Belum punya akun? Daftar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}