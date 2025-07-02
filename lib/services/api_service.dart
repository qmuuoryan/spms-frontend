import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student_dashboard_model.dart';
import 'dart:io';
import 'package:path/path.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

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

  static Future<StudentDashboardData> getStudentDashboard(String token) async {
    final url = Uri.parse('$baseUrl/api/dashboard/student/');
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
      final data = json.decode(response.body);
      return StudentDashboardData.fromJson(data);
    } else {
      throw Exception('Failed to load student dashboard');
    }
  }
  
  static Future<void> submitProjectTopic(String token, String title, String description) async {
    final url = Uri.parse('$baseUrl/api/dashboard/student/submit-topic/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
    final body = jsonEncode({'title': title, 'description': description});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode != 201 && response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Submission failed');
    }
  }

  static Future<void> uploadProposal({
   required String token,
   required int projectId,
   required File file,
  }) async {
   final url = Uri.parse('$baseUrl/api/proposals/');
   final request = http.MultipartRequest('POST', url)
     ..headers['Authorization'] = 'Token $token'
     ..fields['project'] = projectId.toString()
     ..files.add(await http.MultipartFile.fromPath('file', file.path));

   final streamedResponse = await request.send();
   final response = await http.Response.fromStream(streamedResponse);

   if (response.statusCode != 201 && response.statusCode != 200) {
     final error = json.decode(response.body);
     throw Exception(error['detail'] ?? 'Proposal upload failed');
    }
  }

  static Future<List<Map<String, dynamic>>> getSubmittedTopics(String token) async {
    final url = Uri.parse('$baseUrl/api/lecturer/submitted-topics/');
    final response = await http.get(url, headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load submitted topics');
    }
  }

  static Future<void> approveTopic(String token, int projectId) async {
    final url = Uri.parse('$baseUrl/api/lecturer/topic/$projectId/approve/');
    final response = await http.post(url, headers: {
      'Authorization': 'Token $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to approve topic');
    }
  }

  static Future<void> rejectTopic(String token, int projectId) async {
    final url = Uri.parse('$baseUrl/api/lecturer/topic/$projectId/reject/');
    final response = await http.post(url, headers: {
      'Authorization': 'Token $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to reject topic');
    }
  }

  static Future<void> assignSupervisor(String token, int projectId, int supervisorId) async {
    final url = Uri.parse('$baseUrl/api/lecturer/topic/$projectId/assign-supervisor/');
    final response = await http.post(
     url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
     },
      body: jsonEncode({'supervisor_id': supervisorId}),
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['error'] ?? 'Failed to assign supervisor');
    }
  }

  static Future<List<Map<String, dynamic>>> getSupervisors(String token) async {
    final url = Uri.parse('$baseUrl/api/lecturer/supervisors/');
    final response = await http.get(url, headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load supervisors');
    }
  }

  static Future<List<dynamic>> getAssignedProjects(String token) async {
    final url = Uri.parse('$baseUrl/api/supervisor/assigned-projects/');
    final response = await http.get(url, headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    });

    print('Assigned Projects Status: ${response.statusCode}');
    print('Assigned Projects Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load assigned projects');
    }
  }


  static Future<List<dynamic>> getSupervisorProposals(String token) async {
  final url = Uri.parse('$baseUrl/api/supervisor/proposals/');
  final response = await http.get(url, headers: {
    'Authorization': 'Token $token',
    'Content-Type': 'application/json',
  });

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception("Failed to load proposals");
  }
}

static Future<void> reviewProposal({
  required String token,
  required int proposalId,
  required String status,
  required String feedback,
}) async {
  final url = Uri.parse('$baseUrl/api/supervisor/proposals/$proposalId/review/');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'status': status, 'feedback': feedback}),
  );

  if (response.statusCode != 200) {
    final error = json.decode(response.body);
    throw Exception(error['detail'] ?? 'Review failed');
  }
}



}
