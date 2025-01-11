import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_map/uber_Clone/global/globad_var.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // Add a list of markers to the state

  List<Marker> markers = [];

  final List<Marker> _list = [
    const Marker(
      markerId: MarkerId('marker_1'),
      position: LatLng(21.7624777, 72.1081094),
      infoWindow: InfoWindow(title: 'My current Location'),
    ),
    const Marker(
      markerId: MarkerId('marker_2'),
      position: LatLng(21.7421194, 72.1063534),
      infoWindow: InfoWindow(title: 'Bortalav Lake'),
    ),
  ];

  initState() {
    super.initState();
    markers.addAll(_list);
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(21.7624777, 72.1081094),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            // markers: Set<Marker>.of(markers),
          ),
        ],
      ),

      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: const Text('To the lake!'),
      //   icon: const Icon(Icons.directions_boat),
      // ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}



// Scaffold(
//       body: GoogleMap(
//         mapType: MapType.hybrid,
//         initialCameraPosition: _kGooglePlex,
//         onMapCreated: (GoogleMapController controller) {
//           _controller.complete(controller);
//         },
//         markers: Set<Marker>.of(markers),
//       ),
//       floatingActionButton: FloatingActionButton(
//         // onPressed: _goToTheLake,
//         onPressed: () async {
//           GoogleMapController controller = await _controller.future;
//           controller.animateCamera(CameraUpdate.newCameraPosition(
//               const CameraPosition(
//                   target: LatLng(21.7421194, 72.1063534), zoom: 14.4746)));
//           setState(() {});
//         },
//         child: const Icon(Icons.location_disabled_outlined),
//       ),
//       // floatingActionButton: FloatingActionButton.extended(
//       //   onPressed: _goToTheLake,
//       //   label: const Text('To the lake!'),
//       //   icon: const Icon(Icons.directions_boat),
//       // ),
//     );