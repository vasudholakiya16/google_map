import 'package:flutter/material.dart';
import 'package:google_map/map_marker_custom_info_window.dart';

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
      home: const MapMarkerCustomInfoWindow(),
    );
  }
}
