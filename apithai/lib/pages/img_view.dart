import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';

class img_upload extends StatefulWidget {
  const img_upload({super.key});

  @override
  State<img_upload> createState() => _img_uploadState();
}

class _img_uploadState extends State<img_upload> {
  
  Dio dio = Dio();
String? image;
String? pname;
late Uint8List imageBytes;

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
      final response = await dio.get('https://10.0.2.2:7277/GetImageAndName/10');

      if (response.statusCode == 200) {
        final jsonResponse = response.data;

         

      if (jsonResponse is Map<String, dynamic>) {
        setState(() {
          image = jsonResponse['image'] as String;
          pname = jsonResponse['pname'] as String;
          imageBytes = Uint8List.fromList(base64Decode(image.toString()));
        });

          print('Request succeeded: images=$image, pname=$pname');
        } else {
          print('Invalid JSON response');
        }
      } else {
        print('Request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    makeRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(pname.toString()),
        Image.memory(imageBytes)
        ],
      )),
    );
  }
}
