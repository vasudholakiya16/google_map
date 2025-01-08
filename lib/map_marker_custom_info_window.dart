import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerCustomInfoWindow extends StatefulWidget {
  const MapMarkerCustomInfoWindow({super.key});

  @override
  State<MapMarkerCustomInfoWindow> createState() =>
      _MapMarkerCustomInfoWindowState();
}

class _MapMarkerCustomInfoWindowState extends State<MapMarkerCustomInfoWindow> {
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  // Initialize an empty list for markers
  final List<Marker> _markers = [];

  // Coordinates for the markers and associated titles
  final List<Map<String, dynamic>> _positions = [
    {
      'latLng': LatLng(37.7749, -122.4194), // San Francisco
      'title': 'San Francisco',
      'description': 'Welcome to San Francisco!',
      'image':
          'https://www.sftravel.com/sites/default/files/styles/hero/public/2022-10/painted-ladies-city-skyline-twilight.jpg.webp?itok=MVU3kPdc', // Valid image URL
    },
    {
      'latLng': LatLng(34.0522, -118.2437), // Los Angeles
      'title': 'Los Angeles',
      'description': 'Welcome to Los Angeles!',
      'image':
          'https://cdn.britannica.com/22/154122-050-B1D0A7FD/Skyline-Los-Angeles-California.jpg', // Valid image URL
    },
    {
      'latLng': LatLng(40.7128, -74.0060), // New York City
      'title': 'New York City',
      'description': 'Welcome to New York City!',
      'image':
          'https://cdn.britannica.com/61/93061-050-99147DCE/Statue-of-Liberty-Island-New-York-Bay.jpg', // Valid image URL
    },
    {
      'latLng': LatLng(51.5074, -0.1278), // London
      'title': 'London',
      'description': 'Welcome to London!',
      'image':
          'https://media.cntraveler.com/photos/66ec5d99c2fb737668ff3872/16:9/w_1920,c_limit/GettyImages-488479062.jpg', // Valid image URL
    },
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() {
    for (int i = 0; i < _positions.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId(i.toString()),
          position: _positions[i]['latLng'],
          onTap: () {
            // Show custom info window when a marker is tapped
            _customInfoWindowController.addInfoWindow!(
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _positions[i]['title'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(_positions[i]['description']),
                      SizedBox(height: 5),
                      // Use Expanded to allow the image to take the full width
                      Expanded(
                        child: Image.network(
                          _positions[i]['image'],
                          fit: BoxFit
                              .cover, // Ensures the image covers the area properly
                          width: double
                              .infinity, // Makes sure the image fills the width
                          height: double
                              .infinity, // Ensures the height fills the available space
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _positions[i]['latLng'],
            );
          },

          // onTap: () {
          //   // Show custom info window when a marker is tapped
          //   _customInfoWindowController.addInfoWindow!(
          //     Container(
          //       color: Colors.white,
          //       child: Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               _positions[i]['title'],
          //               style: TextStyle(fontWeight: FontWeight.bold),
          //             ),
          //             SizedBox(height: 5),
          //             Text(_positions[i]['description']),
          //             SizedBox(height: 5),
          //             Image.network(
          //               _positions[i]['image'],
          //               width: double
          //                   .infinity, // Makes sure the image fills the width
          //               height: double
          //                   .infinity, // Ensures the height fills the available space
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //     _positions[i]['latLng'],
          //   );
          // },
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Info Window'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7749, -122.4194),
              zoom: 14,
            ),
            markers: Set<Marker>.of(_markers),
            onTap: (LatLng position) {
              _customInfoWindowController.hideInfoWindow!();
            },
            onMapCreated: (GoogleMapController controller) {
              _customInfoWindowController.googleMapController = controller;
            },
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 200,
            width: 300,
            offset: 35,
          ),
        ],
      ),
    );
  }
}
