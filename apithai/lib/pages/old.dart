import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_internet_signal/flutter_internet_signal.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String connectionQuality = 'Unknown';
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    checkConnectionQuality();
  }

  Future<bool> checkConnectionQuality() async {
    final connectivity = Connectivity();
    final connectivityResult = await connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.mobile) {
      setState(() {
        isConnected = true;
      });
    }

    // The user has no internet connection.

    return isConnected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Quality'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Connection Quality:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              isConnected.toString(),
              style: TextStyle(fontSize: 24, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
