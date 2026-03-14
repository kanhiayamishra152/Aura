class TaskModel {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final int timeSpentSeconds;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.timeSpentSeconds = 0,
    required this.createdAt,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    int? timeSpentSeconds,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'timeSpentSeconds': timeSpentSeconds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: (map['isCompleted'] as int) == 1,
      timeSpentSeconds: map['timeSpentSeconds'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
