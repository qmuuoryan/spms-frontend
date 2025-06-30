import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Divider(thickness: 1, color: Color.fromARGB(255, 231, 236, 236)),
        SizedBox(height: 8),
        Text("© 2025 SPMS. All rights reserved.", style: TextStyle(fontSize: 14)),
        SizedBox(height: 4),
        Text("Developed by https://github.com/qmuuoryan", style: TextStyle(fontSize: 12)),
        SizedBox(height: 16),
      ],
    );
  }
}
