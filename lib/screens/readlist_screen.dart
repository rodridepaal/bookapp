// lib/screens/readlist_screen.dart

import 'package:bookapp/models/book_model.dart' as book_api;
import 'package:bookapp/models/saved_book_model.dart';
import 'package:bookapp/providers/book_provider.dart';
import 'package:bookapp/screens/detail_book_screen.dart';
import 'package:bookapp/services/google_books_service.dart';
import 'package:bookapp/widgets/saved_book_list_item.dart'; // Pastikan ini diimport
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReadListScreen extends StatefulWidget {
  // Constructor tanpa const
  const ReadListScreen({Key? key}) : super(key: key);

  @override
  State<ReadListScreen> createState() => _ReadListScreenState();
}

class _ReadListScreenState extends State<ReadListScreen> {
  // State untuk loading overlay
  bool _isLoadingDetail = false;
  final GoogleBooksService _booksService = GoogleBooksService();

  // Controller dan state untuk search lokal
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Listener untuk search bar
    _searchController.addListener(() {
      // Periksa apakah widget masih ada sebelum setState
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text;
          print("DEBUG (ReadList): Search query changed: $_searchQuery");
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- HANYA SATU DEFINISI FUNGSI INI ---
  Future<void> _navigateToDetail(String bookId) async {
    // Hindari double tap saat loading
    if (_isLoadingDetail) return;

    // Periksa mounted sebelum setState
    if (!mounted) return;
    setState(() {
      _isLoadingDetail = true;
    }); // Tampilkan loading

    try {
      print('DEBUG (ReadList): Memanggil fetchBookById for $bookId...');
      final book_api.Book? bookDetail = await _booksService.fetchBookById(
        bookId,
      );
      print(
        'DEBUG (ReadList): fetchBookById selesai. Hasil: ${bookDetail?.title ?? "NULL"}',
      );

      if (!mounted) return; // Cek lagi setelah await

      if (bookDetail != null) {
        print('DEBUG (ReadList): Data buku didapat, mencoba navigasi...');
        // Tunggu navigasi selesai baru matikan loading
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailBookScreen(book: bookDetail),
          ),
        );
      } else {
        print('DEBUG (ReadList): bookDetail null, menampilkan snackbar.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detail buku tidak ditemukan.')),
        );
      }
    } catch (e) {
      print('DEBUG (ReadList): ERROR saat fetch/navigasi: $e');
      if (mounted) {
        // Cek mounted sebelum panggil context
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat detail buku.')),
        );
      }
    } finally {
      // Pastikan widget masih ada sebelum set state
      if (mounted) {
        setState(() {
          _isLoadingDetail = false;
        }); // Sembunyikan loading
        print('DEBUG (ReadList): Loading detail disembunyikan.');
      }
    }
  }
  // ------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: TextField(
          // Search bar
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search your read list...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                    onPressed: () => _searchController.clear(),
                  )
                : null,
          ),
        ),
      ),
      body: Stack(
        // Pakai Stack untuk overlay loading
        children: [
          Consumer<BookProvider>(
            builder: (context, provider, child) {
              // Ambil semua buku readlist
              final allReadListBooks = provider.savedBooks
                  .where((book) => book.status == 'readlist')
                  .toList();

              // Filter berdasarkan search query
              final List<SavedBook> filteredList;
              if (_searchQuery.isEmpty) {
                filteredList = allReadListBooks;
              } else {
                filteredList = allReadListBooks.where((book) {
                  return book.title.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
                }).toList();
              }
              print(
                "DEBUG (ReadList): Filtered list count: ${filteredList.length}",
              );

              // Tampilkan pesan jika list kosong
              if (filteredList.isEmpty && _searchQuery.isNotEmpty) {
                return const Center(
                  child: Text('Buku tidak ditemukan di Read List-mu.'),
                );
              }
              if (allReadListBooks.isEmpty) {
                return const Center(
                  child: Text('Kamu belum menambahkan buku ke Read List.'),
                );
              }

              // Tampilkan ListView hasil filter
              return ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final savedBook = filteredList[index];
                  // InkWell DI SINI, membungkus SavedBookListItem
                  return InkWell(
                    onTap: () {
                      print(
                        'DEBUG (ReadList): InkWell di-tap! Book ID: ${savedBook.bookId}',
                      );
                      _navigateToDetail(
                        savedBook.bookId,
                      ); // Panggil fungsi navigasi
                    },
                    child: SavedBookListItem(
                      // Widget item (TANPA InkWell di dalamnya)
                      book: savedBook,
                      trailing: Icon(
                        Icons.bookmark,
                        color: Colors.yellow[700],
                        size: 28,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // Loading Overlay (muncul jika _isLoadingDetail true)
          if (_isLoadingDetail)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // --- TIDAK ADA DEFINISI FUNGSI LAGI DI BAWAH SINI ---
} // <-- Tutup Class State
