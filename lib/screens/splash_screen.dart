import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    // Timer untuk 2 detik
    Timer(const Duration(seconds: 2), () {
      _checkSession();
    });
  }

  void _checkSession() {
    // Buka box session yang sudah kita buat di main.dart
    var sessionBox = Hive.box('sessionBox');
    
    // Cek apakah ada data 'isLoggedIn' dan nilainya true
    bool isLoggedIn = sessionBox.get('isLoggedIn', defaultValue: false);

    if (isLoggedIn) {
      // Jika sudah login, langsung ke Home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Jika belum, ke Welcome Screen
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Sesuai UI kamu
      body: Center(
        child: Container(
          width: 150, // Sesuaikan ukuran logo
          height: 150,
          decoration: BoxDecoration(
            color: Colors.black, // Background logo hitam
            borderRadius: BorderRadius.circular(30), // Sudut rounded
          ),
          child: Center(
            // Tampilkan logo dari aset
            child: Image.asset(
              'assets/images/logo.png',
              width: 100, // Sesuaikan ukuran
              // Mungkin perlu atur warnanya jika logonya transparan
              // color: Colors.white, 
            ),
          ),
        ),
      ),
    );
  }
}