import 'package:bookapp/services/auth_service.dart'; // <-- Sudah benar
import 'package:bookapp/widgets/custom_button.dart'; // <-- Sudah benar
import 'package:bookapp/widgets/custom_textfield.dart'; // <-- Sudah benar
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- Controller dan Service (Sudah Benar) ---
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Logic Handle Login (Dengan Perbaikan Async) ---
  void _handleLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Validasi
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password harus diisi')),
      );
      return;
    }

    try {
      bool isSuccess = await _authService.login(email, password);

      // --- PERBAIKAN UNTUK ASYNC GAPS ---
      // Cek apakah widget masih ada di layar sebelum pakai context
      if (!mounted) return;
      // ------------------------------------

      if (isSuccess) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email atau password salah')),
        );
      }
    } catch (e) {
      // --- PERBAIKAN UNTUK ASYNC GAPS ---
      if (!mounted) return;
      // ------------------------------------
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi error: $e')),
      );
    }
  }

  // --- INI YANG HILANG: METHOD BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teks Judul
            const Text(
              "Let's Sign you in.\nWelcome back\nYou've been missed!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // Form
            CustomTextField(
              label: 'Email',
              hint: 'Enter your Email',
              controller: _emailController,
            ),
            const SizedBox(height: 24),

            CustomTextField(
              label: 'Password',
              hint: 'Enter Password',
              isPassword: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 40),

            // Tombol Login
            CustomButton(
              text: 'Login',
              onPressed: _handleLogin, // Ini memanggil fungsi di atas
            ),
            const SizedBox(height: 16),

            // Teks "Don't have an account?"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}