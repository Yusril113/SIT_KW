import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../helpers/db_helper.dart';
import '../providers/login_state.dart';
// Import 'user_model.dart' jika diperlukan oleh DbHelper.instance.insertUser
// import '../models/user_model.dart'; 

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Tambahkan Controller untuk Email dan Verifikasi Password
  final _confirmPasswordController = TextEditingController();

  // Status loading untuk tombol
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
     _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final dbHelper = DbHelper.instance;

    try {
      // 🔎 cek user berdasarkan Username
      final existingUser = await dbHelper.getUserByUsername(username);

      if (existingUser != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Username "$username" sudah digunakan'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Catatan: Jika Anda ingin memeriksa email juga, tambahkan logika cek email di sini.

      // 📝 simpan user. CATATAN: Fungsi insertUser Anda harus menerima Email sebagai argumen ketiga.
      // Jika fungsi DbHelper.instance.insertUser hanya menerima username dan password, 
      // Anda harus memodifikasi DbHelper atau UserModel Anda.
      await dbHelper.insertUser(username, email, password);

      // 💾 simpan session via Riverpod (Auto-login setelah register)
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      await prefs.setString('email', email); // Simpan email jika diperlukan

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Anda telah login.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigasi ke Dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrasi gagal: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi User')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Input Username ---
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty
                        ? 'Username tidak boleh kosong'
                        : null,
              ),
              const SizedBox(height: 16),

              // --- Input Email (BARU) ---
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  // Validasi format email sederhana
                  if (!val.contains('@') || !val.contains('.')) {
                    return 'Masukkan format email yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- Input Password ---
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (val) =>
                    val != null && val.length < 6
                        ? 'Password minimal 6 karakter'
                        : null,
              ),
              const SizedBox(height: 16),

              // --- Input Verifikasi Password (BARU) ---
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Verifikasi Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Verifikasi password tidak boleh kosong';
                  }
                  if (val != _passwordController.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // --- Tombol Daftar ---
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Daftar Akun',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
               const SizedBox(height: 10),
               TextButton(
                onPressed: () {
                  // Kembali ke halaman sebelumnya (biasanya LoginScreen)
                  Navigator.pop(context);
                },
                child: const Text('Sudah punya akun? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}