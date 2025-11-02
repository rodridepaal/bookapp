// lib/services/auth_service.dart

import 'package:encrypt/encrypt.dart' as enc;
import 'package:hive/hive.dart';
import 'dart:convert'; // Import dart:convert

class AuthService {
  final _userBox = Hive.box('userBox');
  final _sessionBox = Hive.box('sessionBox');

  // --- KUNCI STATIS (TETAP SAMA) ---
  static final _key = enc.Key.fromUtf8('my32lengthsupersecretsecretkey!!');
  // --- IV STATIS (INI PERBAIKANNYA) ---
  // Ganti fromLength(16) (RANDOM)
  // jadi fromUtf8('16karakterapaaja') (STATIS)
  static final _iv = enc.IV.fromUtf8('my16digitivkey!!');
  // ------------------------------------

  final _encrypter = enc.Encrypter(enc.AES(_key));

  String _encryptPassword(String password) {
    // Selalu pakai _iv yang statis
    return _encrypter.encrypt(password, iv: _iv).base64;
  }

  // --- FUNGSI REGISTER (DENGAN PRINT DEBUG) ---
  Future<bool> register(String name, String email, String password) async {
    if (_userBox.containsKey(email)) {
      print('DEBUG (Register): Gagal - Email $email sudah ada.');
      return false;
    }
    final encryptedPassword = _encryptPassword(password);
    print(
      'DEBUG (Register): Mau simpan ke Hive -> Key: $email, Value: {name: $name, password: $encryptedPassword}',
    );
    try {
      await _userBox.put(email, {'name': name, 'password': encryptedPassword});
      final savedData = _userBox.get(email);
      print(
        'DEBUG (Register): Berhasil simpan! Data di Hive: ${jsonEncode(savedData)}',
      );
      return true;
    } catch (e) {
      print('DEBUG (Register): ERROR saat _userBox.put: $e');
      return false;
    }
  }

  // --- FUNGSI LOGIN (DENGAN PRINT DEBUG) ---
  Future<bool> login(String email, String password) async {
    if (!_userBox.containsKey(email)) {
      print('DEBUG (Login): Gagal - User $email tidak ditemukan.');
      return false;
    }
    final userData = _userBox.get(email);
    print(
      'DEBUG (Login): Data user ditemukan di Hive: ${jsonEncode(userData)}',
    );
    if (userData == null || !userData.containsKey('password')) {
      print(
        'DEBUG (Login): Error - Data user tidak valid atau tidak ada password.',
      );
      return false;
    }
    final String storedPassword = userData['password'];
    print('DEBUG (Login): Password tersimpan di Hive: $storedPassword');

    // Enkripsi password input (sekarang pakai IV statis yang sama)
    final String inputEncryptedPassword = _encryptPassword(password);
    print(
      'DEBUG (Login): Password input setelah dienkripsi: $inputEncryptedPassword',
    );

    if (storedPassword == inputEncryptedPassword) {
      print('DEBUG (Login): Password COCOK! Membuat session...');
      await _sessionBox.put('isLoggedIn', true);
      await _sessionBox.put('userEmail', email);
      return true;
    } else {
      print('DEBUG (Login): Password TIDAK COCOK!');
      return false;
    }
  }

  // Fungsi Logout (tetap sama)
  Future<void> logout() async {
    await _sessionBox.clear();
    print('User logged out.');
  }
}
