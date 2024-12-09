class Task {
  final String name;
  final String studymat;
  final String targetdate;
  final String duration;

  Task({
    required this.name,
    required this.studymat,
    required this.targetdate,
    required this.duration,
  });

  // Convert a Task object to a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'studymat': studymat,
      'target_date': targetdate,
      'duration': duration,
    };
  }

  // Create a Task object from a Firestore document snapshot
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      name: map['name'] ?? '',
      studymat: map['studymat'] ?? '',
      targetdate: map['target_date'] ?? '',
      duration: map['duration'] ?? '',
    );
  }
}
