import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map/uber_Clone/driver_app/global/globad_var.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _mapTheme = '';
  final Completer<GoogleMapController> _controller = Completer();
  Position? currentPositionOfUser;

  // static const CameraPosition _initialLocation = CameraPosition(
  //   target: LatLng(21.7615294, 72.1111625),
  //   zoom: 14.4746,
  // );

  @override
  void initState() {
    super.initState();
    // Load the default map theme when the widget is initialized
    _loadMapTheme('assets/maptheme/retro_theme.json');
  }

  // Method to load map theme from an asset file
  void _loadMapTheme(String assetPath) {
    DefaultAssetBundle.of(context).loadString(assetPath).then((string) {
      setState(() {
        _mapTheme = string;
      });
      // Reapply the theme immediately after it has been loaded
      _applyMapStyle();
    });
  }

  // Method to apply the map style to the controller
  void _applyMapStyle() async {
    final controller = await _controller.future;
    controller.setMapStyle(_mapTheme);
  }

  getCurrentLiveLocation() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;
    LatLng positionOfUserLatLang = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

    CameraPosition cameraPosition = CameraPosition(
      target: positionOfUserLatLang,
      zoom: 14.4746,
    );

    _controller.future.then((controller) {
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Popup menu for theme selection
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Text('Retro Theme'),
                value: 'assets/maptheme/retro_theme.json',
              ),
              const PopupMenuItem(
                child: Text('Silver Theme'),
                value: 'assets/maptheme/silver_them.json',
              ),
              const PopupMenuItem(
                child: Text('Dark Theme'),
                value: 'assets/maptheme/dark_theme.json',
              ),
              const PopupMenuItem(
                child: Text('Aubergine Theme'),
                value: 'assets/maptheme/aubergine_theme.json',
              ),
              const PopupMenuItem(
                child: Text('Night Theme'),
                value: 'assets/maptheme/night_theme.json',
              ),
            ],
            onSelected: (value) {
              // When a theme is selected, load the appropriate map style
              _loadMapTheme(value as String);
            },
          )
        ],
      ),
      body: GoogleMap(
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        initialCameraPosition: googlePlexInitialPosition,
        onMapCreated: (GoogleMapController controller) {
          // Set the controller once the map is created
          _controller.complete(controller);
          // Apply the initial map theme
          controller.setMapStyle(_mapTheme);
          getCurrentLiveLocation();
        },
      ),
    );
  }
}
