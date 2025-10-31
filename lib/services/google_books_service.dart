import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bookapp/models/book_model.dart';

class GoogleBooksService {
  final String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  List<Book> _parseBooks(String responseBody) {
    final jsonData = json.decode(responseBody);
    final items = jsonData['items'] as List<dynamic>?;

    if (items == null) {
      return []; // Kembalikan list kosong jika tidak ada 'items'
    }

  print('DEBUG (API Response): Jumlah item diterima = ${items.length}');

    // Ubah setiap item JSON menjadi objek Book
    return items.map((item) => Book.fromJson(item)).toList();
  }

  // Fungsi untuk mengambil "Popular Books" (by relevance)
  Future<List<Book>> fetchPopularBooks() async {
    // Kita cari manga (subject:manga) dan urutkan berdasarkan relevansi
    final response = await http.get(Uri.parse('$_baseUrl?q=book&orderBy=relevance&maxResults=20')); // Query manga

    if (response.statusCode == 200) {
      return _parseBooks(response.body);
    } else {
      throw Exception('Failed to load popular books');
    }
  }

  // Fungsi untuk mengambil "Newest Books" (fiksi terbaru)
  Future<List<Book>> fetchNewestBooks() async {
    final response = await http.get(Uri.parse('$_baseUrl?q=subject:fiction&orderBy=newest&maxResults=20'));

    if (response.statusCode == 200) {
      return _parseBooks(response.body);
    } else {
      throw Exception('Failed to load newest books');
    }
  }

  // Fungsi untuk cari buku
  Future<List<Book>> searchBooks(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl?q=$query&maxResults=20'));

    if (response.statusCode == 200) {
      return _parseBooks(response.body);
    } else {
      throw Exception('Failed to search books');
    }
  }

  // --- FUNGSI AMBIL DETAIL BY ID (YANG DIBENERIN) ---
  Future<Book?> fetchBookById(String bookId) async {
    // Pastikan ID tidak kosong
    if (bookId.isEmpty) {
      print('DEBUG: Error - bookId kosong.');
      return null;
    }

    final String apiUrl = '$_baseUrl/$bookId'; // URL pakai ID
    print('DEBUG: Fetching by ID URL: $apiUrl');

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // API ini ngembaliin satu objek buku, BUKAN list 'items'
        final jsonData = json.decode(response.body);
        print('DEBUG: JSON Data received (partial): ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}'); // Print sebagian body
        try {
          // Langsung parse jsonData
          return Book.fromJson(jsonData);
        } catch (e) {
          print('DEBUG: ERROR parsing JSON Book.fromJson: $e'); // Print error parsing
          return null; // Gagal parsing
        }
      } else if (response.statusCode == 404) {
        print('DEBUG: Buku dengan ID $bookId tidak ditemukan (404).');
        return null; // Buku tidak ada
      } else {
        // Print error API lainnya
        print('DEBUG: Gagal fetchBookById. Status: ${response.statusCode}, Body: ${response.body}');
        // Jangan throw Exception biar ReadListScreen bisa nampilin snackbar
        return null; // Gagal karena error lain
      }
    } catch (e) {
      // Tangkap error koneksi/lainnya
      print('DEBUG: Exception saat fetchBookById: $e');
      return null; // Gagal karena exception
    }
  }
  // --------------------------------------------------
}