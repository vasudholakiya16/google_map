import 'package:flutter/material.dart';
import 'package:google_map/customise_google_map.dart';
import 'package:google_map/how_to_show_network_image_as_marker_on_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const ConvertToLatitudeToAddress(),
      // home: const MapSample(),
      // home: const GetUserCurrentLocationScreen(),
      // home: const GoogleMapAutoCommpletePlace(),
      // home: const AddMultipleCustomMarker(),
      // home: const MapMarkerCustomInfoWindow(),
      // home: const FlutterDrawPolygonOnGoogleMap(),
      // home: const AddingRoutePolylinesToGoogleMaps(),
      // home: const HowToShowNetworkImageAsMarkerOnMap(),
      home: const CustomiseGoogleMap(),
    );
  }
}
