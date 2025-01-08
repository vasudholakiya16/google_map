import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HowToShowNetworkImageAsMarkerOnMap extends StatefulWidget {
  const HowToShowNetworkImageAsMarkerOnMap({super.key});

  @override
  State<HowToShowNetworkImageAsMarkerOnMap> createState() =>
      _HowToShowNetworkImageAsMarkerOnMapState();
}

class _HowToShowNetworkImageAsMarkerOnMapState
    extends State<HowToShowNetworkImageAsMarkerOnMap> {
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _initialLocation =
      CameraPosition(target: LatLng(21.7615294, 72.1111625), zoom: 14.4746);

  final Set<Marker> _markers = <Marker>{};

  // Coordinates for the markers
  List<LatLng> latlng = [
    LatLng(21.761509, 72.110685),
    LatLng(21.761913, 72.110267),
    LatLng(21.762367, 72.109176),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  loadData() async {
    for (int i = 0; i < latlng.length; i++) {
      // Load network image
      Uint8List? image = await loadNetworkImage(
          'https://cdn.britannica.com/22/154122-050-B1D0A7FD/Skyline-Los-Angeles-California.jpg');
      final ui.Codec markerImageCodec = await ui.instantiateImageCodec(
        image!.buffer.asUint8List(),
        targetWidth: 100,
        targetHeight: 100,
      );
      final ui.FrameInfo frameInfo = await markerImageCodec.getNextFrame();
      final ByteData? byteData =
          await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

      final Uint8List resizeImageMarker = byteData!.buffer.asUint8List();
      _markers.add(
        Marker(
          markerId: MarkerId('marker${i.toString()}'),
          position: latlng[i],
          infoWindow: InfoWindow(title: 'Marker ${i.toString()}'),
          icon: BitmapDescriptor.fromBytes(resizeImageMarker),
        ),
      );
      setState(() {});
    }
  }

  Future<Uint8List?> loadNetworkImage(String path) async {
    final completed = Completer<ImageInfo>();
    var image = NetworkImage(path);

    image.resolve(const ImageConfiguration()).addListener(ImageStreamListener(
        (ImageInfo info, bool _) => completed.complete(info)));

    final imageInfo = await completed.future;
    final ByteData? data = await imageInfo.image
        .toByteData(format: ImageByteFormat.png); // Since we need bytes

    return data?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: GoogleMap(
              initialCameraPosition: _initialLocation,
              markers: Set<Marker>.of(_markers),
              // mapToolbarEnabled: true,
              // liteModeEnabled: true,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              })),
    );
  }
}
