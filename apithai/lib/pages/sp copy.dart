import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: stored_p2(),
  ));
}

class stored_p2 extends StatefulWidget {
  const stored_p2({super.key});

  @override
  State<stored_p2> createState() => _stored_p2State();
}

class _stored_p2State extends State<stored_p2> {
  List<String> studentNames = [];
  var name = TextEditingController();
  Future<void> getuser() async {
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
        'https://10.0.2.2:7277/GetStudents'; // Replace with your actual API URL

    Map<String, dynamic> jsonData = {
      "name": name.text,
    };

    try {
      final response = await dio.get(
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
        setState(() {
          studentNames = (response.data as List).cast<String>();
        });
        print('GET successfully');
      } else {
        print('Failed');
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
      body: SafeArea(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: getuser, child: Text('Get')),
              Expanded(
                child: ListView.builder(
                  itemCount: studentNames.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(studentNames[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
