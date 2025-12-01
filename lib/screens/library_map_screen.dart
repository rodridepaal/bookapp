// lib/screens/library_map_screen.dart

import 'package:bookapp/models/osm_place_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LibraryMapScreen extends StatefulWidget {
  final Position userPosition;
  final List<OsmPlace> libraries;
  final LatLng? initialTarget;

  const LibraryMapScreen({
    Key? key,
    required this.userPosition,
    required this.libraries,
    this.initialTarget,
  }) : super(key: key);

  @override
  State<LibraryMapScreen> createState() => _LibraryMapScreenState();
}

class _LibraryMapScreenState extends State<LibraryMapScreen> {
  // Controller untuk mengambil data posisi map
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    // Tentukan titik tengah awal
    final centerLocation = widget.initialTarget ??
        LatLng(widget.userPosition.latitude, widget.userPosition.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi Pencarian',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          // 1. PETA
          FlutterMap(
            mapController: _mapController, // Pasang controller
            options: MapOptions(
              initialCenter: centerLocation,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.bookapp',
              ),
              MarkerLayer(
                markers: [
                  // Marker User (Biru)
                  Marker(
                    point: LatLng(widget.userPosition.latitude,
                        widget.userPosition.longitude),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.my_location,
                        color: Colors.blue, size: 40),
                  ),
                  // Marker Perpustakaan (Merah)
                  ...widget.libraries.map((lib) => Marker(
                        point: LatLng(lib.latitude, lib.longitude),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(lib.name),
                                content: Text(lib.address),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text("Tutup"))
                                ],
                              ),
                            );
                          },
                          child: const Icon(Icons.location_on,
                              color: Colors.red, size: 40),
                        ),
                      )),
                ],
              ),
            ],
          ),

          // 2. PIN TENGAH (Penunjuk Lokasi Manual)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40), // Geser dikit biar ujung pin pas di tengah
              child: Icon(Icons.location_pin, size: 50, color: Colors.black),
            ),
          ),

          // 3. TOMBOL "CARI DI SINI"
          Positioned(
            bottom: 30,
            left: 50,
            right: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                // Ambil koordinat tengah peta saat ini
                LatLng center = _mapController.camera.center;
                // Kirim balik ke halaman sebelumnya
                Navigator.pop(context, center);
              },
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text("Cari di Area Ini", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}