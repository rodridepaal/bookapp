import 'package:bookapp/models/book_model.dart';
import 'package:bookapp/providers/book_provider.dart';
import 'package:bookapp/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Import intl untuk format angka
import 'package:provider/provider.dart';

class DetailBookScreen extends StatefulWidget {
  final Book book;
  const DetailBookScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<DetailBookScreen> createState() => _DetailBookScreenState();
}

class _DetailBookScreenState extends State<DetailBookScreen> {
  String? currentStatus;
  final CurrencyService _currencyService = CurrencyService();
  Future<Map<String, double>>? _ratesFuture; // Future untuk hasil API kurs
  double? _basePrice; // Harga asli dari Google Books
  String? _baseCurrency; // Mata uang asli dari Google Books
  bool _canConvert = false; // Flag apakah kita bisa konversi

  // Daftar mata uang target
  final List<String> _targetCurrencies = ['IDR', 'USD', 'EUR', 'JPY'];

  @override
  void initState() {
    super.initState();
    // 1. Cek status buku
    currentStatus = Provider.of<BookProvider>(context, listen: false)
        .getBookStatus(widget.book.id);

    // 2. Cek harga & mata uang asli dari Google Books
    if (widget.book.retailPriceAmount != null && widget.book.retailPriceCurrency != null) {
      _basePrice = widget.book.retailPriceAmount;
      _baseCurrency = widget.book.retailPriceCurrency;
    } else if (widget.book.listPriceAmount != null && widget.book.listPriceCurrency != null) {
      _basePrice = widget.book.listPriceAmount;
      _baseCurrency = widget.book.listPriceCurrency;
    }

    // 3. Cek apakah mata uang asli ADA di daftar target kita
    if (_basePrice != null && _baseCurrency != null && _targetCurrencies.contains(_baseCurrency!)) {
      _canConvert = true; // Bisa dikonversi!
      // Panggil API kurs dengan mata uang asli sebagai 'from'
      _ratesFuture = _currencyService.fetchRates(fromCurrency: _baseCurrency!);
    } else {
      _canConvert = false; // Tidak bisa dikonversi
    }
  }

  // --- UI (Build Method) ---
  @override
  Widget build(BuildContext context) {
    // Ambil provider (listen: false agar tidak rebuild terus saat harga loading)
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GAMBAR BUKU ---
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.book.thumbnailLink,
                  height: 300,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : Container(
                            height: 300,
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
                          );
                  },
                   errorBuilder: (context, error, stackTrace) => Container( // Fallback jika gambar gagal load
                      height: 300,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.book, color: Colors.grey, size: 50)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- KONTEN TEKS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    widget.book.title,
                    style: GoogleFonts.manrope( // Contoh pakai font kustom
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Penulis & Tahun
                  Text(
                    '${widget.book.authors.join(', ')} - ${widget.book.publishedDate}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Info (Genre, Halaman, Bahasa)
                  _buildBookInfoRow(),
                  const SizedBox(height: 24),

                  // Deskripsi
                  _buildSectionTitle('Description :'),
                  const SizedBox(height: 8),
                  Text(
                    // Tampilkan deskripsi atau pesan jika kosong
                    widget.book.description.isNotEmpty ? widget.book.description : 'No description available.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),

                  // --- HARGA (LOGIKA BARU) ---
                  _buildSectionTitle('Price :'),
                  const SizedBox(height: 8),
                  _buildPriceSection(), // <-- Panggil fungsi baru
                  // --------------------------

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      // --- Tombol Bawah ---
      // Kita perlu kirim provider ke sini karena fungsi handle klik butuh provider
      bottomNavigationBar: _buildBottomButtons(bookProvider),
    );
  }

  // --- WIDGET BUILDER PEMBANTU ---

  // Fungsi baru untuk menampilkan bagian harga
  Widget _buildPriceSection() {
    // Jika TIDAK bisa dikonversi (harga asli null ATAU mata uang asli tidak ada di target)
    if (!_canConvert || _basePrice == null || _baseCurrency == null) {
      return Column(
        children: [
          _buildPriceRow('IDR', '-'),
          _buildPriceRow('USD', '-'),
          _buildPriceRow('EUR', '-'),
          _buildPriceRow('JPY', '-'),
        ],
      );
    }

    // Jika BISA dikonversi, gunakan FutureBuilder
    // Pastikan _ratesFuture tidak null sebelum digunakan
    if (_ratesFuture == null) {
       // Seharusnya tidak terjadi jika _canConvert true, tapi sebagai fallback
       final format = NumberFormat.currency(locale: 'en_US', symbol: _getCurrencySymbol(_baseCurrency!));
       return Column(children: [_buildPriceRow(_baseCurrency!, format.format(_basePrice!))]);
    }

    return FutureBuilder<Map<String, double>>(
      future: _ratesFuture,
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black));
        }

