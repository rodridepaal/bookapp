// lib/screens/main_navigation_screen.dart

import 'package:bookapp/screens/finished_screen.dart'; // <-- Pastikan import-nya ada
import 'package:bookapp/screens/home_screen.dart';
import 'package:bookapp/screens/library_screen.dart';
import 'package:bookapp/screens/readlist_screen.dart'; // <-- Pastikan import-nya ada
import 'package:bookapp/widgets/custom_bottom_nav.dart';
import 'package:flutter/material.dart';

// Halaman placeholder untuk 'Library'
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Halaman $title')),
    );
  }
}


class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0; 

  // Daftar halaman
  final List<Widget> _pages = [
    const HomeScreen(),
    ReadListScreen(), // <-- Sudah benar
    FinishedScreen(), // <-- Sudah benar
    LibraryScreen(), // Tab 3
  ];

  // --- PASTIKAN FUNGSI INI ADA ---
  void _onTap(int index) {
    print('Fungsi _onTap terpanggil! Ganti ke index: $index');
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),

          // --- PASTIKAN 'onTap: _onTap' ADA DI SINI ---
          CustomBottomNav(
            currentIndex: _currentIndex,
            onTap: _onTap, // <-- INI YANG PALING PENTING
          ),
        ],
      ),
    );
  }
}