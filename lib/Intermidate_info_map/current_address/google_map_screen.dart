import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FetchLiveAddress extends StatefulWidget {
  const FetchLiveAddress({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FetchLiveAddressState createState() => _FetchLiveAddressState();
}

class _FetchLiveAddressState extends State<FetchLiveAddress> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  String _address = '';

  // Initial position for the map (for example: somewhere in India)
  static const LatLng _initialPosition = LatLng(21.761509, 72.110685);

  @override
  void initState() {
    super.initState();
  }

  // Function to fetch address based on latitude and longitude
  Future<void> _fetchAddress(LatLng latLng) async {
    try {
      // Use Geocoding package to get the address
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        setState(() {
          _address =
              '${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}, ${placemark.postalCode}, ${placemark.isoCountryCode}';
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
    }
  }

  // Callback for map tap to add marker and fetch address
  void _onMapTapped(LatLng latLng) {
    setState(() {
      _markers.clear(); // Clear previous markers
      _markers.add(Marker(
        markerId: MarkerId(latLng.toString()),
        position: latLng,
      ));
    });
    _fetchAddress(latLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map with Address Fetch"),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _initialPosition,
                zoom: 12,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              onTap: _onMapTapped, // Handle tap to add marker and fetch address
              markers: _markers,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _address,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
