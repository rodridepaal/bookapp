class OsmPlace {
  final int id; // ID unik dari OSM
  final String name;
  final String address; // Kita coba rangkai alamat dari tags
  final double latitude;
  final double longitude;

  OsmPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  // Fungsi buat bikin alamat jadi rapi (bisa dikembangin)
  static String _formatAddress(Map<String, dynamic> tags) {
    List<String> addressParts = [];
    if (tags['addr:street'] != null) addressParts.add(tags['addr:street']);
    if (tags['addr:housenumber'] != null) addressParts.add(tags['addr:housenumber']);
    if (tags['addr:city'] != null) addressParts.add(tags['addr:city']);
    // Tambahin fallback kalau nggak ada alamat detail
    if (addressParts.isEmpty && tags['description'] != null) return tags['description'];
    if (addressParts.isEmpty) return 'Alamat tidak diketahui';
    return addressParts.join(', ');
  }

  // Factory buat ngubah JSON dari Overpass jadi objek OsmPlace
  factory OsmPlace.fromJson(Map<String, dynamic> json) {
    final tags = json['tags'] ?? {};
    // Ambil koordinat. Kalau 'way' atau 'relation', pakai 'center'
    final double lat = json['lat'] ?? json['center']?['lat'] ?? 0.0;
    final double lon = json['lon'] ?? json['center']?['lon'] ?? 0.0;

    return OsmPlace(
      id: json['id'] ?? 0,
      name: tags['name'] ?? 'Perpustakaan Tanpa Nama',
      address: _formatAddress(tags),
      latitude: lat,
      longitude: lon,
    );
  }
}
