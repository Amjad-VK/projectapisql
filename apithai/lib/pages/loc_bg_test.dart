import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      Location location = Location();

      // Check if location service is enabled

      // Retrieve location data
      LocationData locationData = await location.getLocation();
      final now = DateTime.now();

      // Write data to file
      final directory = await getApplicationDocumentsDirectory();
      File file = File('${directory.path}/location_data.txt');
      IOSink sink = file.openWrite(mode: FileMode.append);
      sink.writeln(
          'Timestamp: ${now}, Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}');
      await sink.flush();
      await sink.close();

      print('Location data written to file successfully.');
    } catch (e) {
      print('An error occurred while getting location data: $e');
    }
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  // Adjust the frequency as per your needs. The minimum interval is 15 minutes.
  Workmanager().registerPeriodicTask("1", "simplePeriodicTask",
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(
          seconds: 10) // Change this value to adjust the frequency
      );

  runApp(MaterialApp(
    theme: ThemeData(useMaterial3: false),
    home: MyLocc(),
  ));
}

class MyLocc extends StatefulWidget {
  const MyLocc({Key? key}) : super(key: key);

  @override
  _MyLoccState createState() => _MyLoccState();
}

class _MyLoccState extends State<MyLocc> {
  Future<String>? _fileContents;
  @override
  void initState() {
    super.initState();
    _getLocationPermission();
    _fileContents = readFile();
    print('App started.');
  }

  Future<void> _getLocationPermission() async {
    Location location = Location();
    final status = await location.requestPermission();
    if (status != PermissionStatus.granted) {
      print('Location permission not granted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location Data')),
      body: FutureBuilder<String>(
        future: _fileContents,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No location data available.'));
          } else {
            List<String> locations = snapshot.data!.split('\n');
            return ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(locations[index]),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<String> readFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/location_data.txt');

      // Check if the file exists before reading
      if (await file.exists()) {
        String contents = await file.readAsString();
        return contents;
      } else {
        return 'No location data available.';
      }
    } catch (e) {
      return 'An error occurred while reading the file: $e';
    }
  }
}
