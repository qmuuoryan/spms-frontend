class Project {
  final int id;
  final String title;
  final String description;
  final String status;
  final String submittedAt;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.submittedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      submittedAt: json['submitted_at'],
    );
  }
}

class StudentDashboardData {
  final String registrationNumber;
  final String fullName;
  final Project? project;

  StudentDashboardData({
    required this.registrationNumber,
    required this.fullName,
    this.project,
  });

  factory StudentDashboardData.fromJson(Map<String, dynamic> json) {
    return StudentDashboardData(
      registrationNumber: json['registration_number'],
      fullName: json['full_name'],
      project: json['project'] != null ? Project.fromJson(json['project']) : null,
    );
  }
}
