import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    String currentTime = DateTime.now().toString();
    String currentLocation =
        'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/locations3.txt');
    await file.writeAsString('$currentTime: $currentLocation\n',
        mode: FileMode.append);
    print('UPDATED');
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  Workmanager().registerPeriodicTask(
    "1",
    "simplePeriodicTask",
    frequency: Duration(minutes: 15),
    initialDelay: Duration(seconds: 20),
    
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Geolocation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Stream<String> _locationDataStream;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _locationDataStream = _readLocationData();
  }

  Stream<String> _readLocationData() async* {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/locations3.txt');

    while (true) {
      await Future.delayed(Duration(seconds: 5)); // Wait for 5 seconds

      // Read the data from the file
      String data = await file.readAsString();
      yield data; // Emit the data
    }
  }

  // Add this method
  Future<void> _requestLocationPermission() async {
    PermissionStatus permission = await Permission.location.status;
    if (permission != PermissionStatus.granted) {
      await Permission.location.request();
    }
  }

  Future<void> _refreshLocationData() async {
    setState(() {
      _locationDataStream = _readLocationData(); // Refresh the data stream
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loc'),
      ),
      body: StreamBuilder<String>(
        stream: _locationDataStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<String> locationData = snapshot.data!.split('\n');
            return locationData.isEmpty
                ? Center(child: Text('No data'))
                : ListView.builder(
                    itemCount: locationData.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(locationData[index]),
                      );
                    },
                  );
          } else {
            return Center(child: Text('Loading...'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _refreshLocationData,child: Icon(Icons.refresh),),
    );
  }
}
