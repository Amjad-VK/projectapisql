import 'package:flutter/material.dart';

class adminhome_page extends StatefulWidget {
  const adminhome_page({super.key});

  @override
  State<adminhome_page> createState() => _adminhome_pageState();
}

class _adminhome_pageState extends State<adminhome_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () {
               Navigator.pushNamed(context, '/viewusers');
            }, child: Text('User Approval'))
          ],
        ),
      ),
    );
  }
}
