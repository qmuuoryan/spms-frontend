import 'package:flutter/material.dart';

class BaseRegisterForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController fullNameController;
  final String role;
  final Function onSubmit;

  const BaseRegisterForm({super.key, 
    required this.emailController,
    required this.passwordController,
    required this.fullNameController,
    required this.role,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Register as $role", style: TextStyle(fontSize: 20)),
        TextField(controller: fullNameController, decoration: InputDecoration(labelText: "Full Name")),
        TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
        TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => onSubmit(),
          child: Text("Register"),
        ),
      ],
    );
  }
}
