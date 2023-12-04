import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';
import 'package:permission_handler/permission_handler.dart';


const fetchBackground = "fetchBackground";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        Position userLocation = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        break;
    }
    return Future.value(true);
  });
}

void main() {
  runApp(MaterialApp(
    home: MyGeoLoc(),
  ));
}

class MyGeoLoc extends StatefulWidget {
  const MyGeoLoc({super.key});

  @override
  State<MyGeoLoc> createState() => _MyGeoLocState();
}

class _MyGeoLocState extends State<MyGeoLoc> {
  @override
void initState() {
  super.initState();

  // Check if location permission is granted
  Permission.locationAlways.isGranted.then((isGranted) {
    if (!isGranted) {
      // Request location permission
      Permission.locationAlways.request().then((status) {
        if (status == PermissionStatus.granted) {
          // Permission granted, proceed with location retrieval
          _handleLocationRetrieval();
        } else {
          // Permission denied, handle accordingly
          print('Location permission denied');
        }
      });
    } else {
      // Permission already granted, proceed with location retrieval
      _handleLocationRetrieval();
    }
  });
}

void _handleLocationRetrieval() {
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  Workmanager().registerPeriodicTask(
    "1",
    fetchBackground,
    frequency: Duration(minutes: 30),
  );

  Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  ).then((Position position) {
    print('Current position: ${position.latitude}, ${position.longitude}');
  }).catchError((error) {
    print('Error getting current position: ${error.toString()}');
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Icon(Icons.location_on_outlined),
      ),
    );
  }
}
