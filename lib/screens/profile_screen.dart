import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:bookapp/providers/book_provider.dart';
import 'package:bookapp/providers/user_provider.dart';
import 'package:bookapp/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _handleLogout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/welcome',
      (route) => false,
    );
  }

  Future<void> _handleChangePhoto(BuildContext context, UserProvider userProvider) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(pickedFile.path);
    final newPath = '${appDir.path}/$fileName';
    final File newImage = await File(pickedFile.path).copy(newPath);

    final userBox = Hive.box('userBox');
    final userData = userBox.get(userProvider.userEmail);
    if (userData != null) {
      userData['imagePath'] = newImage.path;
      await userBox.put(userProvider.userEmail, userData);
      userProvider.triggerUpdate(); // Beri tahu provider

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final readListCount = bookProvider.savedBooks
        .where((book) => book.status == 'readlist')
        .length;
    final finishedCount = bookProvider.savedBooks
        .where((book) => book.status == 'finished')
        .length;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(
                  key: ValueKey(userProvider.imagePath ?? DateTime.now().toString()),
                  radius: 80,
                  backgroundImage: userProvider.profileImage,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0),
            TextButton(
              onPressed: () => _handleChangePhoto(context, userProvider),
              // --- INI YANG DIBENERIN (BAGIAN 1) ---
              child: const Text(
                'Change Photo', // Teksnya hilang tadi
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              // ------------------------------------
            ),
            const SizedBox(height: 16),
            Text(
              userProvider.userName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              userProvider.userEmail,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCounterBox('Read List', readListCount.toString()), // <-- Panggil helper
                const SizedBox(width: 24),
                _buildCounterBox('Finished', finishedCount.toString()), // <-- Panggil helper
              ],
            ),
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Keluh Kesah',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  // --- INI YANG DIBENERIN (BAGIAN 2) ---
  // Fungsi ini isinya kehapus sebagian tadi
  Widget _buildCounterBox(String label, String count) {
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  // ------------------------------------
}
