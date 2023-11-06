import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';

class userre_page extends StatefulWidget {
  const userre_page({super.key});

  @override
  State<userre_page> createState() => _userre_pageState();
}

class _userre_pageState extends State<userre_page> {
  var name = TextEditingController();
  var place = TextEditingController();
  var address = TextEditingController();
  var username = TextEditingController();
  var pass = TextEditingController();
  var formkey = GlobalKey<FormState>();

// Validation
  void validate() {
    if (formkey.currentState!.validate()) {
    if (name.text.isEmpty ||
        place.text.isEmpty ||
        address.text.isEmpty ||
        username.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Please fill in all fields.'),
        ),
      );
    } else if (pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Password cannot be empty.'),
        ),
      );
    } else if (pass.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Password must be at least 3 characters long.'),
        ),
      );
    } else {
      // All fields are valid, add the user
      adduser();
    }
  }
  }

// Print Data
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
    print(name.text);

    final url =
        'https://10.0.2.2:7277/AddUser'; // Replace with your actual API URL

    // Create a Map containing the data to send in the request body
    final data = {
      'name': name.text,
      'place': place.text,
      'address': address.text,
      'username': username.text,
      'password': pass.text
    };

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
        Navigator.pushNamed(context, '/');
        print('User added successfully');
      } else {
        print('Failed to add user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: name,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Name'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: place,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Place'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: address,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Address'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: username,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Username'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: pass,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Password'),
                ),
              ),
              ElevatedButton(onPressed: validate, child: Text('Register'))
            ],
          ),
        ),
      ),
    );
  }
}
