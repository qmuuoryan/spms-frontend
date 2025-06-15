import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(SPMSApp());
}

class SPMSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: LoginScreen(),
    );
  }
}
