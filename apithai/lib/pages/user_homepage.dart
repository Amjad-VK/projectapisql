import 'dart:async';
import 'dart:io';

import 'package:apithai/pages/sqlhelper.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:sqflite/sqflite.dart';

class UserHomePage extends StatefulWidget {
  final String? username;
  var userId;

  UserHomePage({required this.username, required this.userId});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  late Timer _locationTimer;
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  double lat = 0;
  double long = 0;

  late Timer _timer;
  int ct = 0;
  Color buttonColor = Colors.greenAccent;
  getdataCount() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    final count = Sqflite.firstIntValue(await db
        .rawQuery('SELECT COUNT(*) FROM offline_imgcap WHERE id = ?', [1]));
    print(count);
    setState(() {
      ct = count!;
      buttonColor = ct == 0 ? Colors.green : Colors.redAccent;
    });
  }

  addtoDB() async {
    if (ct != 0) {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      // View the data
      final tbdata = await dbHelper.getAllData();

      for (var row in tbdata) {
        final data = {
          'Id': row['id'].toString(),
          'Pname': row['Pname'].toString(),
          'Beforeafter': row['Beforeafter'].toString(),
          'Product': row['Product'].toString(),
          'Sof1': (row['Sof1'] != '' ? row['Sof1'].toString() : '0'),
          'Sof2': (row['Sof2'] != '' ? row['Sof2'].toString() : '0'),
          'Images': row['Images'].toString(),
          'Lat': row['Lat'].toString(),
          'Long': row['Long'].toString()
        };

        // Call the function to post data to the API
        final apiSuccess = await addToApi(data);

        if (apiSuccess) {
          await db.delete('offline_imgcap');
          print('Table truncated (all data deleted)');
        }
      }
    } else {
      print("No Data to Sync");
    }
  }

  Future<bool> addToApi(Map<String, dynamic> data) async {
    final dio = Dio();
    // Disable SSL certificate verification
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      return HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };
    };
    final url =
        'https://10.0.2.2:7277/AddImgData'; // Replace with your actual API URL

    try {
      final response = await dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Data posted successfully to the API');
        return true; // API call was successful
      } else {
        print('Failed to post data to the API: ${response.statusCode}');
        return false; // API call failed
      }
    } catch (e) {
      print('Error: $e');
      return false; // API call failed
    }
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
      'Id': widget.userId.toString(),
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
    // Dispose the timers when the widget is removed from the tree
  @override
  void dispose() {
    _locationTimer.cancel();
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdataCount();
    startLocationUpdate();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.username == null || widget.userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('User Home Page - Loading...'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Name:' +
            '${widget.username}' +
            '    ' +
            'ID:' +
            '${widget.userId}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/userimgcap',
                      arguments:
                          widget.userId, // Pass the userId as a route argument
                    );
                  },
                  child: Text('Image Capture', style: TextStyle(fontSize: 20))),
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                  style: ButtonStyle(
                    // Set the button color based on buttonColor
                    backgroundColor:
                        MaterialStateProperty.all<Color>(buttonColor),
                  ),
                  onPressed: () {
                    addtoDB();
                    getdataCount();
                    setState(() {});
                  },
                  child: Text(
                    'Sync  ($ct)',
                    style: TextStyle(fontSize: 20),
                  )),
            )
            // Add the rest of your user home page content here
          ],
        ),
      ),
    );
  }
}
