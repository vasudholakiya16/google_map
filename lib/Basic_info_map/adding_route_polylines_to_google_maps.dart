import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddingRoutePolylinesToGoogleMaps extends StatefulWidget {
  const AddingRoutePolylinesToGoogleMaps({super.key});

  @override
  State<AddingRoutePolylinesToGoogleMaps> createState() =>
      _AddingRoutePolylinesToGoogleMapsState();
}

class _AddingRoutePolylinesToGoogleMapsState
    extends State<AddingRoutePolylinesToGoogleMaps> {
  Completer<GoogleMapController> _controller = Completer();

  CameraPosition _initialLocation =
      CameraPosition(target: LatLng(21.7615294, 72.1111625), zoom: 14.4746);
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};

  List<LatLng> latlng = [
    LatLng(21.761509, 72.110685),
    LatLng(21.761913, 72.110267),
    LatLng(21.762367, 72.109176),
  ];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < latlng.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId('marker${i.toString()}'),
          position: latlng[i],
          infoWindow: InfoWindow(title: 'Marker ${i.toString()}'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
      );
      setState(() {});
      _polyLines.add(
        Polyline(
          polylineId: PolylineId('route1'),
          visible: true,
          points: latlng,
          color: Colors.blue,
          width: 4,
        ),
      );
    }
    // how_to_show_network_image_as_marker_on_map.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _initialLocation,
        mapType: MapType.normal,
        markers: _markers,
        polylines: _polyLines,
        myLocationEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
