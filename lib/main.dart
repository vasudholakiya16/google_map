import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_map/uber_Clone/driver_app/auth_screen/login_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? prefs;

void main() async {
  // HttpOverrides.global = MyHttpOverriders();
  // WidgetsFlutterBinding.ensureInitialized();
  // prefs = await SharedPreferences.getInstance();
  // ServiceCall.userUUID = Globes.udValueString('uuid');

  // if (ServiceCall.userUUID == '') {
  //   ServiceCall.userUUID = const Uuid().v6();
  //   Globes.udStringSet(ServiceCall.userUUID, 'uuid');
  // }
  // SocketManager.shared.initSocket();
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  // ask for location permission
  await Permission.locationWhenInUse.isDenied.then((value) {
    if (value) {
      Permission.locationWhenInUse.request();
    }
  });

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
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
      // home: const MapSample(),

      // Intermediate_info_map
      // home: const FetchLiveAddress(),
      // home: const MapScreen(),
      // home: const GoogleMapAutoCommpletePlace(),
      // home: MapSample(),

      /// uber Clone
      home: const LoginScreenDriverApp(),
    );
  }
}
