import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed; // Fungsi yang dijalankan saat di-klik

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Lebar penuh
      height: 55, // Tinggi sesuai desain
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, // Warna hitam pekat
          foregroundColor: Colors.white, // Teks putih
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Border bulat
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}