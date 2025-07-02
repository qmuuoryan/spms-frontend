import 'package:flutter/material.dart';
import 'package:spms_frontend/screens/lecturer_dashboard.dart';
import 'package:spms_frontend/screens/student_dashboard.dart';
import 'package:spms_frontend/screens/supervisor_dashboard.dart';
import 'package:spms_frontend/services/google_auth_service.dart';
import '../widgets/base_register_form.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  String selectedRole = 'student';
  String? error;
  bool isGoogleLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void handleRegister() async {
    try {
      final result = await ApiService.register(
        username: fullNameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: selectedRole,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registered as $selectedRole"),
          backgroundColor: const Color(0xFF26A69A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  void signInWithGoogle() async {
    setState(() => isGoogleLoading = true);
    
    try {
      final result = await GoogleAuthService.signInWithGoogle();
      
      if (result['success']) {
        final token = result['token'];
        final role = result['role'];
        final isNewUser = result['isNewUser'];
        
        if (isNewUser) {
          _showSuccessSnackBar('Welcome! Account created successfully');
        } else {
          _showSuccessSnackBar('Welcome back!');
        }
        
        _navigateToRoleDashboard(role, token);
      } else {
        _showErrorSnackBar(result['error']);
      }
    } catch (e) {
      _showErrorSnackBar('Google sign-in failed: ${e.toString()}');
    } finally {
      setState(() => isGoogleLoading = false);
    }
  }

  void _navigateToRoleDashboard(String role, String token) {
    Widget dashboard;
    
    switch (role) {
      case 'student':
        dashboard = StudentDashboard(token: token);
        break;
      case 'supervisor':
        dashboard = SupervisorDashboard(token: token);
        break;
      case 'lecturer':
        dashboard = LecturerDashboard(token: token);
        break;
      default:
        dashboard = StudentDashboard(token: token);
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => dashboard),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF00695C),
              Color(0xFF004D40),
              Color(0xFF00251A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  
                  _buildHeader(),
                  
                  const SizedBox(height: 40),
                  
                  
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildRegistrationForm(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
      
        const Icon(
          Icons.person_add_alt_1,
          size: 64,
          color: Colors.white,
        ),
        
        const SizedBox(height: 16),
        
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFB2DFDB)],
          ).createShader(bounds),
          child: const Text(
            "Create Account",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          "Join SPMS and manage your projects efficiently",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          _buildRoleSelector(),
          
          const SizedBox(height: 24),
          
          
          BaseRegisterForm(
            emailController: emailController,
            passwordController: passwordController,
            fullNameController: fullNameController,
            role: selectedRole,
            onSubmit: handleRegister,
          ),
          
          
          if (error != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "or",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),

          const SizedBox(height: 24),

          // Google Sign-In Button
          ElevatedButton.icon(
            onPressed: isGoogleLoading ? null : signInWithGoogle,
            icon: Image.asset(
              'assets/icons/g.png', // Make sure this file exists in your assets
              height: 24,
              width: 24,
            ),
            label: isGoogleLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    "Sign in with Google",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              shadowColor: Colors.black45,
            ),
          ),


          const SizedBox(height: 24),


          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Already have an account? ",
                style: TextStyle(color: Colors.grey),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: Color(0xFF00695C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Role",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF424242),
          ),
        ),
        
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: DropdownButton<String>(
            value: selectedRole,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00695C)),
            items: [
              {'value': 'student', 'label': 'Student', 'icon': Icons.school},
              {'value': 'supervisor', 'label': 'Supervisor', 'icon': Icons.supervisor_account},
              {'value': 'lecturer', 'label': 'Lecturer', 'icon': Icons.person},
              {'value': 'admin', 'label': 'Admin', 'icon': Icons.admin_panel_settings},
            ].map((role) {
              return DropdownMenuItem(
                value: role['value'] as String,
                child: Row(
                  children: [
                    Icon(
                      role['icon'] as IconData,
                      size: 20,
                      color: const Color(0xFF00695C),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      role['label'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF424242),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => selectedRole = value!),
          ),
        ),
      ],
    );
  }
}