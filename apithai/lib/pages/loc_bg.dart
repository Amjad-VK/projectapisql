import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

void backgroundFetchHeadlessTask(String taskId) async {
  print('[BackgroundFetch] Headless event received.');
  await getLocationData();
  BackgroundFetch.finish(taskId);
}

Future<void> getLocationData() async {
  try {
    Location location = new Location();
    LocationData _locationData;
    _locationData = await location.getLocation();
    double lat = _locationData.latitude!;
    double long = _locationData.longitude!;

    // Get local path
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/location.txt');

    // Format date
    final now = DateTime.now();
    final formatter = DateFormat('HH:mm:ss');
    final timestamp = formatter.format(now);

    // Write location data to file
    final locationData = 'Timestamp: $timestamp, Latitude: $lat, Longitude: $long\n';
    await file.writeAsString(locationData, mode: FileMode.append);

    // print(lat.toString());
    // print(long.toString());
  } catch (e) {
    print('An error occurred while getting location data: $e');
  }
}

void main() {
  runApp(MaterialApp(home: LocTrack(),));
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

@override
void initState() {
  initState();
  BackgroundFetch.configure(BackgroundFetchConfig(
    minimumFetchInterval: 15, // <-- minutes
    stopOnTerminate: false,
    enableHeadless: true,
    requiresBatteryNotLow: false,
    requiresCharging: false,
    requiresStorageNotLow: false,
    requiresDeviceIdle: false,
    requiredNetworkType: NetworkType.NONE,
  ), (String taskId) async {
    print("[BackgroundFetch] Event received: $taskId");
    await getLocationData();
    BackgroundFetch.finish(taskId);
  }).then((int status) {
    print('[BackgroundFetch] configure success: $status');
  }).catchError((e) {
    print('[BackgroundFetch] configure ERROR: $e');
  });

  if (Platform.isAndroid) {
    BackgroundFetch.scheduleTask(TaskConfig(
      taskId: "com.transistorsoft.customtask",
      delay: 1000 * 60, // <-- milliseconds
      periodic: true,
      forceAlarmManager: true,
      stopOnTerminate: false,
      enableHeadless: true,
    ));
  }
}


class LocTrack extends StatelessWidget {
  const LocTrack({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(),);
  }
}