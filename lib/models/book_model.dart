// lib/models/book_model.dart

class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String publisher;
  final String publishedDate;
  final String description;
  final String thumbnailLink;
  final List<String> categories;
  final double averageRating;
  final int pageCount;
  final String language;

  // --- TAMBAHAN BARU UNTUK HARGA ---
  // Kita pakai nullable double (?) karena harga bisa jadi nggak ada
  final double? listPriceAmount;
  final String? listPriceCurrency;
  final double? retailPriceAmount; // Harga jual (kalau ada diskon, dll)
  final String? retailPriceCurrency;
  // ---------------------------------

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.publisher,
    required this.publishedDate,
    required this.description,
    required this.thumbnailLink,
    required this.categories,
    required this.averageRating,
    required this.pageCount,
    required this.language,
    // Tambah di constructor
    this.listPriceAmount,
    this.listPriceCurrency,
    this.retailPriceAmount,
    this.retailPriceCurrency,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final saleInfo = json['saleInfo'] as Map<String, dynamic>?;
    final listPrice = saleInfo?['listPrice'] as Map<String, dynamic>?;
    final retailPrice = saleInfo?['retailPrice'] as Map<String, dynamic>?;
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
    final thumbnail =
        imageLinks?['thumbnail'] ??
        imageLinks?['smallThumbnail'] ??
        'https://via.placeholder.com/150';
    final authorsList = volumeInfo['authors'] as List<dynamic>?;
    final authors =
        authorsList?.map((e) => e.toString()).toList() ?? ['Unknown Author'];
    final categoriesList = volumeInfo['categories'] as List<dynamic>?;
    final categories =
        categoriesList?.map((e) => e.toString()).toList() ?? ['No Genre'];
    final date = volumeInfo['publishedDate'] ?? '0000';
    final publishedYear = date.length >= 4 ? date.substring(0, 4) : '0000';

    // --- PASTIKAN INI ADA SEBELUM 'return' ---
    final rawDescription = volumeInfo['description'] ?? 'No Description';

    return Book(
      id: json['id'] ?? 'Unknown ID',
      title: volumeInfo['title'] ?? 'No Title',
      authors: authors,
      publisher: volumeInfo['publisher'] ?? 'Unknown Publisher',
      publishedDate: publishedYear,
      // --- PAKAI rawDescription DI SINI ---
      description: rawDescription.replaceAll(RegExp(r'<[^>]*>'), ''),
      // ----------------------------------
      thumbnailLink: thumbnail.replaceAll('http:', 'https:'),
      categories: categories,
      averageRating: (volumeInfo['averageRating'] ?? 0.0).toDouble(),
      pageCount: volumeInfo['pageCount'] ?? 0,
      language: volumeInfo['language'] ?? 'N/A',
      listPriceAmount: (listPrice?['amount'] as num?)?.toDouble(),
      listPriceCurrency: listPrice?['currencyCode'] as String?,
      retailPriceAmount: (retailPrice?['amount'] as num?)?.toDouble(),
      retailPriceCurrency: retailPrice?['currencyCode'] as String?,
    );
  }
}
