import 'package:bookapp/models/book_model.dart';
import 'package:bookapp/providers/book_provider.dart';
import 'package:bookapp/providers/user_provider.dart';
import 'package:bookapp/screens/detail_book_screen.dart';
import 'package:bookapp/screens/profile_screen.dart';
import 'package:bookapp/services/google_books_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookapp/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoogleBooksService _booksService = GoogleBooksService();
  Future<List<Book>>? _popularBooksFuture;
  Future<List<Book>>? _newestBooksFuture;
  final TextEditingController _searchController = TextEditingController();
  Future<List<Book>>? _searchResultsFuture;
  bool _isSearching = false;
  bool _isLoadingDetail = false;

  @override
  void initState() {
    super.initState();
    _fetchDefaultBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchDefaultBooks() {
    setState(() {
      _popularBooksFuture = _booksService.fetchPopularBooks();
      _newestBooksFuture = _booksService.fetchNewestBooks();
      _searchResultsFuture = null;
      _isSearching = false;
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      _fetchDefaultBooks();
      return;
    }
    setState(() {
      _searchResultsFuture = _booksService.searchBooks(query.trim());
      _isSearching = true;
    });
  }

  Future<void> _navigateToDetail(String bookId) async {
    if (_isLoadingDetail) return;
    setState(() {
      _isLoadingDetail = true;
    });

    try {
      final Book? bookDetail = await _booksService.fetchBookById(bookId);
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

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 246, 0),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 90.0),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    if (_isSearching)
                      _buildSearchResultsSection(bookProvider)
                    else
                      _buildDefaultSections(bookProvider),
                  ],
                ),
              ),
            ),
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

  Widget _buildHeader(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              NotificationService.showTestNotificationNow();
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
            child: Text(
              'Hi, ${userProvider.userName}!',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
            child: CircleAvatar(
              key: ValueKey(
                userProvider.imagePath ?? DateTime.now().toString(),
              ),
              radius: 24,
              backgroundImage: userProvider.profileImage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search a book title...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    _searchController.clear();
                    _fetchDefaultBooks();
                  },
                )
              : null,
          filled: true,
          fillColor: const Color.fromARGB(255, 255, 0, 0),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (value) => _performSearch(value),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDefaultSections(BookProvider bookProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Popular Books'),
        const SizedBox(height: 16),
        _buildHorizontalBookList(_popularBooksFuture, bookProvider),
        const SizedBox(height: 24),
        _buildSectionTitle('Newest Books'),
        const SizedBox(height: 16),
        _buildVerticalBookList(_newestBooksFuture, bookProvider),
      ],
    );
  }

  Widget _buildSearchResultsSection(BookProvider bookProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Search Results for "${_searchController.text}"'),
        const SizedBox(height: 16),
        _buildSearchResultsList(_searchResultsFuture, bookProvider),
      ],
    );
  }

  Widget _buildHorizontalBookList(
    Future<List<Book>>? future,
    BookProvider bookProvider,
  ) {
    return FutureBuilder<List<Book>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No books found.'));
        }

        final books = snapshot.data!;
        return SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final String? bookStatus = bookProvider.getBookStatus(book.id);
              final padding = (index == 0) ? 24.0 : 16.0;
              return Padding(
                padding: EdgeInsets.only(left: padding),
                child: _buildBookCard(
                  book,
                  bookStatus,
                  () => _navigateToDetail(book.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVerticalBookList(
    Future<List<Book>>? future,
    BookProvider bookProvider,
  ) {
    return FutureBuilder<List<Book>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No books found.'));
        }

        final books = snapshot.data!;
        return ListView.builder(
          itemCount: books.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final book = books[index];
            final String? bookStatus = bookProvider.getBookStatus(book.id);
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              // Menggunakan _buildBookListItem untuk tampilan daftar (gambar di kiri)
              child: _buildBookListItem(
                book,
                bookStatus,
                () => _navigateToDetail(book.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResultsList(
    Future<List<Book>>? future,
    BookProvider bookProvider,
  ) {
    if (future == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Text('Type a keyword and press Enter to search.'),
      );
    }

    return FutureBuilder<List<Book>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error searching books: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No books found matching your search.'),
          );
        }

        final books = snapshot.data!;
        return ListView.builder(
          itemCount: books.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final book = books[index];
            final String? bookStatus = bookProvider.getBookStatus(book.id);
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: _buildBookListItem(
                book,
                bookStatus,
                () => _navigateToDetail(book.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookCard(Book book, String? bookStatus, VoidCallback onTap) {
    final bool isSaved = bookStatus != null;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    book.thumbnailLink,
                    height: 180,
                    width: 140,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                            ? child
                            : Container(
                                height: 180,
                                width: 140,
                                color: Colors.grey[200],
                                child: const Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      width: 140,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                if (isSaved)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          bookStatus == 'finished'
                              ? Icons.visibility
                              : Icons.bookmark_added,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              book.authors.join(', '),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookListItem(Book book, String? bookStatus, VoidCallback onTap) {
    
    // Tentukan Ikon dan Warna berdasarkan status
    IconData iconData;
    Color iconColor;

    if (bookStatus == 'readlist') {
      iconData = Icons.bookmark;
      iconColor = Colors.yellow[700]!; // Kuning Emas
    } else if (bookStatus == 'finished') {
      iconData = Icons.check_circle;
      iconColor = Colors.green; // Hijau
    } else {
      iconData = Icons.bookmark_border_outlined;
      iconColor = Colors.grey[600]!; // Abu-abu
    }

    return Card(
      color: Colors.white, //kasi warna container
      elevation: 2, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Sudut membulat
      ),
      margin: const EdgeInsets.only(bottom: 16), // Jarak antar kartu
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16), // Efek klik mengikuti bentuk kartu
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Jarak isi ke pinggir kartu
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book.thumbnailLink,
                  height: 100, // Ukuran disesuaikan agar pas di kartu
                  width: 70,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : Container(
                          height: 100,
                          width: 70,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    width: 70,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // --- INFO BUKU ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book.authors.join(', '),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // --- IKON STATUS (KANAN) ---
              const SizedBox(width: 12),
              Icon(
                iconData,
                color: iconColor,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}