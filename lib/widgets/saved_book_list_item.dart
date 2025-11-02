import 'package:bookapp/models/saved_book_model.dart';
import 'package:flutter/material.dart';

class SavedBookListItem extends StatelessWidget {
  final SavedBook book;
  final Widget trailing; // Widget di sebelah kanan (ikon bookmark atau ceklis)

  const SavedBookListItem({
    super.key,
    required this.book,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // LANGSUNG RETURN CONTAINER
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      height: 130, //D Tinggi item
      child: Row(
        children: [
          // Gambar Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              book.thumbnailLink,
              height: 100, // Ukuran lebih kecil
              width: 70,
              fit: BoxFit.cover,
              // Tambahkan error builder biar nggak crash kalau gambar gagal load
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                width: 70,
                color: Colors.grey[300],
                child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey)),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info Buku
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book.authors, // Ini sudah string gabungan
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Jika ini adalah buku 'finished', tampilkan tanggal
                if (book.status == 'finished' && book.finishedTimestamp != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Finished: ${book.finishedTimestamp!.day}/${book.finishedTimestamp!.month}/${book.finishedTimestamp!.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Ikon Trailing (Bookmark atau Ceklis)
          const SizedBox(width: 16),
          trailing,
        ],
      ),
    );
  }
}