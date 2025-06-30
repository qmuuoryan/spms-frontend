import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SupervisorDashboard extends StatefulWidget {
  final String token;

  const SupervisorDashboard({super.key, required this.token});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  bool isLoading = true;
  List<dynamic> assignedProjects = [];

  @override
  void initState() {
    super.initState();
    fetchAssignedProjects();
  }

  Future<void> fetchAssignedProjects() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getAssignedProjects(widget.token);
      setState(() {
        assignedProjects = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Supervisor Dashboard")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchAssignedProjects,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: assignedProjects.length,
                itemBuilder: (context, index) {
                  final project = assignedProjects[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Student: ${project['student_name']}"),
                          Text("Reg No: ${project['student_reg_no']}"),
                          const SizedBox(height: 8),
                          Text("Title: ${project['title']}",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("Description: ${project['description']}"),
                          Text("Status: ${project['status']}"),
                          Text("Submitted: ${project['submitted_at']}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
