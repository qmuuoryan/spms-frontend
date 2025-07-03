import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SupervisorDashboard extends StatefulWidget {
  final String token;

  const SupervisorDashboard({super.key, required this.token});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard>
    with TickerProviderStateMixin {
  bool isLoading = true;
  List<dynamic> assignedProjects = [];
  final Map<int, TextEditingController> feedbackControllers = {};

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    fetchAssignedProjects();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in feedbackControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> fetchAssignedProjects() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getAssignedProjects(widget.token);
      setState(() {
        assignedProjects = data;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> approveOrRejectProposal({
    required int proposalId,
    required bool approve,
    required String feedback,
  }) async {
    try {
      if (approve) {
        await ApiService.approveProposal(widget.token, proposalId, feedback);
      } else {
        await ApiService.rejectProposal(widget.token, proposalId, feedback);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? "Proposal approved." : "Proposal rejected.")),
      );

      fetchAssignedProjects(); // Refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
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
              ? _buildLoadingState()
              : RefreshIndicator(
                  onRefresh: fetchAssignedProjects,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 30),
                            ...assignedProjects.map(_buildProjectCard).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text("Loading your dashboard...", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: const [
        Icon(Icons.dashboard, color: Colors.white, size: 28),
        SizedBox(width: 16),
        Text(
          "Supervisor Dashboard",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProjectCard(dynamic project) {
    List<dynamic> proposals = project['proposals'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProjectDetailRow("Student", project['student_name']),
          _buildProjectDetailRow("Reg No", project['student_reg_no']),
          _buildProjectDetailRow("Title", project['title']),
          _buildProjectDetailRow("Description", project['description']),
          _buildProjectDetailRow("Status", project['status']),
          _buildProjectDetailRow("Submitted", project['submitted_at']),
          const SizedBox(height: 12),
          const Text(
            "Proposals",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          ...proposals.map((proposal) => _buildProposalCard(proposal)).toList(),
        ],
      ),
    );
  }

  Widget _buildProjectDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value?.toString() ?? '')),
        ],
      ),
    );
  }

  Widget _buildProposalCard(dynamic proposal) {
    final proposalId = proposal['id'];
    final status = proposal['status'];
    final fileName = proposal['original_filename'] ?? "No file";
    final fileUrl = proposal['proposal_file'];
    final feedback = proposal['feedback'] ?? "";

    feedbackControllers.putIfAbsent(proposalId, () => TextEditingController(text: feedback));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("File: $fileName", style: const TextStyle(fontWeight: FontWeight.w500)),
          Text("Status: $status"),
          const SizedBox(height: 8),
          if (fileUrl != null)
            TextButton.icon(
              onPressed: () async {
                final uri = Uri.parse(fileUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Could not open file.")),
                  );
                }
              },
              icon: const Icon(Icons.download, size: 18),
              label: const Text("Download File"),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: feedbackControllers[proposalId],
            decoration: const InputDecoration(
              hintText: "Write feedback...",
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text("Approve"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  approveOrRejectProposal(
                    proposalId: proposalId,
                    approve: true,
                    feedback: feedbackControllers[proposalId]?.text ?? "",
                  );
                },
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.close),
                label: const Text("Reject"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  approveOrRejectProposal(
                    proposalId: proposalId,
                    approve: false,
                    feedback: feedbackControllers[proposalId]?.text ?? "",
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
