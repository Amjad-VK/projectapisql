import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: stored_p(),
  ));
}

class stored_p extends StatefulWidget {
  const stored_p({super.key});

  @override
  State<stored_p> createState() => _stored_pState();
}

class _stored_pState extends State<stored_p> {
  var name = TextEditingController();
  Future<void> adduser() async {
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
        'https://10.0.2.2:7277/AddStudent'; // Replace with your actual API URL

    Map<String, dynamic> jsonData = {
      "name": name.text,
    };

    try {
      final response = await dio.post(
        url,
        data: jsonData,
        options: Options(
          headers: {
            'Content-Type': 'application/json', // Request content type
            'accept': '*/*', // Requested media type
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
        Navigator.pushNamed(context, '/');
        print('User added successfully');
      } else {
        print('Failed to add user: ${response.statusCode}');
        if (response.statusCode == 400) {
          print('Bad Request: ${response.data}');
        }
      }
    } catch (e) {
      if (e is DioException) {
        print('Dio Error Response:');
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      } else {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: name,
            ),
            ElevatedButton(onPressed: adduser, child: Text('Submit'))
          ],
        ),
      ),
    );
  }
}
