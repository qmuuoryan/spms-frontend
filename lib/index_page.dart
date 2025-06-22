import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Senior Project Management System', style: TextStyle(fontweight: FontWeight: Fontweight.bold))),

         actions: [
            TextButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: const Text("Login", style: TextStyle(color: colors.white)),   
        )
      ],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Login'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  LoginScreen()),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Register'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  RegisterScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
