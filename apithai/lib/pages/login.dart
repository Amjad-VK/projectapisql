// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:apithai/pages/user_homepage.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';

class login_page extends StatefulWidget {
  const login_page({super.key});

  @override
  State<login_page> createState() => _login_pageState();
}

class _login_pageState extends State<login_page> {
  var username = TextEditingController();
  var pass = TextEditingController();
  final dio = Dio();
  // Chech Credentials
  Future<Map<String, dynamic>?> checkCredentials() async {
    try {
      // Disable SSL certificate verification
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        return HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) {
            return true;
          };
      };

      final response = await dio.get(
        'https://10.0.2.2:7277/CheckUserCredentialsandst',
        queryParameters: {
          'username': username.text,
          'password': pass.text,
        },
      );

      if (response.statusCode == 200) {
        print(response.data);
        final responseData = response.data;
        return responseData; // Return the response data
      } else {
        
        return null; // Handle other status codes if needed
      }
    } catch (e) {
      print('Dio Error: $e');
      return null; // Handle network errors
    }
  }

  // Check login
  void checkLogin() async {
    final response = await checkCredentials();

    if (response != null && response['status'] == 1) {
      // Credentials are correct, navigate to the user home page
      final userId = response['id'];
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserHomePage(username: username.text, userId: userId),
      ),
    );
    } else {
      // Show a Snackbar for incorrect credentials
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Invalid Credentials'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: username,
              decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(),
                  hintText: 'Username'),
            ),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: pass,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Password'),
            ),
            ElevatedButton(onPressed: checkLogin, child: Text("Login")),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/userreg');
                },
                child: Text('Not a User?Register Now'))
          ],
        ),
      ),
    );
  }
}
