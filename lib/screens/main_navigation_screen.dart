// lib/screens/main_navigation_screen.dart

import 'package:bookapp/screens/chat_screen.dart';
import 'package:bookapp/screens/finished_screen.dart';
import 'package:bookapp/screens/home_screen.dart';
import 'package:bookapp/screens/library_screen.dart';
import 'package:bookapp/screens/readlist_screen.dart';
import 'package:bookapp/screens/next_day_predictor_screen.dart'; // <--- IMPORT INI
import 'package:bookapp/widgets/custom_bottom_nav.dart';
import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  // Variabel rahasia buat hitung klik
  int _secretHomeClickCount = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ReadListScreen(),
    const FinishedScreen(),
    const LibraryScreen(),
  ];

  void _onTap(int index) {
    // --- LOGIKA EASTER EGG (FITUR RAHASIA) ---
    if (index == 0) {
      // Jika user klik tombol Home (index 0)
      _secretHomeClickCount++;
      print("Secret Click: $_secretHomeClickCount"); // Debug biar keliatan di terminal

      if (_secretHomeClickCount >= 5) {
        // Reset counter
        _secretHomeClickCount = 0;
        
        // Buka Layar Rahasia
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NextDayPredictorScreen()),
        );
        
        // Jangan lanjut update state index, biar tetap di home pas balik
        return; 
      }
    } else {
      // Kalau user klik tombol lain (bukan Home), reset counternya
      _secretHomeClickCount = 0;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0, right: 8.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatScreen()),
            );
          },
          backgroundColor: Colors.black,
          child: const Icon(Icons.support_agent, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          CustomBottomNav(
            currentIndex: _currentIndex,
            onTap: _onTap,
          ),
        ],
      ),
    );
  }
}