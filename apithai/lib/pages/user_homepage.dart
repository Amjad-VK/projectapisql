import 'package:flutter/material.dart';

class UserHomePage extends StatelessWidget {
  final String? username;
  final int? userId;

  UserHomePage({required this.username, required this.userId});

  @override
  Widget build(BuildContext context) {
    if (username == null || userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('User Home Page - Loading...'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Name:' + '$username' + '    ' + 'ID:' + '$userId'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () {Navigator.pushNamed(context, '/userimgcap');}, child: Text('Image Capture')),
            ElevatedButton(onPressed: () {Navigator.pushNamed(context, '/usersync');}, child: Text('Sync'))
            // Add the rest of your user home page content here
          ],
        ),
      ),
    );
  }
}
