import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class GoogleMapAutoCommpletePlace extends StatefulWidget {
  const GoogleMapAutoCommpletePlace({super.key});

  @override
  State<GoogleMapAutoCommpletePlace> createState() =>
      _GoogleMapAutoCommpletePlaceState();
}

class _GoogleMapAutoCommpletePlaceState
    extends State<GoogleMapAutoCommpletePlace> {
  final TextEditingController _searchController = TextEditingController();

  var uuid = const Uuid();
  String? _sessionToken = '123456';
  List<dynamic> _placeList = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      onChanged();
    });
  }

  void onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestions(_searchController.text);
  }

  void getSuggestions(String input) async {
    String API_Key = "AlzaSyNLll2gafxIJEhByhCbtEpI07Z8-9fAs8z";
    String baseURL = 'https://maps.gomaps.pro/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$API_Key&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));
    print(response.body);
    var data = json.decode(response.body);
    print(data);

    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        _placeList = json.decode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map Auto Complete Place'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Place',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _placeList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () async {
                    List<Location> locations = await locationFromAddress(
                        _placeList[index]['description']);
                    print(locations.last.longitude);
                    print(locations.last.latitude);
                  },
                  title: Text(_placeList[index]['description']),
                );
              },
            ),
          ),
          // Expanded(
          //   child: Container(
          //     color: Colors.grey,
          //   ),
          // ),
        ],
      ),
    );
  }
}
