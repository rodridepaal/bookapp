import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  // Base URL API Frankfurter.app
  final String _baseUrl = 'https://api.frankfurter.app/latest';

  // Daftar mata uang target kita
  final List<String> _targetCurrencies = ['IDR', 'USD', 'EUR', 'JPY'];

  // Fungsi baru: Menerima mata uang asal (fromCurrency)
  Future<Map<String, double>> fetchRates({required String fromCurrency}) async {
    // Pastikan mata uang asal valid (salah satu dari 4 target)
    if (!_targetCurrencies.contains(fromCurrency)) {
      print('Error: Mata uang asal tidak valid: $fromCurrency');
      return {}; // Kembalikan map kosong jika tidak valid
    }

    // Buat daftar mata uang tujuan (semua target KECUALI mata uang asal)
    final String toCurrencies = _targetCurrencies
        .where((c) => c != fromCurrency) // Filter mata uang asal
        .join(','); // Gabung jadi string (misal: "USD,EUR,JPY")

    // Buat URL API lengkap
    final String apiUrl = '$_baseUrl?from=$fromCurrency&to=$toCurrencies';
    print('Fetching rates from: $apiUrl'); // Debug print

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>?;

        if (rates == null) {
          print('Error: API tidak mengembalikan rates.');
          return {};
        }

        // Ubah data 'rates' menjadi Map<String, double>
        final Map<String, double> convertedRates = {};
        rates.forEach((key, value) {
          convertedRates[key] = (value ?? 0.0).toDouble();
        });

        // Tambahkan rate untuk mata uang asal itu sendiri (rate = 1.0)
        convertedRates[fromCurrency] = 1.0;

        print('Rates fetched: $convertedRates'); // Debug print
        return convertedRates;
      } else {
        // Gagal ambil data
        throw Exception(
          'Failed to load currency rates (Status code: ${response.statusCode})',
        );
      }
    } catch (e) {
      print('Error fetching rates: $e');
      return {}; // Kembalikan map kosong jika error
    }
  }
}
