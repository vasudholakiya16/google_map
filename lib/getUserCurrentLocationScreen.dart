// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class getUserCurrentLocationScreen extends StatefulWidget {
//   const getUserCurrentLocationScreen({super.key});

//   @override
//   State<getUserCurrentLocationScreen> createState() =>
//       _getUserCurrentLocationScreenState();
// }

// class _getUserCurrentLocationScreenState
//     extends State<getUserCurrentLocationScreen> {
//   final Completer<GoogleMapController> _controller = Completer();

//   static const CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(21.7624777, 72.1081094),
//     zoom: 14.4746,
//   );

//   final List<Marker> markers = <Marker>[
//     Marker(
//       markerId: MarkerId('Home'),
//       position: LatLng(21.7624777, 72.1081094),
//       infoWindow: const InfoWindow(title: 'Home'),
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
//     ),
//   ];

//   Future<Position> getUserCurrentLocation() async {
//     await Geolocator.requestPermission()
//         .then((value) {})
//         .onError((error, stackTrace) {
//       print('Error: $error');
//     });
//     return await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//   }

//   loadLocation() {
//     getUserCurrentLocation().then((value) async {
//       print("My current location is: ");
//       print(value.latitude.toString() + ' ' + value.longitude.toString());

//       markers.add(Marker(
//         markerId: MarkerId('3'),
//         position: LatLng(value.latitude, value.longitude),
//         infoWindow: const InfoWindow(title: 'My Location'),
//       ));

//       CameraPosition _cameraPosition = CameraPosition(
//         target: LatLng(value.latitude, value.longitude),
//         zoom: 14.4746,
//       );
//       // create a controller to achieve the animation
//       final GoogleMapController controller =
//           await _controller.future as GoogleMapController;
//       controller.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
//       setState(() {
//         markers;
//       });
//     });
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     loadLocation();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GoogleMap(
//           initialCameraPosition: _kGooglePlex,
//           markers: Set<Marker>.of(markers),
//           onMapCreated: (GoogleMapController controller) {
//             _controller.complete(controller);
//           }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {},
//         child: const Icon(Icons.location_searching),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GetUserCurrentLocationScreen extends StatefulWidget {
  const GetUserCurrentLocationScreen({super.key});

  @override
  State<GetUserCurrentLocationScreen> createState() =>
      _GetUserCurrentLocationScreenState();
}

class _GetUserCurrentLocationScreenState
    extends State<GetUserCurrentLocationScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(21.7624777, 72.1081094),
    zoom: 14.4746,
  );

  List<Marker> markers = <Marker>[
    Marker(
      markerId: MarkerId('Home'),
      position: LatLng(21.7624777, 72.1081094),
      infoWindow: const InfoWindow(title: 'Home'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
    ),
  ];

  Future<Position> getUserCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Handle the case when permission is denied
      return Future.error("Location permission denied");
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  loadLocation() {
    getUserCurrentLocation().then((value) async {
      print("My current location is: ");
      print(value.latitude.toString() + ' ' + value.longitude.toString());

      setState(() {
        markers.add(Marker(
          markerId: MarkerId('3'),
          position: LatLng(value.latitude, value.longitude),
          infoWindow: const InfoWindow(title: 'My Location'),
        ));
      });

      CameraPosition _cameraPosition = CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 14.4746,
      );

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
    }).catchError((error) {
      print("Error getting location: $error");
    });
  }

  @override
  void initState() {
    super.initState();
    loadLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        markers: Set<Marker>.of(markers),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: loadLocation,
        child: const Icon(Icons.location_searching),
      ),
    );
  }
}
