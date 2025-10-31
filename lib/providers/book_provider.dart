// lib/providers/book_provider.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bookapp/models/book_model.dart' as ApiBook; // Pakai alias
import 'package:bookapp/models/saved_book_model.dart';

class BookProvider extends ChangeNotifier {
  // Buka box yang sudah kita siapkan
  final Box<SavedBook> _savedBooksBox = Hive.box<SavedBook>('savedBooksBox');

  // List lokal untuk menampung buku yang sudah diambil dari Hive
  List<SavedBook> _savedBooks = [];

  // Getter agar halaman lain bisa "mendengarkan" list ini
  List<SavedBook> get savedBooks => _savedBooks;

  BookProvider() {
    // Saat provider ini dibuat, langsung muat data dari database
    _loadSavedBooks();
    // Dengarkan perubahan box (misal dihapus dari tempat lain)
    _savedBooksBox.listenable().addListener(_loadSavedBooks);
  }

  @override
  void dispose() {
    _savedBooksBox.listenable().removeListener(_loadSavedBooks);
    super.dispose();
  }

  // --- FUNGSI INTERNAL ---
  void _loadSavedBooks() {
    // Ambil semua data dari box dan masukkan ke list
    _savedBooks = _savedBooksBox.values.toList();
    // Beri tahu semua "pendengar" (widget) bahwa datanya sudah update
    notifyListeners();
     print('DEBUG (BookProvider): _loadSavedBooks called. Count: ${_savedBooks.length}'); // Debug
  }

  // --- FUNGSI UNTUK UI ---

  /// Cek status buku (sudah disimpan atau belum)
  String? getBookStatus(String bookId) {
    try {
      // Coba cari buku berdasarkan ID
      final book = _savedBooks.firstWhere((b) => b.bookId == bookId);
      return book.status; // 'readlist' atau 'finished'
    } catch (e) {
      // Jika tidak ketemu (firstWhere error), berarti belum disimpan
      return null;
    }
  }

  // --- INI FUNGSI YANG KEMARIN SEMPAT HILANG/SALAH ---
  /// Cek apakah buku sudah ada di list (berdasarkan ID)
  bool isBookSaved(String bookId) {
    // Cek pakai 'book.bookId' karena _savedBooks isinya SavedBook
    bool found = _savedBooks.any((book) => book.bookId == bookId);
    // print('DEBUG (BookProvider): isBookSaved called for $bookId. Result: $found'); // Debug (opsional)
    return found;
  }
  // --------------------------------------------------

  /// Fungsi untuk tombol "Read List"
  Future<void> addToReadList(ApiBook.Book book) async {
    final newSavedBook = SavedBook(
      bookId: book.id,
      status: 'readlist', // Set status
      title: book.title,
      authors: book.authors.join(', '), // Gabung penulis
      thumbnailLink: book.thumbnailLink,
      finishedTimestamp: null, // Kosongkan
    );

    // Simpan ke Hive pakai ID buku sebagai KEY
    await _savedBooksBox.put(book.id, newSavedBook);

    // Update list lokal dan beri tahu UI (sudah otomatis via listener)
    // _loadSavedBooks(); // Tidak perlu panggil manual lagi
     print('DEBUG (BookProvider): Added ${book.title} to Read List.'); // Debug
  }

  /// Fungsi untuk tombol "Finished"
  Future<void> addToFinished(ApiBook.Book book) async {
    final newSavedBook = SavedBook(
      bookId: book.id,
      status: 'finished', // Set status
      title: book.title,
      authors: book.authors.join(', '),
      thumbnailLink: book.thumbnailLink,
      finishedTimestamp: DateTime.now().toUtc(), // Catat waktu selesai (UTC)
    );

    await _savedBooksBox.put(book.id, newSavedBook);

    // _loadSavedBooks(); // Tidak perlu panggil manual lagi
    print('DEBUG (BookProvider): Added ${book.title} to Finished.'); // Debug
  }

  /// Fungsi untuk menghapus buku (jika di-klik lagi di detail)
  Future<void> removeBook(String bookId) async {
    await _savedBooksBox.delete(bookId);

    // _loadSavedBooks(); // Tidak perlu panggil manual lagi
    print('DEBUG (BookProvider): Removed book with ID $bookId.'); // Debug
  }
}