import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserProvider extends ChangeNotifier {
  final Box _sessionBox = Hive.box('sessionBox');
  final Box _userBox = Hive.box('userBox');

  String _userName = 'User';
  String _userEmail = '';
  String? _imagePath;

  String get userName => _userName;
  String get userEmail => _userEmail;
  String? get imagePath => _imagePath;
  ImageProvider get profileImage {
    if (_imagePath != null && File(_imagePath!).existsSync()) {
      return FileImage(File(_imagePath!));
    } else {
      return const NetworkImage('https://i.pravatar.cc/150?img=12');
    }
  }

  UserProvider() {
    loadUserData();
    _userBox.listenable().addListener(loadUserData);
  }

  @override
  void dispose() {
    _userBox.listenable().removeListener(loadUserData);
    super.dispose();
  }

  void loadUserData() {
    _userEmail = _sessionBox.get('userEmail', defaultValue: '');
    if (_userBox.containsKey(_userEmail)) {
      final userData = _userBox.get(_userEmail) ?? {};
      _userName = userData['name'] ?? 'User';
      _imagePath = userData['imagePath'];
      notifyListeners();
    } else {
      _userName = 'User';
      _userEmail = '';
      _imagePath = null;
      notifyListeners();
    }
  }

  void triggerUpdate() {
    loadUserData();
  }
}