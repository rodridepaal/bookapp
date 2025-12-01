 import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex; 
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Kita pakai Stack agar bisa mengambang di atas konten
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 70, // Tinggi navigasi
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 4, 22, 217),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.bookmark, 'Read List', 1),
            _buildNavItem(Icons.visibility, 'Finished', 2),
            _buildNavItem(Icons.account_balance, 'Library', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    // Cek apakah tab ini sedang aktif
    final bool isActive = (currentIndex == index);

    return InkWell(
      onTap: () {
        print('Tombol di-klik! Index: $index');
        onTap(index);
      },
      // Panggil fungsi callback
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Ubah tampilan jika aktif
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            // Tampilkan teks hanya jika aktif (sesuai UI kamu)
            if (isActive)
              const SizedBox(width: 8),
            if (isActive)
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}