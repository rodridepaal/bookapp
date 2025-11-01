// lib/screens/library_screen.dart

import 'dart:async';
import 'package:bookapp/models/osm_place_model.dart';
import 'package:bookapp/screens/library_map_screen.dart';
import 'package:bookapp/services/osm_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // --- State ---
  String _currentLocationStatus = 'Mencari lokasi...';
  String? _userAddress; // State buat alamat
  final OsmService _osmService = OsmService();
  bool _isLoading = true;
  Position? _userPosition;
  List<OsmPlace> _libraries = [];
  // -------------

  @override
  void initState() {
    super.initState();
    _fetchNearbyLibraries();
  }

  // --- HANYA SATU DEFINISI FUNGSI INI ---
  Future<void> _fetchNearbyLibraries() async {
    print("DEBUG (Library): Memulai _fetchNearbyLibraries...");
    // Reset state sebelum fetch baru, cek mounted
    if (mounted) setState(() {
        _isLoading = true;
        _currentLocationStatus = 'Mencari lokasi...';
        _userAddress = null;
        _libraries = [];
      });

    LocationPermission permission;
    try {
      // 1. Cek Service & Izin Lokasi
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { if (!mounted) return; setState(() { _currentLocationStatus = 'GPS/Lokasi HP mati'; _isLoading = false; }); return; }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) { if (!mounted) return; setState(() { _currentLocationStatus = 'Izin lokasi ditolak'; _isLoading = false; }); return; }
      }

      // 2. Ambil Posisi
      Position position = await Geolocator.getCurrentPosition( desiredAccuracy: LocationAccuracy.medium, timeLimit: const Duration(seconds: 15));
      if (!mounted) return;
      setState(() { _userPosition = position; });

      // 3. Geocoding (Ubah koordinat jadi alamat)
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          // Rangkai alamat jadi lebih rapi
          _userAddress = [
            placemark.street,
            placemark.subLocality,
            placemark.locality,
            placemark.subAdministrativeArea,
            placemark.administrativeArea
          ].whereType<String>().where((part) => part.isNotEmpty).join(', ');
          if(mounted) setState(() { _currentLocationStatus = 'Lokasi ditemukan!'; });
        } else {
           if(mounted) setState(() { _currentLocationStatus = 'Lokasi ditemukan (tanpa alamat detail)'; });
        }
      } catch (geoError) {
         if(mounted) setState(() { _currentLocationStatus = 'Lokasi ditemukan (gagal dapatkan alamat)'; });
      }

      // 4. Panggil service OSM
      List<OsmPlace> libraries = await _osmService.getNearbyLibraries( position.latitude, position.longitude);
      if (!mounted) return;
      setState(() { _libraries = libraries; _isLoading = false; });

    } on TimeoutException { if (!mounted) return; setState(() { _currentLocationStatus = 'Gagal ambil lokasi (Timeout)'; _isLoading = false; }); }
    catch (e) { print("DEBUG (Library): Exception lain: $e"); if (!mounted) return; setState(() { if (_userPosition == null) { _currentLocationStatus = 'Gagal dapatkan lokasi'; } else { _currentLocationStatus = 'Gagal dapatkan data perpus'; } _isLoading = false; }); }
  }
  // ------------------------------------------

  // --- HANYA SATU DEFINISI FUNGSI INI ---
  void _openMapPage({LatLng? targetLocation}) {
    if (_userPosition != null) {
      Navigator.push( context, MaterialPageRoute(
          builder: (context) => LibraryMapScreen(
              userPosition: _userPosition!,
              libraries: _libraries,
              initialTarget: targetLocation,
          ),
        ),
      );
    } else {
       ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Lokasi belum siap.')),);
    }
  }
  // ------------------------------------

  // --- HANYA SATU DEFINISI FUNGSI INI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 1,
        backgroundColor: Colors.white,
        toolbarHeight: 130, // Tinggikan AppBar buat nampung tombol & alamat
        titleSpacing: 24.0, // Atur padding title
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Halaman
            const Text(
              'Nearest Library',
              style: TextStyle( color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
            ),
            const SizedBox(height: 12),
            // Baris Tombol
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol Refresh Lokasi
                TextButton.icon(
                  onPressed: _fetchNearbyLibraries, // Panggil fetch lagi
                  icon: Icon(Icons.my_location, size: 18, color: Colors.blue[700]),
                  label: Text(
                    'Refresh Lokasi', // Ganti teks
                    style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
                // Tombol Buka Peta
                TextButton.icon(
                  onPressed: () => _openMapPage(targetLocation: null), // Buka peta fokus user
                  icon: Icon(Icons.map_outlined, size: 18, color: Colors.grey[700]),
                  label: Text(
                    'Buka Map',
                    style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ],
            ),
             // Tampilkan Alamat atau Status
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                  _userAddress ?? _currentLocationStatus, // Tampilkan alamat kalau ada, kalau nggak, statusnya
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(), // Panggil helper body
    );
  }
  // ------------------------------------

  // --- HANYA SATU DEFINISI FUNGSI INI ---
  Widget _buildBody() {
    if (_isLoading) { return const Center(child: CircularProgressIndicator(color: Colors.black)); }
    // Tampilkan pesan error spesifik jika gagal
    if (_currentLocationStatus.contains('Gagal') || _currentLocationStatus.contains('ditolak') || _currentLocationStatus.contains('mati')) {
       return Center(child: Padding( padding: const EdgeInsets.all(24.0), child: Text(_currentLocationStatus, textAlign: TextAlign.center)));
    }
    // Tampilkan pesan jika tidak ada perpus
    if (_libraries.isEmpty) { return const Center(child: Text('Tidak ada perpustakaan terdekat ditemukan via OSM.')); }

    // Tampilkan list
    return ListView.builder(
      itemCount: _libraries.length,
      itemBuilder: (context, index) {
        final place = _libraries[index];
        // InkWell buat item bisa diklik
        return InkWell(
          onTap: () { _openMapPage(targetLocation: LatLng(place.latitude, place.longitude)); },
          child: _buildLibraryItem( title: place.name, address: place.address), // Panggil helper item
        );
      },
    );
  }
  // ------------------------------------

  // --- HANYA SATU DEFINISI FUNGSI INI ---
  Widget _buildLibraryItem({required String title, required String address}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        children: [
          ClipRRect( borderRadius: BorderRadius.circular(8),
            child: Container( width: 60, height: 60, color: Colors.blueGrey[100], child: const Icon(Icons.local_library, color: Colors.white, size: 30)), // Icon placeholder
          ),
          const SizedBox(width: 16),
          Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text( title, style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text( address, style: TextStyle( color: Colors.grey[700], fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          )),
        ],
      ),
    );
  }
  // ------------------------------------

  // --- TIDAK ADA DEFINISI FUNGSI LAGI DI BAWAH SINI ---

} // <-- Tutup Class State