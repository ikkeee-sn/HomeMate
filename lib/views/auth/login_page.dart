import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main_navigation.dart';
import '../../models/expense_data.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final String email = _nameController.text.trim();
    final String password = _passwordController.text.trim();

    // Cek input kosong
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan Password tidak boleh kosong!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mulai loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Login menggunakan Firebase Authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Simpan username/email untuk digunakan aplikasi
      UserSession.username = email;

      if (!mounted) return;

      // Masuk ke halaman utama
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigationPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Login gagal!';

      if (e.code == 'invalid-email') {
        message = 'Format email tidak valid!';
      } else if (e.code == 'user-not-found') {
        message = 'Email belum terdaftar!';
      } else if (e.code == 'wrong-password') {
        message = 'Password salah!';
      } else if (e.code == 'invalid-credential') {
        message = 'Email atau Password salah!';
      } else if (e.code == 'user-disabled') {
        message = 'Akun ini telah dinonaktifkan!';
      } else if (e.code == 'too-many-requests') {
        message = 'Terlalu banyak percobaan login. Coba lagi nanti!';
      } else {
        message = 'Login gagal: ${e.message ?? 'Terjadi kesalahan'}';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat login!'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.home_rounded,
                size: 80,
                color: Color(0xFF869277),
              ),

              const SizedBox(height: 10),

              const Text(
                'HomeMate',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF869277),
                ),
              ),

              const Text(
                'Manajemen Pengeluaran Rumah Tangga',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              // Email
              TextField(
                controller: _nameController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.person,
                    color: Color(0xFF869277),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Color(0xFF869277),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Tombol Login
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF869277),
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}