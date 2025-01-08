import 'dart:async';
import 'dart:core';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddMultipleCustomMarker extends StatefulWidget {
  const AddMultipleCustomMarker({super.key});

  @override
  State<AddMultipleCustomMarker> createState() =>
      _AddMultipleCustomMarkerState();
}

class _AddMultipleCustomMarkerState extends State<AddMultipleCustomMarker> {
  final Completer<GoogleMapController> _controller = Completer();

  Uint8List? markerImage;

  // List of custom marker images
  List<String> _images = [
    "images/car.png",
    "images/motorbike.png",
    "images/location.png",
    "images/location (1).png"
  ];

  // Coordinates for the markers
  final List<LatLng> _positions = [
    LatLng(37.7749, -122.4194), // San Francisco
    LatLng(34.0522, -118.2437), // Los Angeles
    LatLng(40.7128, -74.0060), // New York City
    LatLng(51.5074, -0.1278), // London
  ];

  // Initialize an empty list for markers
  final List<Marker> _markers = [];

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco
    zoom: 14,
  );

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return ((await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List());
  }

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  // Method to load markers with their respective images
  void _loadMarkers() async {
    for (int i = 0; i < _images.length; i++) {
      try {
        final Uint8List markerIcon = await getBytesFromAsset(_images[i], 100);

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId('marker_${i.toString()}'),
              position: _positions[i],
              icon: BitmapDescriptor.fromBytes(markerIcon),
              infoWindow: InfoWindow(title: 'This is Marker ${i.toString()}'),
            ),
          );
        });
      } catch (e) {
        print('Error loading marker image: ${_images[i]}');
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: _kGooglePlex,
          mapType: MapType.normal,
          markers: Set.from(_markers),
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }
}
