import 'dart:convert';
import 'package:bookapp/models/osm_place_model.dart'; // Import model baru
import 'package:http/http.dart' as http;

class OsmService {
  // Endpoint Overpass API (pilih salah satu, yg .de biasanya stabil)
  final String _overpassUrl = 'https://overpass-api.de/api/interpreter';
  // final String _overpassUrl = 'https://lz4.overpass-api.de/api/interpreter';
  // final String _overpassUrl = 'https://z.overpass-api.de/api/interpreter';

  // Timeout request (detik)
  final int _timeoutSeconds = 30;

  Future<List<OsmPlace>> getNearbyLibraries(
      double latitude, double longitude,
      {double radiusMeters = 5000}) async { // Default radius 5km

    // Query Overpass QL: Cari node & way dengan tag amenity=library
    // di sekitar (around) koordinat dalam radius tertentu.
    // Minta output JSON. Minta data center untuk way/relation.
    final String query = """
    [out:json][timeout:$_timeoutSeconds];
    (
      node["amenity"="library"](around:$radiusMeters,$latitude,$longitude);
      way["amenity"="library"](around:$radiusMeters,$latitude,$longitude);
      relation["amenity"="library"](around:$radiusMeters,$latitude,$longitude);
    );
    out center;
    """;

    print('DEBUG (OSM): Querying Overpass API...');
    print('DEBUG (OSM): Query = $query'); // Print query for debugging

    try {
      // Overpass pakai POST request
      final response = await http.post(
        Uri.parse(_overpassUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'data': query}, // Kirim query di body
      ).timeout(Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List<dynamic>?;
         print('DEBUG (OSM): Response received. Elements count: ${elements?.length ?? 0}');

        if (elements == null) {
          return [];
        }

        // Ubah setiap 'element' JSON menjadi objek OsmPlace
        // Filter juga yg nggak punya nama (kadang ada data OSM yg aneh)
        return elements
               .where((element) => element['tags']?['name'] != null)
               .map((element) => OsmPlace.fromJson(element))
               .toList();
      } else {
         print('DEBUG (OSM): Error - Status Code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load libraries from Overpass API (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('DEBUG (OSM): Exception - $e');
      // Kembalikan list kosong jika error (timeout, koneksi, dll)
      return [];
    }
  }
}
