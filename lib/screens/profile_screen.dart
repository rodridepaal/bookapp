import 'dart:io';
import 'package:bookapp/screens/game_screen.dart';
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

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.black), // --- [COLOR] Ikon Kamera ---
              title: const Text('Ambil Foto (Kamera)'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.black), // --- [COLOR] Ikon Galeri ---
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 50,
      );

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
        
        userProvider.triggerUpdate();

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
        );
      }
    } catch (e) {
      print("Error ambil foto: $e");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil foto. Pastikan izin kamera aktif.')),
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
      // --- [COLOR] Background Body ---
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), 
      appBar: AppBar(
        elevation: 0,
        // --- [COLOR] Background AppBar ---
        backgroundColor: Colors.white, 
        leading: IconButton(
          // --- [COLOR] Ikon Back ---
          icon: const Icon(Icons.arrow_back, color: Colors.black), 
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            // --- [COLOR] Ikon Logout ---
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
              child: const Text(
                'Change Photo',
                // --- [COLOR] Teks Ganti Foto ---
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), 
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userProvider.userName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              userProvider.userEmail,
              // --- [COLOR] Teks Email ---
              style: TextStyle(fontSize: 16, color: Colors.grey[600]), 
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- WIDGET READ LIST ---
                _buildReadListCard('Read List', readListCount.toString()),
                const SizedBox(width: 24),
                // --- WIDGET FINISHED ---
                _buildFinishedCard('Finished', finishedCount.toString()),
              ],
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BookTetrisScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  // --- [COLOR] Background Tombol Game ---
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0), 
                  // --- [COLOR] Teks/Ikon Tombol Game ---
                  foregroundColor: Colors.white, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.videogame_asset),
                label: const Text(
                  'Main Book Stacker',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 36),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kesan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'sangat menyenangkan, angkatan selanjutnya pasti senang riang gembira happy dan berseri seri.',
              style: TextStyle(
                fontSize: 15,
                // --- [COLOR] Teks Kesan ---
                color: Colors.grey[700], 
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Saran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Berikut adalah top 3 saran untuk Pak Bagus yang lucu dan jenaka:\n\n'
              '🔥 1. Yang humor akademik halus tapi nyelekit:\n'
              '“Pak, terima kasih sudah ngajarin kami ngoding. '
              'Sekarang kami tau… kalau error bukan salah kode — '
              'tapi salah takdir dan mental hehehe.”\n\n'

              '🤣 2. Yang absurd tapi sopan:\n'
              '“Pak, kalau aplikasi kami tidak memuaskan dan banyak error… '
              'itu bukan bug. Itu fitur. Kami hanya mengikuti prinsip Bapak: '
              'dibuat segampang itu dan sesimpel itu hehehe.”\n\n'

              '😅 3. Yang format formal:\n'
              '“Dengan segala hormat, Bapak adalah dosen mobile yang selalu '
              'sabar ketika mahasiswa presentasinya nyeleneh, berikut cara merayu beliau: ‘Pak bagus keren sekali!’ '
              'boleh lah kasih saya nilai A hehehe.” \n\n\n'
              'saran ini dipikir dengan serius 7 hari 7 malam, yang bilang hasil prompt berarti haters hehehe',
              style: TextStyle(
                fontSize: 15,
                // --- [COLOR] Teks Saran ---
                color: Colors.grey[700], 
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET KHUSUS READ LIST (Bisa ganti warna sendiri) ---
  Widget _buildReadListCard(String label, String count) {
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        // --- [COLOR] Background Card Read List ---
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        // --- [COLOR] Border Card Read List ---
        border: Border.all(color: Colors.grey[300]!), 
        boxShadow: [
          BoxShadow(
            // --- [COLOR] Bayangan Card Read List ---
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
              // --- [COLOR] Teks Label Read List ---
              color: Colors.grey[600], 
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET KHUSUS FINISHED (Bisa ganti warna sendiri) ---
  Widget _buildFinishedCard(String label, String count) {
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        // --- [COLOR] Background Card Finished ---
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        // --- [COLOR] Border Card Finished ---
        border: Border.all(color: const Color.fromARGB(255, 231, 220, 220)!), 
        boxShadow: [
          BoxShadow(
            // --- [COLOR] Bayangan Card Finished ---
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
              // --- [COLOR] Teks Label Finished ---
              color: Colors.grey[600], 
            ),
          ),
        ],
      ),
    );
  }
}