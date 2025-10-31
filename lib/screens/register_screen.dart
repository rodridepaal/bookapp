import 'package:bookapp/widgets/custom_button.dart';
import 'package:bookapp/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:bookapp/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller untuk mengambil teks dari form
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _retypePasswordController = TextEditingController();

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _retypePasswordController.dispose();
    super.dispose();
  }

 void _handleRegister() async { // <-- Tambahkan 'async'
  // Ambil text
  final name = _nameController.text;
  final email = _emailController.text;
  final password = _passwordController.text;
  final retypePassword = _retypePasswordController.text;

  // --- VALIDASI SEDERHANA ---
  if (name.isEmpty || email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua field harus diisi')),
    );
    return; // Berhenti
  }

  if (password != retypePassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password tidak cocok')),
    );
    return; // Berhenti
  }

  // --- PANGGIL AUTH SERVICE ---
  try {
    bool isSuccess = await _authService.register(name, email, password);

    if (isSuccess) {
      // Sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
      );
      // Pindah ke halaman login
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Gagal (email sudah ada)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email sudah terdaftar')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi error: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tombol back
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        // Agar bisa di-scroll jika keyboard muncul
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teks Judul
            const Text(
              "Let's make an account.\nWelcome!\nLet me know who u are.",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // Form
            CustomTextField(
              label: 'Name',
              hint: 'Enter your Name',
              controller: _nameController,
            ),
            const SizedBox(height: 24),

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
            const SizedBox(height: 24),

            CustomTextField(
              label: 'Re-type Password',
              hint: 'Re-enter your password',
              isPassword: true,
              controller: _retypePasswordController,
            ),
            const SizedBox(height: 40), // Jarak ke tombol

            // Tombol Register
            CustomButton(
              text: 'Register',
              onPressed: _handleRegister,
            ),
            const SizedBox(height: 16),

            // Teks "Already have an account?"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    // Pindah ke halaman Login
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'Login',
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