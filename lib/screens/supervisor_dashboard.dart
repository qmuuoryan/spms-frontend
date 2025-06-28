import 'package:flutter/material.dart';

class SupervisorDashboard extends StatelessWidget {
  final String token;

  const SupervisorDashboard({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Supervisor Dashboard")),
      body: const Center(
        child: Text(
          "Welcome to the Supervisor Dashboard!",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
