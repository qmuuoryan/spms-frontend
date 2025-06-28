import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/login/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'username': email, 'password': password});

    final response = await http.post(url, headers: headers, body: body);
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Invalid credentials');
    } else {
      throw Exception('Unexpected error: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String role, 
  }) async {
    final url = Uri.parse('$baseUrl/api/register/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'username': username,
      'email': email,
      'password': password,
      'role': role,
    });

    final response = await http.post(url, headers: headers, body: body);
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Registration failed');
    }
  }

  
  static Future<Map<String, dynamic>> getStudentDashboard(String token) async {
    final url = Uri.parse('$baseUrl/api/student/dashboard/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    print("Dashboard Status: ${response.statusCode}");
    print("Dashboard Body: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load student dashboard');
    }
  }
}
