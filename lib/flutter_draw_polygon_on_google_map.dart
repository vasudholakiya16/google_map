import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FlutterDrawPolygonOnGoogleMap extends StatefulWidget {
  const FlutterDrawPolygonOnGoogleMap({super.key});

  @override
  State<FlutterDrawPolygonOnGoogleMap> createState() =>
      _FlutterDrawPolygonOnGoogleMapState();
}

class _FlutterDrawPolygonOnGoogleMapState
    extends State<FlutterDrawPolygonOnGoogleMap> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(33.654235, 73.073000), // San Francisco
    zoom: 14,
  );

  final Set<Marker> _markers = HashSet<Marker>();
  final Set<Polygon> _polygons = HashSet<Polygon>();
  List<LatLng> _points = [
    LatLng(33.654235, 73.073000),
    LatLng(33.647326, 72.820175),
    LatLng(33.689531, 72.763160),
    LatLng(34.131452, 72.763160),
    LatLng(33.654235, 73.073000),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _polygons.add(
      Polygon(
        polygonId: const PolygonId('1'),
        points: _points,
        strokeWidth: 4,
        strokeColor: Colors.red,
        fillColor: Colors.red.withOpacity(0.5),
        geodesic: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Draw Polygon on Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        mapType: MapType.hybrid,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers,
        polygons: _polygons,
      ),
    );
  }
}
