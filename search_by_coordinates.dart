import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoogleMapController? mapController;
  LatLng? destination;
  String searchQuery = '';
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  void dispose() {
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  void getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      destination = LatLng(position.latitude, position.longitude);
    });
  }

  void searchPlace(String query) async {
    List<Location> locations = await locationFromAddress(query);
    if (locations.isNotEmpty) {
      Location location = locations.first;
      setState(() {
        destination = LatLng(location.latitude, location.longitude);
      });
      mapController?.animateCamera(CameraUpdate.newLatLng(destination!));
    }
  }

  void searchPlaceByCoordinates() {
    double latitude = double.tryParse(latitudeController.text) ?? 0.0;
    double longitude = double.tryParse(longitudeController.text) ?? 0.0;
    if (latitude != 0.0 && longitude != 0.0) {
      setState(() {
        destination = LatLng(latitude, longitude);
      });
      mapController?.animateCamera(CameraUpdate.newLatLng(destination!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Google Maps Example'),
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(0, 0),
                zoom: 15,
              ),
              markers: destination != null
                  ? {
                      Marker(
                        markerId: MarkerId('destination'),
                        position: destination!,
                      ),
                    }
                  : {},
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      onSubmitted: (value) {
                        searchPlace(searchQuery);
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: latitudeController,
                          decoration: InputDecoration(
                            hintText: 'Latitude',
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: longitudeController,
                          decoration: InputDecoration(
                            hintText: 'Longitude',
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: searchPlaceByCoordinates,
                        child: Text('Search by Coordinates'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
