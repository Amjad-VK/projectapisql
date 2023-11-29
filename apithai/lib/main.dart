import 'dart:io';

import 'package:apithai/pages/admin_home.dart';
import 'package:apithai/pages/admin_viewuser.dart';
import 'package:apithai/pages/img_view.dart';
import 'package:apithai/pages/img_view_db.dart';
import 'package:apithai/pages/login.dart';
import 'package:apithai/pages/old.dart';
import 'package:apithai/pages/sp.dart';
import 'package:apithai/pages/user_homepage.dart';
import 'package:apithai/pages/user_imgcapture.dart';
import 'package:apithai/pages/user_registration.dart';
import 'package:apithai/pages/user_sync.dart';
import 'package:flutter/material.dart';


void main() {
  HttpClient httpClient = new HttpClient();
  httpClient.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const login_page(),
          '/adminhome': (context) => const adminhome_page(),
          '/viewusers': (context) => const viewusers_page(),
          '/userreg': (context) => const userre_page(),
          '/userimgcap': (context) => const userimgcapture_page(),
           '/usersync': (context) => const usersync_page(),
             '/imgview': (context) => const img_upload(),
             '/imgoff': (context) => const img_offline(),
             '/tst': (context) =>  LocationDisplay(),
                '/sp': (context) =>  stored_p(),
          
        });
  }
}
