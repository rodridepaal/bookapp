import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Pusatkan vertikal
            children: [
              // Bagian Logo
              const Spacer(),
              Container(
                width: 120, // Sesuaikan ukuran
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Image.asset('assets/images/logo.png', width: 80),
                ),
              ),
              const SizedBox(height: 32),

              // Teks "Welcome to bookapp."
              Text(
                'Welcome to bookapp.',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Teks "Pantun"
              Text(
                'Kalau ada sumur diladang\n'
                'boleh kita menumpang mandi,\n'
                'Kalau ada umur yang panjang\n'
                'boleh kita menumpang mandi juga.\n'
                'Jangan lupa baca buku!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5, // Jarak antar baris
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(), // Dorong tombol ke bawah
              // Tombol Login (Hitam)
              SizedBox(
                width: double.infinity, // Lebar penuh
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Warna hitam
                    foregroundColor: Colors.white, // Teks putih
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Register (Abu-abu)
              SizedBox(
                width: double.infinity, // Lebar penuh
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300], // Warna abu-abu
                    foregroundColor: Colors.black, // Teks hitam
                    elevation: 0, // Tanpa bayangan
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
