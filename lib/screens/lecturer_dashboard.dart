// Redesigned LecturerDashboard to match StudentDashboard style
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LecturerDashboard extends StatefulWidget {
  final String token;
  const LecturerDashboard({super.key, required this.token});

  @override
  State<LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> with TickerProviderStateMixin {
  bool isLoading = true;
  List<dynamic> topics = [];
  List<dynamic> supervisors = [];
  Map<int, int?> selectedSupervisors = {};

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
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    fetchDashboardData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        _animationController.forward();
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: \$e')),
      );
    }
  }

  Future<void> approveTopic(int topicId) async {
    try {
      await ApiService.approveTopic(widget.token, topicId);
      fetchDashboardData();
    } catch (e) {
      _showError('Approval failed: \$e');
    }
  }

  Future<void> rejectTopic(int topicId) async {
    try {
      await ApiService.rejectTopic(widget.token, topicId);
      fetchDashboardData();
    } catch (e) {
      _showError('Rejection failed: \$e');
    }
  }

  Future<void> assignSupervisor(int topicId, int supervisorId) async {
    try {
      await ApiService.assignSupervisor(widget.token, topicId, supervisorId);
      fetchDashboardData();
    } catch (e) {
      _showError('Assignment failed: \$e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00695C), Color(0xFF004D40)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : RefreshIndicator(
                  onRefresh: fetchDashboardData,
                  color: Colors.white,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.dashboard,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  "Lecturer Dashboard",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ...topics.map((topic) {
                            final topicId = topic['id'];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    topic['title'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF424242),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(topic['description'], style: const TextStyle(color: Colors.black87)),
                                  const SizedBox(height: 8),
                                  _buildInfoRow('Status', topic['status'], Icons.info_outline),
                                  _buildInfoRow('Student', topic['student_name'], Icons.person),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => approveTopic(topicId),
                                        icon: const Icon(Icons.check, size: 18),
                                        label: const Text('Approve'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green.shade600,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => rejectTopic(topicId),
                                        icon: const Icon(Icons.close, size: 18),
                                        label: const Text('Reject'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade600,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<int>(
                                    value: selectedSupervisors[topicId],
                                    decoration: const InputDecoration(
                                      labelText: 'Assign Supervisor',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: supervisors.map<DropdownMenuItem<int>>((supervisor) {
                                      return DropdownMenuItem<int>(
                                        value: supervisor['id'],
                                        child: Text(supervisor['name']),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSupervisors[topicId] = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.send, size: 18),
                                    label: const Text('Assign'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00695C),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    onPressed: () {
                                      final selected = selectedSupervisors[topicId];
                                      if (selected != null) {
                                        assignSupervisor(topicId, selected);
                                      } else {
                                        _showError('Please select a supervisor first');
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            "\$label:",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
