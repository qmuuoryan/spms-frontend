import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const IndexPage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/student_home': (context) => const Scaffold(body: Center(child: Text("Student Dashboard Placeholder"))),
        '/supervisor_home': (context) => const Scaffold(body: Center(child: Text("Supervisor Dashboard Placeholder"))),
        '/lecturer_home': (context) => const Scaffold(body: Center(child: Text("Lecturer Dashboard Placeholder"))),
      },
    );
  }
}
