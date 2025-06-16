import 'package:flutter/material.dart';
import '../widgets/base_register_form.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  String selectedRole = 'student';
  String? error;

  void handleRegister() async {
    try {
      final result = await ApiService.register(
        username: fullNameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: selectedRole,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registered as $selectedRole")),
      );

      
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SPMS Registration")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedRole,
              items: ['student', 'supervisor'].map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedRole = value!),
            ),
            BaseRegisterForm(
              emailController: emailController,
              passwordController: passwordController,
              fullNameController: fullNameController,
              role: selectedRole,
              onSubmit: handleRegister,
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
