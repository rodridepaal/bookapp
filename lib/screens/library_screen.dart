// lib/screens/library_screen.dart

import 'dart:async';
import 'package:bookapp/models/osm_place_model.dart';
import 'package:bookapp/screens/library_map_screen.dart';
import 'package:bookapp/services/osm_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // --- State ---
  String _currentLocationStatus = 'Mencari lokasi...';
  String? _userAddress;
  final OsmService _osmService = OsmService();
  bool _isLoading = true;
  Position? _userPosition;
  LatLng? _searchCenter; 
  List<OsmPlace> _libraries = [];
  // -------------

  @override
  void initState() {
    super.initState();
    _fetchNearbyLibraries();
  }

  Future<void> _fetchNearbyLibraries({double? manualLat, double? manualLng}) async {
    print("DEBUG (Library): Memulai _fetchNearbyLibraries...");
    if (mounted) {
      setState(() {
        _isLoading = true;
        _currentLocationStatus = 'Mencari lokasi...';
        if (manualLat == null) _userAddress = null; 
        _libraries = [];
      });
    }

    try {
      double targetLat;
      double targetLng;

      // KASUS 1: Pakai Lokasi Manual (dari Map)
      if (manualLat != null && manualLng != null) {
        targetLat = manualLat;
        targetLng = manualLng;
        if (mounted) {
          setState(() {
            _currentLocationStatus = 'Lokasi Manual Dipilih';
            _searchCenter = LatLng(targetLat, targetLng);
          });
        }
      } 
      // KASUS 2: Pakai GPS (Otomatis)
      else {
        // 1. Cek Service & Izin Lokasi
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (!mounted) return;
          setState(() {
            _currentLocationStatus = 'GPS/Lokasi HP mati';
            _isLoading = false;
          });
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) {
            if (!mounted) return;
            setState(() {
              _currentLocationStatus = 'Izin lokasi ditolak';
              _isLoading = false;
            });
            return;
          }
        }

        // 2. Ambil Posisi GPS
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 15));
        
        targetLat = position.latitude;
        targetLng = position.longitude;

        if (!mounted) return;
        setState(() {
          _userPosition = position;
          _searchCenter = LatLng(targetLat, targetLng);
        });

        // 3. Geocoding
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            _userAddress = [
              placemark.street,
              placemark.subLocality,
              placemark.locality,
              placemark.subAdministrativeArea,
              placemark.administrativeArea
            ].whereType<String>().where((part) => part.isNotEmpty).join(', ');
            if (mounted) {
              setState(() {
                _currentLocationStatus = 'Lokasi ditemukan!';
              });
            }
          }
        } catch (geoError) {
          // Ignore
        }
      }

      // 4. Panggil service OSM
      List<OsmPlace> libraries = await _osmService.getNearbyLibraries(
          targetLat, targetLng);
      
      // --- FITUR BARU: SORTING BY DISTANCE ---
      // Jika kita punya lokasi user, urutkan perpustakaan dari yang terdekat
      if (_userPosition != null) {
        libraries.sort((a, b) {
          double distA = Geolocator.distanceBetween(
              _userPosition!.latitude, _userPosition!.longitude, a.latitude, a.longitude);
          double distB = Geolocator.distanceBetween(
              _userPosition!.latitude, _userPosition!.longitude, b.latitude, b.longitude);
          return distA.compareTo(distB); // Urutkan Ascending (Kecil ke Besar)
        });
      }
      // -------------------------------------

      if (!mounted) return;
      setState(() {
        _libraries = libraries;
        _isLoading = false;
      });

    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _currentLocationStatus = 'Gagal ambil lokasi (Timeout)';
        _isLoading = false;
      });
    } catch (e) {
      print("DEBUG (Library): Exception lain: $e");
      if (!mounted) return;
      setState(() {
        _currentLocationStatus = 'Terjadi kesalahan';
        _isLoading = false;
      });
    }
  }

  void _openMapPage({LatLng? targetLocation}) async {
    if (_userPosition != null) {
      final selectedLocation = await Navigator.push<LatLng>(
        context,
        MaterialPageRoute(
          builder: (context) => LibraryMapScreen(
            userPosition: _userPosition!,
            libraries: _libraries,
            initialTarget: targetLocation ?? _searchCenter, 
          ),
        ),
      );

      if (selectedLocation != null) {
        _fetchNearbyLibraries(
          manualLat: selectedLocation.latitude,
          manualLng: selectedLocation.longitude,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi belum siap.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 1,
        backgroundColor: Colors.white,
        toolbarHeight: 130,
        titleSpacing: 24.0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nearest Library',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 28),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _fetchNearbyLibraries(),
                  icon: Icon(Icons.my_location,
                      size: 18, color: Colors.blue[700]),
                  label: Text(
                    'Reset Lokasi Saya',
                    style: TextStyle(
                        color: Colors.blue[700], fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
                TextButton.icon(
                  onPressed: () => _openMapPage(targetLocation: null),
                  icon: Icon(Icons.map_outlined,
                      size: 18, color: Colors.grey[700]),
                  label: Text(
                    'Buka Map',
                    style: TextStyle(
                        color: Colors.grey[700], fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                _userAddress ?? _currentLocationStatus,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.black));
    }

    if (_libraries.isEmpty) {
      return const Center(
          child: Text('Tidak ada perpustakaan ditemukan di area ini.'));
    }

    return ListView.builder(
      itemCount: _libraries.length,
      itemBuilder: (context, index) {
        final place = _libraries[index];

        // --- HITUNG JARAK UNTUK DISPLAY ---
        String distanceInfo = '-';
        if (_userPosition != null) {
          double distanceInMeters = Geolocator.distanceBetween(
            _userPosition!.latitude,
            _userPosition!.longitude,
            place.latitude,
            place.longitude,
          );

          if (distanceInMeters >= 1000) {
            distanceInfo =
                '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
          } else {
            distanceInfo = '${distanceInMeters.toStringAsFixed(0)} m';
          }
        }
        // --------------------

        return InkWell(
          onTap: () {
            _openMapPage(
                targetLocation: LatLng(place.latitude, place.longitude));
          },
          child: _buildLibraryItem(
            title: place.name,
            address: "$distanceInfo dari lokasi Anda",
          ),
        );
      },
    );
  }

  Widget _buildLibraryItem({required String title, required String address}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
                width: 60,
                height: 60,
                color: Colors.blueGrey[100],
                child: const Icon(Icons.local_library,
                    color: Colors.white, size: 30)),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(address,
                  style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          )),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
} 