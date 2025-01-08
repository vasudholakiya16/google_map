import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_map/Basic_info_map/home_screen.dart';
import 'package:google_map/Real-Time%20Car%20GPS%20Tracking%20with%20Google%20Maps/common/globes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'Real-Time Car GPS Tracking with Google Maps/common/my_http_overriders.dart';
import 'Real-Time Car GPS Tracking with Google Maps/common/service_call.dart';
import 'Real-Time Car GPS Tracking with Google Maps/common/socket_manager.dart';

SharedPreferences? prefs;

void main() async {
  HttpOverrides.global = MyHttpOverriders();
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  ServiceCall.userUUID = Globes.udValueString('uuid');

  if (ServiceCall.userUUID == '') {
    ServiceCall.userUUID = const Uuid().v6();
    Globes.udStringSet(ServiceCall.userUUID, 'uuid');
  }
  SocketManager.shared.initSocket();
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
      // home: const CustomiseGoogleMap(),

      /// code snippet for Real-Time Car GPS Tracking with Google Maps
      home: const MapSample(),
    );
  }
}
