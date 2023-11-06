// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'sqlhelper.dart';

class userimgcapture_page extends StatefulWidget {
  const userimgcapture_page({super.key});

  @override
  State<userimgcapture_page> createState() => _userimgcapture_pageState();
}

class _userimgcapture_pageState extends State<userimgcapture_page> {
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
// InternetStatus
  Future<bool> checkConnectionQuality() async {
    final connectivity = Connectivity();
    final connectivityResult = await connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.mobile) {
      print("Connected");
      setState(() {
        isConnected = true;
      });
    }

    // The user has no internet connection.
    print("Disconnected");
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

  Future<List<Map<String, Object?>>> saveData() async {
    if (isConnected == true) {
      if (formkey.currentState!.validate()) {
        print(pname.text);
        print(selectedValue.toString());
        print(selectedProduct.toString());

        String productName = pname.text;
        int beforeAfterValue = selectedValue == 'Before' ? 0 : 1;
        String selectedProductStr = selectedProduct.toString();

        final dbHelper = DatabaseHelper();
        final db = await dbHelper.database;
        var data = {
          'Id':10,
          'Pname': pname.text,
          'Beforeafter': beforeAfterValue,
          'Product': selectedProduct,
          'Sof1': shr1.text,
          'Sof2': shr2.text,
          'Images': imgdata
        };
        // await db.insert('offline_imgcap', data);

        final tbdata = await dbHelper.getAllData();
        for (var row in tbdata) {
          print('id: ${row['id']}');
          print('Pname: ${row['Pname']}');
          print('B/F: ${row['Beforeafter']}');
          print('Product: ${row['Product']}');
          print('Sof1: ${row['Sof1']}');
          print('Sof2: ${row['Sof1']}');
          print('Image: ${row['Images']}');
          print('-------------------');
        }
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
                content: Text('You Are Registered'),
              ),
            );
            // Navigator.pushNamed(context, '/');
            print('User added successfully');
          } else {
            print('Failed to add user: ${response.statusCode}');
          }
        } catch (e) {
          print('Error: $e');
        }
        return tbdata;
      } else {
        throw Exception('Form validation failed');
      }
    } else {
      throw Exception('No internet connection');
    }
  }

  // InitState
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    makeRequest();
    checkConnectionQuality();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                    width: 50, // Set the width as needed
                    height: 50, // Set the height as needed
                  ),
                  if (decodedImage != null)
                  Image.memory(
                    decodedImage!,
                    width: 50, // Set the width as needed
                    height: 50, // Set the height as needed
                  ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: saveData,
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
