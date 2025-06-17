import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); 

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorMessage;

  void handleLogin() async {
    print("Login button pressed");
    print("Email: ${emailController.text}");
    print("Password: ${passwordController.text}");
    


    try {
      final result = await ApiService.login(
        emailController.text,
        passwordController.text,
      );
      print("Login Response: $result");

      final token = result['token'];
      final role = result['role'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful! Role: $role')),
      );

      if (role == 'student') {
        Navigator.pushReplacementNamed(context, '/student_home');
      } 
      else if (role == 'supervisor') {
        Navigator.pushReplacementNamed(context, '/supervisor_home');
      } 
      else if (role == 'lecturer'){
        Navigator.pushReplacementNamed(context, '/lecturer_home');
      }
      else if (role == 'admin'){
        Navigator.pushReplacementNamed(context, '/admin_home');
      }
      else {
        setState(() => errorMessage = "Unknown role: $role");
      }
    } catch (e) {
      print("Login failed: $e");
      setState(() => errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SPMS Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleLogin,
              child: const Text("Login"),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
