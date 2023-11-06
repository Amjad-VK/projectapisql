import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserDetailsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  UserDetailsPage({required this.user});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  @override
  void initState() {
    super.initState();
  }

  void approveUser() async {
    Dio dio = Dio();

    // Disable SSL certificate verification
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      return HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };
    };

    try {
      final response = await dio.put(
        'https://10.0.2.2:7277/UpdateStatus/${widget.user['Id']}',
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.greenAccent,
            content: Text('Acces Granted'),
          ),
        );
        print("Access Updated");
      } else {
        // Handle specific Dio errors here
        if (response.statusCode == 400) {
          print('Dio Error: Bad Request');
          // You can also extract and print the error message if available in the response.
          // Example: print('Error Message: ${response.data['message']}');
        } else {
          print('Dio Error: ${response.statusCode} - ${response.data}');
        }
      }
    } catch (e) {
      // Handle network errors, if any
      if (e is DioException) {
        print('Dio Error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        print('Network error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Name: ${widget.user['Name']}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Place: ${widget.user['Place']}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Address: ${widget.user['Address']}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Username: ${widget.user['Username']}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Password: ${widget.user['Password']}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Status: ${widget.user['Status']}',
              style: TextStyle(
                fontSize: 20,
               color: widget.user['Status'] == 0 ? Colors.red : Colors.green,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                approveUser();
              },
              child: Text('Approve'),
            ),
            // Add more user details here
          ],
        ),
      ),
    );
  }
}
