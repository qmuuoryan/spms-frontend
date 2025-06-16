import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/supervisor_dashboard.dart';
import 'index_page.dart';

void main() {
  runApp(const SPMSApp());
}

class SPMSApp extends StatelessWidget {
  const SPMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const IndexPage(),
    );
  }
}
