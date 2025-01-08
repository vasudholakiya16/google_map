import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class ConvertToLatitudeToAddress extends StatefulWidget {
  const ConvertToLatitudeToAddress({super.key});

  @override
  State<ConvertToLatitudeToAddress> createState() =>
      _ConvertToLatitudeToAddressState();
}

class _ConvertToLatitudeToAddressState
    extends State<ConvertToLatitudeToAddress> {
  String stAddress = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convert Coordinates to Address'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Address: $stAddress',
            style: TextStyle(fontSize: 20),
          ),
          Center(
            child: GestureDetector(
              onTap: () async {
                final latitude = 21.7624777;
                final longitude = 72.1081094;

                try {
                  // Get address from coordinates
                  List<Placemark> placemarks =
                      await placemarkFromCoordinates(latitude, longitude);

                  if (placemarks.isNotEmpty) {
                    var first = placemarks.first;
                    String address =
                        '${first.name}, ${first.street}, ${first.locality}, ${first.country}, ${first.postalCode}, ${first.administrativeArea}';
                    setState(() {
                      stAddress = address;
                    });
                    print("Address: $address");
                  } else {
                    print("No address found");
                  }
                } catch (e) {
                  print("Error getting address: $e");
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border.all(color: Colors.black),
                  ),
                  child: Center(
                    child: Text(
                      'Convert Coordinates',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
