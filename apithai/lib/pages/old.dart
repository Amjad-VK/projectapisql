import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class LocationDisplay extends StatefulWidget {
  @override
  _LocationDisplayState createState() => _LocationDisplayState();
}

class _LocationDisplayState extends State<LocationDisplay> {
// Gmap

  LatLng initialCenter = LatLng(11.2626, 75.7673);
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  double lat = 0;
  double long = 0;

  late Timer _timer;
  late Timer _locationTimer;

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
    // startLocationUpdate();
  }

  Future<void> checkLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    getLocationData();
  }

  Future<void> getLocationData() async {
    _locationData = await location.getLocation();
    setState(() {
      lat = _locationData.latitude!;
      long = _locationData.longitude!;
    }); // Trigger a rebuild to display location data
  }

  addtotable() async {
    final dio = Dio();

    // Disable SSL certificate verification
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      return HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };
    };

    final url = 'https://10.0.2.2:7277/AddLocation';
    // Replace with your actual API URL

    final data = {
      'Id': '1',
      'Lat': lat,
      'Long': long,
    };

    final response = await dio.post(
      url,
      data: data,
      options: Options(
        headers: {
          'Content-Type':
              'application/json', // Set the content type based on your API's requirements
        },
      ),
    );
  }

  void startLocationUpdate() {
    const Duration locationUpdateInterval =
        Duration(seconds: 5); // 5 seconds interval

    _locationTimer = Timer.periodic(locationUpdateInterval, (_) {
      // Call getLocationData every 5 seconds
      getLocationData();
      // After getting location data, you can add it to the table
      addtotable();
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text('AlertDialog Title'),
          content:  SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your Location'),
              SizedBox(height: 200,width: 200,
                child: FlutterMap(
                      options: MapOptions(
                        initialCenter: initialCenter,
                        initialZoom: 16,
                      ),
                      children: [
                        TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app'),
                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              'OpenStreetMap contributors',
                              // onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                            ),
                          ],
                        )
                      ]),
              ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () {}, child: Text('Submit'))
              ],
            ),
          ],
        );
      },
    );
  }

// Navigator.of(context).pop();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Location Display'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Latitude ${lat.toString()}"),
              Text("Longitudes ${long.toString()}"),
              SizedBox(
                height: 200,
                child: FlutterMap(
                    options: MapOptions(
                      initialCenter: initialCenter,
                      initialZoom: 16,
                    ),
                    children: [
                      TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app'),
                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution(
                            'OpenStreetMap contributors',
                            // onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                          ),
                        ],
                      )
                    ]),
              ),
              ElevatedButton(onPressed: _showMyDialog, child: Text('Submit'))
            ],
          ),
        ));
  }
}
