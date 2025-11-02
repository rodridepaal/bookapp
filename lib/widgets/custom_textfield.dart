import 'package:flutter/material.dart';

// 1. Ubah jadi StatefulWidget
class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    required this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

// 2. Buat Class State-nya
class _CustomTextFieldState extends State<CustomTextField> {
  
  // 3. Buat variabel state untuk melacak status show/hide
  //    Kita set default-nya true (tersembunyi)
  bool _isObscured = true; 

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // 4. Di stateful widget, kita panggil properti pakai 'widget.'
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          
          // 5. Atur obscureText berdasarkan state _isObscured
          //    Tapi HANYA jika ini field password
          obscureText: widget.isPassword ? _isObscured : false, 
          
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            
            // 6. Logika utama untuk ikon
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      // 7. Ganti ikon berdasarkan state
                      _isObscured 
                          ? Icons.visibility_off_outlined 
                          : Icons.visibility_outlined,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      // 8. Panggil setState untuk mengubah state
                      setState(() {
                        // (toggle) Balikkan nilainya:
                        // jika true jadi false, jika false jadi true
                        _isObscured = !_isObscured; 
                      });
                    },
                  )
                : null, // Jangan tampilkan ikon jika bukan field password
          ),
        ),
      ],
    );
  }
}