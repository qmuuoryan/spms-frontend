import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/supervisor_dashboard.dart';
import 'screens/lecturer_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'index_page.dart';

void main() {
  runApp(const SPMSApp());
}

class SPMSApp extends StatelessWidget {
  const SPMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Senior Project Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const IndexPage(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/student_home': (context) => StudentDashboard(),
        '/supervisor_home': (context) => SupervisorDashboard(),
        '/lecturer_home': (context) => LecturerDashboard(),   
        '/admin_home': (context) => AdminDashboard(), 

      },
    );
  }
}
