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
    print("Supervisor token: ${widget.token}");
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    setState(() => isLoading = true);

    try {
      final projects = await ApiService.getAssignedProjects(widget.token);
      print("Fetched assigned projects: $projects");

      setState(() {
        assignedProjects = projects;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching assigned projects: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Supervisor Dashboard")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : assignedProjects.isEmpty
              ? const Center(child: Text("No assigned projects yet."))
              : RefreshIndicator(
                  onRefresh: fetchDashboardData,
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
                              Text("Title: ${project['title']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("Description: ${project['description']}"),
                              Text("Status: ${project['status']}"),
                              Text("Submitted At: ${project['submitted_at']}"),
                              Text("Student Name: ${project['student_name']}"),
                              Text("Reg No: ${project['student_reg_no']}"),
                              const SizedBox(height: 8),

                              
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
