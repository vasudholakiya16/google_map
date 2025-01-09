import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng currentPosition = const LatLng(37.7749, -122.4194); // Default location
  String address = "Move the marker to fetch the address";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  /// Fetches the user's current location and updates the map position
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        address = "Location permission denied. Enable it in settings.";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  /// Fetches the address using the Geocoding API
  Future<void> _fetchAddress(LatLng position) async {
    const apiKey =
        'AIzaSyBjOjo1NlMOsTgDWKxwBc_9rfg7d9Xj9JE'; // Replace with your API key
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Android-Package': 'com.example.google_map',
          'X-Android-Cert': 'AIzaSyBjOjo1NlMOsTgDWKxwBc_9rfg7d9Xj9JE',
        },
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          setState(() {
            address =
                data['results'][0]['formatted_address'] ?? 'No address found';
          });
        } else {
          setState(() {
            address = 'No address found';
          });
        }
      } else {
        setState(() {
          address = 'Failed to fetch address: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        address = 'Failed to fetch address: Timeout or network error';
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMarkerDragEnd(LatLng position) {
    _fetchAddress(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Address Fetcher')),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: currentPosition,
              zoom: 15.0,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('currentMarker'),
                position: currentPosition,
                draggable: true,
                onDragEnd: _onMarkerDragEnd,
              ),
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.white,
              child: Text(
                address,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
