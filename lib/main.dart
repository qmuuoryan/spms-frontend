import 'package:flutter/material.dart';
import 'index_page.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/supervisor_dashboard.dart';
import 'screens/lecturer_dashboard.dart';
import 'screens/admin_dashboard.dart';

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
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/student_home': (_) => const StudentDashboard(),
        '/supervisor_home': (_) => const SupervisorDashboard(),
        '/lecturer_home': (_) => const LecturerDashboard(),
        '/admin_home': (_) => const AdminDashboard(),
      },
    );
  }
}