        // Error atau data kosong dari API Kurs
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          print('Error/No data from Currency API FutureBuilder: ${snapshot.error}'); // Debug print
          // Tetap tampilkan harga asli jika gagal ambil kurs
           final format = NumberFormat.currency(locale: 'en_US', symbol: _getCurrencySymbol(_baseCurrency!));
           return Column(children: [_buildPriceRow(_baseCurrency!, format.format(_basePrice!))]);
        }

        // Berhasil! Hitung semua harga
        final rates = snapshot.data!;

        // Ambil rate dari map (pakai ?? 1.0 untuk mata uang asal)
        // Rate adalah nilai tukar DARI _baseCurrency KE target currency
        final rateIDR = rates['IDR'] ?? (_baseCurrency == 'IDR' ? 1.0 : 0.0);
        final rateUSD = rates['USD'] ?? (_baseCurrency == 'USD' ? 1.0 : 0.0);
        final rateEUR = rates['EUR'] ?? (_baseCurrency == 'EUR' ? 1.0 : 0.0);
        final rateJPY = rates['JPY'] ?? (_baseCurrency == 'JPY' ? 1.0 : 0.0);

        // Hitung harga final: HargaTujuan = HargaAsal * RateKeTujuan
        final double priceIDR = _basePrice! * rateIDR;
        final double priceUSD = _basePrice! * rateUSD;
        final double priceEUR = _basePrice! * rateEUR;
        final double priceJPY = _basePrice! * rateJPY;

        // Format angka biar bagus
        final idrFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0); // Rupiah tanpa desimal
        final usdFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$ ');
        final eurFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€ ');
        final yenFormat = NumberFormat.currency(locale: 'ja_JP', symbol: '¥ ', decimalDigits: 0); // Yen tanpa desimal


        return Column(
          children: [
            _buildPriceRow('IDR', idrFormat.format(priceIDR)),
            _buildPriceRow('USD', usdFormat.format(priceUSD)),
            _buildPriceRow('EUR', eurFormat.format(priceEUR)),
            _buildPriceRow('JPY', yenFormat.format(priceJPY)),
          ],
        );
      },
    );
  }

  // Helper untuk simbol mata uang (bisa ditambahin)
  String _getCurrencySymbol(String code) {
    switch (code) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'JPY': return '¥';
      case 'IDR': return 'Rp';
      default: return code;
    }
  }

  // Helper untuk Info Buku (Genre, Halaman, Bahasa)
Widget _buildBookInfoRow() {
    return Column( // Pakai Column
      children: [
        // Baris 1: Genre (di tengah)
        Center(
          child: _buildInfoColumn(
              'Genre',
              widget.book.categories.isNotEmpty
                  ? widget.book.categories.first
                  : 'N/A'),
        ),
        const SizedBox(height: 16), // Jarak antar baris

        // Baris 2: Pages & Language (berdua)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Jarak rata
          children: [
            _buildInfoColumn(
                'Pages',
                widget.book.pageCount > 0
                    ? widget.book.pageCount.toString()
                    : '-'),
            _buildInfoColumn(
                'Language',
                widget.book.language.toUpperCase()),
          ],
        ),
      ],
    );
  }

  // Helper Kolom Info
  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text( label, style: TextStyle( fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text( value, style: const TextStyle( fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Helper Judul Section
  Widget _buildSectionTitle(String title) {
    return Text( title, style: const TextStyle( fontSize: 18, fontWeight: FontWeight.bold));
  }

  // Helper Baris Harga
  Widget _buildPriceRow(String currency, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text( currency, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text( price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Helper Tombol Bawah
  Widget _buildBottomButtons(BookProvider provider) {
    // Perlu pakai Consumer di sini agar tombol bisa rebuild saat status berubah
    // Tapi karena kita pakai setState di handle klik, ini sudah cukup
    final bool isReadList = currentStatus == 'readlist';
    final bool isFinished = currentStatus == 'finished';

    return Container(
      height: 160, // Kurangi jika masih overflow
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min, // Agar tingginya pas
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleReadListClick(provider),
                  icon: Icon(
                    isReadList ? Icons.bookmark : Icons.bookmark_border,
                    color: isReadList ? Colors.white : Colors.black,
                  ),
                  label: Text( 'Read List', style: TextStyle( color: isReadList ? Colors.white : Colors.black)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isReadList ? Colors.black : Colors.white,
                    side: BorderSide(color: Colors.grey[400]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleFinishedClick(provider),
                  icon: Icon(
                    isFinished ? Icons.visibility : Icons.visibility_outlined,
                    color: isFinished ? Colors.white : Colors.black,
                  ),
                  label: Text( 'Finished', style: TextStyle( color: isFinished ? Colors.white : Colors.black)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isFinished ? Colors.black : Colors.white,
                    side: BorderSide(color: Colors.grey[400]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Kurangi jarak
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text( 'More Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  // Fungsi handle klik
  void _handleReadListClick(BookProvider provider) {
    if (currentStatus == 'readlist') {
      provider.removeBook(widget.book.id);
      setState(() { currentStatus = null; });
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Removed from Read List'), duration: Duration(seconds: 1)));
    } else {
      provider.addToReadList(widget.book);
      setState(() { currentStatus = 'readlist'; });
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Added to Read List'), duration: Duration(seconds: 1)));
    }
  }

  void _handleFinishedClick(BookProvider provider) {
    if (currentStatus == 'finished') {
      provider.removeBook(widget.book.id);
      setState(() { currentStatus = null; });
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Removed from Finished Books'), duration: Duration(seconds: 1)));
    } else {
      provider.addToFinished(widget.book);
      setState(() { currentStatus = 'finished'; });
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Marked as Finished'), duration: Duration(seconds: 1)));
    }
  }

} // <-- Tutup Class

