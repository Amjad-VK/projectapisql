import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:apithai/pages/sqlhelper.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';

class img_offline extends StatefulWidget {
  const img_offline({super.key});

  @override
  State<img_offline> createState() => _img_offlineState();
}

class _img_offlineState extends State<img_offline> {
  Dio dio = Dio();
  late List<Map<String, dynamic>> resultData;
  String? image;

  late Uint8List imageBytes;

  Future<Map<String, dynamic>?> getImageById(int id) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final results =
        await db.query('offline_imgcap', where: 'id = ?', whereArgs: [id]);

    if (results.isNotEmpty) {
      // Return the first record found (there should be only one)
      print(results);
      setState(() {
        resultData = results;
      });
      final List<String> imagesList =
          resultData.map((data) => data['Images'] as String).toList();
      print("Data: $imagesList[0]");
      imageBytes = Uint8List.fromList(base64Decode(imagesList[0]));
    }

    // Return null if no record with the specified ID is found
    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getImageById(21);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Image"),
          Image.memory(imageBytes,width: 200,)
        ],
      )),
    );
  }
}
