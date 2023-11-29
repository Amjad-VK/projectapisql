// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:location/location.dart';
import 'sqlhelper.dart';
import 'package:latlong2/latlong.dart';

class userimgcapture_page extends StatefulWidget {
  const userimgcapture_page({super.key});

  @override
  State<userimgcapture_page> createState() => _userimgcapture_pageState();
}

class _userimgcapture_pageState extends State<userimgcapture_page> {
  // Location
  double lat = 0;
  double long = 0;
  late Timer _timer;
  late Timer _locationTimer;
  LatLng initialCenter = LatLng(7, 8);
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  int userId = 0;
// Controllers
  var pname = TextEditingController();
  var shr1 = TextEditingController();
  var shr2 = TextEditingController();
  var formkey = GlobalKey<FormState>();

  String selectedValue = 'Before';

  String selectedProduct = ''; // Selected product name
  // Get Datas
  List<String> productNames = [];
  File? capturedImage; // Store the captured image
  late String imgdata;
  Uint8List? decodedImage;
  bool isConnected = false; //connectionstatus
  Dio dio = Dio();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the userId from the route arguments
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null) {
      setState(() {
        userId = args as int;
      });
    }
  }

// InternetStatus
  Future<bool> checkConnectionQuality() async {
    final connectivity = Connectivity();
    final connectivityResult = await connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.mobile) {
      print("Connected");
      setState(() {
        isConnected = true;
      });
    } else {
      print("Disconnected");
    }

    // The user has no internet connection.

    return isConnected;
  }

// Camcapture
  Future<void> captureImage() async {
    final ImagePicker _picker = ImagePicker();

    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      // Set the captured image
      setState(() {
        capturedImage = File(image.path);
        imgdata = base64Encode(capturedImage!.readAsBytesSync());
        decodedImage = base64Decode(imgdata);
      });
      print(imgdata);
    } else {
      // User canceled image capture
    }
  }

  Future<void> makeRequest() async {
    // Create a custom Dio instance
    final dio = Dio();

    // Disable SSL certificate verification
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      return HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };
    };

    try {
      final response =
          await dio.get('https://10.0.2.2:7277/GetAllProductNames');

      if (response.statusCode == 200) {
        final jsonResponse = response.data;

        setState(() {
          productNames = (jsonResponse as List).cast<String>();
          if (productNames.isNotEmpty) {
            selectedProduct = productNames.first; // Set the initial value
          }
        });

        // print('Request succeeded');
        // print(response.data);
      } else {
        print('Request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> saveData() async {
    if (isConnected == true) {
      if (formkey.currentState!.validate()) {
        int beforeAfterValue = selectedValue == 'Before' ? 0 : 1;
        int sof1Value = shr1.text.isEmpty ? 0 : int.parse(shr1.text);
        int sof2Value = shr2.text.isEmpty ? 0 : int.parse(shr2.text);

        final data = {
          'Id': userId.toString(),
          'Pname': pname.text,
          'Beforeafter': beforeAfterValue,
          'Product': selectedProduct,
          'Sof1': sof1Value,
          'Sof2': sof2Value,
          'Images': imgdata,
          'Lat':lat.toString(),
          'Long':long.toString()
        };

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
                'Content-Type':
                    'application/json', // Set the content type based on your API's requirements
              },
            ),
          );

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.greenAccent,
                content: Text('Added to Main Database'),
              ),
            );
            // Navigator.pushNamed(context, '/');
            print('User added successfully');
            Navigator.pop(context);
            setState(() {});
          } else {
            print('Failed to add user: ${response.statusCode}');
          }
        } catch (e) {
          print('Error: $e');
        }
      } else {
        throw Exception('Form validation failed');
      }
    } else {
      int beforeAfterValue = selectedValue == 'Before' ? 0 : 1;
      final data = {
        'Id': userId.toString(),
        'Pname': pname.text,
        'Beforeafter': beforeAfterValue,
        'Product': selectedProduct,
        'Sof1': shr1.text,
        'Sof2': shr2.text,
        'Images': imgdata,
        'Lat':lat,
        'Long':long
      };
      // No internet connection, store data in the local database
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      await db.insert('offline_imgcap', data);
      print("addded to offline db");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.greenAccent,
          content: Text('Added to Offline Database'),
        ),
      );

      // View the data
      final tbdata = await dbHelper.getAllData();
      for (var row in tbdata) {
        print('id: ${row['id']}');
        print('Pname: ${row['Pname']}');
        print('B/F: ${row['Beforeafter']}');
        print('Product: ${row['Product']}');
        print('Sof1: ${row['Sof1']}');
        print('Sof2: ${row['Sof1']}');
        print('Image: ${row['Images']}');
         print('Lat: ${row['Lat']}');
          print('Long: ${row['Long']}');
        print('-------------------');
      }
      Navigator.pop(context);
      setState(() {});
    }
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
    print(lat.toString());
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your Location'),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(lat, long),
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
                ElevatedButton(
                    onPressed: () {
                      saveData();
                      Navigator.of(context).pop();
                    },
                    child: Text('Submit'))
              ],
            ),
          ],
        );
      },
    );
  }



  // InitState
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    makeRequest();
    checkConnectionQuality();
    getLocationData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Text(userId.toString()),
        title: Text(isConnected ? "Connected" : "Disconnected"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: pname,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Product'),
                ),
                SizedBox(
                  height: 15,
                ),
                // beforeafter
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue!;
                    });
                  },
                  items: <String>['Before', 'After'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 15,
                ),
                if (selectedValue == 'After')
                  Column(
                    children: [
                      TextField(
                        controller: shr1,
                        keyboardType:
                            TextInputType.number, // Show numeric keyboard
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Share of A',
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: shr2,
                        keyboardType:
                            TextInputType.number, // Show numeric keyboard
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Share of B',
                        ),
                      ),
                    ],
                  ),
                SizedBox(
                  height: 15,
                ),
                // Product dropdown
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedProduct,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedProduct = newValue!;
                    });
                  },
                  items: productNames.map((String product) {
                    return DropdownMenuItem<String>(
                      value: product,
                      child: Text(product),
                    );
                  }).toList(),
                ),
                // Image Capture
                ElevatedButton(
                  onPressed: () {
                    captureImage();
                  },
                  child: Text("Capture Image"),
                )

                // Captured Image Preview
                ,
                if (capturedImage != null)
                  Image.file(
                    capturedImage!,
                    width: 100, // Set the width as needed
                    height: 80, // Set the height as needed
                  ),

                SizedBox(
                  height: 15,
                ),
                SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: () {
                          _showMyDialog();
                        },
                        child: Text(
                          'Save',
                          style: TextStyle(fontSize: 20),
                        )))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
