// lib/screens/library_map_screen.dart

import 'dart:async';
import 'package:bookapp/models/osm_place_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LibraryMapScreen extends StatefulWidget {
  final Position userPosition;
  final List<OsmPlace> libraries;
  final LatLng? initialTarget; // Bisa null

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
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _buildMarkers(); // Panggil helper marker
  }

  // --- HANYA SATU DEFINISI FUNGSI INI ---
  void _buildMarkers() {
    setState(() {
      // Marker user
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(
            widget.userPosition.latitude,
            widget.userPosition.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Lokasi Kamu'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
      // Marker perpustakaan
      for (final library in widget.libraries) {
        _markers.add(
          Marker(
            markerId: MarkerId(library.id.toString()),
            position: LatLng(library.latitude, library.longitude),
            infoWindow: InfoWindow(
              title: library.name,
              snippet: library.address,
            ),
          ),
        );
      }
    });
  }
  // ------------------------------------

  @override
  Widget build(BuildContext context) {
    // Tentukan target kamera awal
    final LatLng cameraTarget =
        widget.initialTarget ??
        LatLng(widget.userPosition.latitude, widget.userPosition.longitude);
    final double initialZoom = widget.initialTarget != null ? 16.0 : 14.0;
    final CameraPosition initialCameraPosition = CameraPosition(
      target: cameraTarget,
      zoom: initialZoom,
    );

    return Scaffold(
      appBar: _buildAppBar(), // Panggil helper AppBar
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialCameraPosition,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

  // --- HANYA SATU DEFINISI FUNGSI INI ---
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Peta Perpustakaan',
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      iconTheme: const IconThemeData(
        color: Colors.black,
      ), // Buat tombol back jadi hitam
    );
  }
  // ------------------------------------
} // <-- Tutup Class State
