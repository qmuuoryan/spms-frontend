class SubmittedTopic {
  final int id;
  final String title;
  final String description;
  final String status;
  final String studentName;
  final int? assignedSupervisorId;

  SubmittedTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.studentName,
    this.assignedSupervisorId,
  });

  factory SubmittedTopic.fromJson(Map<String, dynamic> json) {
    return SubmittedTopic(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      studentName: json['student_name'] ?? 'Unknown',
      assignedSupervisorId: json['supervisor_id'],
    );
  }
}
