import 'package:flutter/material.dart';

class LecturerDashboard extends StatelessWidget {
  final String token;

  const LecturerDashboard({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lecturer Dashboard")),
      body: const Center(
        child: Text(
          "Welcome to the Lecturer Dashboard!",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
