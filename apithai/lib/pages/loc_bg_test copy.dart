import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';


void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Your getLocationData logic here
    Location location = Location();
    try {
      final status = await location.hasPermission();
      if (status == PermissionStatus.granted) {
        LocationData locationData = await location.getLocation();
        final now = DateTime.now();
        // Write the data to a text file
        final directory = await getApplicationDocumentsDirectory();
        File file = File('${directory.path}/location_data.txt');
        IOSink sink = file.openWrite(mode: FileMode.append);
        sink.writeln(
            'Timestamp: ${now}, Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}');
        await sink.flush();
        await sink.close();
      } else {
        await location.requestPermission();
      }
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
  Workmanager().registerPeriodicTask(
    "1",
    "simplePeriodicTask",
    frequency: Duration(minutes: 1), // Change this value to adjust the frequency
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
  Location location = Location();

  List<LocationDataWithTime> locationDataList =
      []; // Declare the locationDataList
  Timer? _timer;

  void getLocationData() async {
    try {
      final status = await location.hasPermission();
      if (status == PermissionStatus.granted) {
        LocationData locationData = await location.getLocation();
        final now = DateTime.now();
        // Add timestamp to the location data and add it to the list
        LocationDataWithTime dataWithTime =
            LocationDataWithTime(locationData, now);
        locationDataList.add(dataWithTime);
        setState(() {}); // Notify the widget that the data has changed

        // Write the data to a text file
        final directory = await getApplicationDocumentsDirectory();
        File file = File('${directory.path}/location_data.txt');
        IOSink sink = file.openWrite(mode: FileMode.append);
        sink.writeln(
            'Timestamp: ${dataWithTime.timestamp}, Latitude: ${dataWithTime.locationData.latitude}, Longitude: ${dataWithTime.locationData.longitude}');
        await sink.flush();
        await sink.close();
      } else {
        await location.requestPermission();
        getLocationData(); // Retry after requesting permission
      }
    } catch (e) {
      print('An error occurred while getting location data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // getLocationData(); // Initial location update

    // _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
    //   getLocationData(); // Update location every minute
    // });
  }

  // @override
  // void dispose() {
  //   _timer?.cancel(); // Cancel the timer when the widget is disposed
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: locationDataList.length,
        itemBuilder: (context, index) {
          LocationDataWithTime dataWithTime = locationDataList[index];
          LocationData locationData = dataWithTime.locationData;
          DateTime timestamp = dataWithTime.timestamp;
          double lat = locationData.latitude!;
          double long = locationData.longitude!;

          return Card(
            elevation: 3,
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timestamp: ${timestamp.toString()}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Latitude: $lat'),
                  SizedBox(height: 4),
                  Text('Longitude: $long'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<String> readFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/location_data.txt');
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return 'An error occurred while reading the file: $e';
    }
  }
}

class LocationDataWithTime {
  final LocationData locationData;
  final DateTime timestamp;

  LocationDataWithTime(this.locationData, this.timestamp);
}
