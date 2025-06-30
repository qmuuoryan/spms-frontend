import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LecturerDashboard extends StatefulWidget {
  final String token;
  const LecturerDashboard({super.key, required this.token});

  @override
  State<LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  bool isLoading = true;
  List<dynamic> topics = [];
  List<dynamic> supervisors = [];
  Map<int, int?> selectedSupervisors = {}; 

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    setState(() => isLoading = true);

    try {
      final topicsData = await ApiService.getSubmittedTopics(widget.token);
      final supervisorData = await ApiService.getSupervisors(widget.token);

      setState(() {
        topics = topicsData;
        supervisors = supervisorData;

        
        for (var topic in topics) {
          selectedSupervisors.putIfAbsent(topic['id'], () => null);
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> approveTopic(int topicId) async {
    try {
      await ApiService.approveTopic(widget.token, topicId);
      fetchDashboardData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Approval failed: $e')),
      );
    }
  }

  Future<void> rejectTopic(int topicId) async {
    try {
      await ApiService.rejectTopic(widget.token, topicId);
      fetchDashboardData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rejection failed: $e')),
      );
    }
  }

  Future<void> assignSupervisor(int topicId, int supervisorId) async {
    try {
      await ApiService.assignSupervisor(widget.token, topicId, supervisorId);
      fetchDashboardData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assignment failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lecturer Dashboard')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchDashboardData,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  final topicId = topic['id'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Title: ${topic['title']}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("Description: ${topic['description']}"),
                          Text("Status: ${topic['status']}"),
                          Text("Student: ${topic['student_name']}"),
                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () => approveTopic(topicId),
                                child: const Text('Approve'),
                              ),
                              ElevatedButton(
                                onPressed: () => rejectTopic(topicId),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Reject'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          DropdownButtonFormField<int>(
                            value: selectedSupervisors[topicId],
                            decoration: const InputDecoration(labelText: 'Assign Supervisor'),
                            items: supervisors.map<DropdownMenuItem<int>>((supervisor) {
                              return DropdownMenuItem<int>(
                                value: supervisor['id'],
                                child: Text(supervisor['name'].isNotEmpty
                                    ? supervisor['name']
                                    : "Supervisor #${supervisor['id']}"),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSupervisors[topicId] = value;
                              });
                            },
                          ),

                          const SizedBox(height: 6),

                          ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Assign'),
                            onPressed: () {
                              final selected = selectedSupervisors[topicId];
                              if (selected != null) {
                                assignSupervisor(topicId, selected);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select a supervisor first')),
                                );
                              }
                            },
                          ),
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
