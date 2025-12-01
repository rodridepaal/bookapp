import 'package:bookapp/models/book_model.dart' as book_api;
import 'package:bookapp/models/saved_book_model.dart';
import 'package:bookapp/providers/book_provider.dart';
import 'package:bookapp/screens/detail_book_screen.dart';
import 'package:bookapp/services/google_books_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class FinishedScreen extends StatefulWidget {
  const FinishedScreen({Key? key}) : super(key: key);

  @override
  State<FinishedScreen> createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> {
  String _selectedZone = 'WIB';
  final Map<String, String> _timezones = {
    'WIB': 'Asia/Jakarta',
    'WITA': 'Asia/Makassar',
    'WIT': 'Asia/Jayapura',
    'London': 'Europe/London',
  };
  bool _isLoadingDetail = false;
  final GoogleBooksService _booksService = GoogleBooksService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        print("DEBUG (Finished): Search query changed: $_searchQuery");
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime utcTimestamp) {
    final location = tz.getLocation(_timezones[_selectedZone]!);
    final zonedTime = tz.TZDateTime.from(utcTimestamp, location);
    final formatter = DateFormat(
      'dd/MM/yyyy HH:mm',
    ); // Format Tanggal Jam:Menit
    return formatter.format(zonedTime);
  }
  // ------------------------------------

  Future<void> _navigateToDetail(String bookId) async {
    if (_isLoadingDetail) return;
    setState(() {
      _isLoadingDetail = true;
    });

    try {
      final book_api.Book? bookDetail = await _booksService.fetchBookById(
        bookId,
      );
      if (!mounted) return;
      if (bookDetail != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailBookScreen(book: bookDetail),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detail buku tidak ditemukan.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat detail buku.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDetail = false;
        });
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
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search your finished books...',
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedZone,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                items: _timezones.keys
                    .map(
                      (zone) =>
                          DropdownMenuItem(value: zone, child: Text(zone)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedZone = value;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<BookProvider>(
            builder: (context, provider, child) {
              final allFinishedBooks = provider.savedBooks
                  .where((book) => book.status == 'finished')
                  .toList();

              final List<SavedBook> filteredList;
              if (_searchQuery.isEmpty) {
                filteredList = allFinishedBooks;
              } else {
                filteredList = allFinishedBooks.where((book) {
                  return book.title.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
                }).toList();
              }
              print(
                "DEBUG (Finished): Filtered list count: ${filteredList.length}",
              );

              if (filteredList.isEmpty && _searchQuery.isNotEmpty) {
                return const Center(
                  child: Text('Buku tidak ditemukan di daftar Finished-mu.'),
                );
              }

              if (allFinishedBooks.isEmpty) {
                return const Center(
                  child: Text('Kamu belum menyelesaikan buku apapun.'),
                );
              }

              return ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final savedBook = filteredList[index];
                  return InkWell(
                    onTap: () => _navigateToDetail(
                      savedBook.bookId,
                    ), // <-- Panggil fungsi di atas
                    child: SavedBookListItemWithTime(
                      book: savedBook,
                      formattedDateTime: savedBook.finishedTimestamp != null
                          ? _formatTimestamp(
                              savedBook.finishedTimestamp!,
                            ) // <-- Panggil fungsi di atas
                          : 'N/A',
                      timezoneAbbreviation: _selectedZone,
                    ),
                  );
                },
              );
            },
          ),
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

}

class SavedBookListItemWithTime extends StatelessWidget {
  final SavedBook book;
  final String formattedDateTime;
  final String timezoneAbbreviation;

  const SavedBookListItemWithTime({
    Key? key,
    required this.book,
    required this.formattedDateTime,
    required this.timezoneAbbreviation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      height: 130,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              book.thumbnailLink,
              height: 100,
              width: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                width: 70,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                  book.authors,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Finished: $formattedDateTime $timezoneAbbreviation', // Tampilkan Tanggal, Jam, Zona
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(Icons.check_circle, color: Colors.green[600], size: 28),
        ],
      ),
    );
  }
}