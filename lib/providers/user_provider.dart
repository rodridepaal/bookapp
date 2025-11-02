// lib/providers/user_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import hive_flutter

class UserProvider extends ChangeNotifier {
  final Box _sessionBox = Hive.box('sessionBox');
  final Box _userBox = Hive.box('userBox');

  String _userName = 'User';
  String _userEmail = '';
  String? _imagePath;

  // Getter untuk UI
  String get userName => _userName;
  String get userEmail => _userEmail;
  String? get imagePath => _imagePath;
  ImageProvider get profileImage {
    if (_imagePath != null && File(_imagePath!).existsSync()) {
      // Penting: Pakai key unik (DateTime) biar Flutter mau refresh gambarnya
      return FileImage(File(_imagePath!));
    } else {
      // Placeholder default
      return const NetworkImage('https://i.pravatar.cc/150?img=12');
    }
  }

  UserProvider() {
    // Muat data saat provider dibuat
    loadUserData();
    // Dengarkan perubahan di userBox
    _userBox.listenable().addListener(loadUserData);
  }

  @override
  void dispose() {
    // Hentikan listener saat provider dihapus
    _userBox.listenable().removeListener(loadUserData);
    super.dispose();
  }

  void loadUserData() {
    _userEmail = _sessionBox.get('userEmail', defaultValue: '');
    if (_userBox.containsKey(_userEmail)) {
      final userData = _userBox.get(_userEmail) ?? {};
      _userName = userData['name'] ?? 'User';
      _imagePath = userData['imagePath'];

      // Beri tahu UI untuk update
      notifyListeners();
      print(
        'User data loaded/updated in provider: Name=$_userName, Path=$_imagePath',
      ); // Debug print
    } else {
      // Jika user data hilang (misal setelah logout lalu login lagi tanpa refresh)
      _userName = 'User';
      _userEmail = '';
      _imagePath = null;
      notifyListeners();
    }
  }

  // Fungsi ini bisa dipanggil dari ProfileScreen setelah update Hive
  // Walaupun listener otomatis, ini bisa buat update lebih cepat
  void triggerUpdate() {
    loadUserData();
  }
}
