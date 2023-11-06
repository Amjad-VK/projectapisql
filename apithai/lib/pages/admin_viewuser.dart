import 'dart:io';

import 'package:apithai/pages/admin_manageuser.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';

import 'dart:convert';

class viewusers_page extends StatefulWidget {
  const viewusers_page({super.key});

  @override
  State<viewusers_page> createState() => _viewusers_pageState();
}

class _viewusers_pageState extends State<viewusers_page> {
  List<dynamic> users = [];
  Dio dio = Dio();


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
      final response = await dio.get('https://10.0.2.2:7277/GetAllUsers');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.data) as List<dynamic>;

        setState(() {
          users = jsonResponse;
        });

        print('Request succeeded');
      } else {
        print('Request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    makeRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salesman'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user['Name'] ?? 'No Username'),
            onTap: () {
              // Navigate to the UserDetailsPage with the selected user's details
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailsPage(user: user),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
