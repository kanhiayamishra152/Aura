import 'dart:convert';

class StudySessionModel {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int plannedDurationSeconds;
  final int actualDurationSeconds;
  final bool isCompleted;

  const StudySessionModel({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.plannedDurationSeconds,
    required this.actualDurationSeconds,
    required this.isCompleted,
  });

  StudySessionModel copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? plannedDurationSeconds,
    int? actualDurationSeconds,
    bool? isCompleted,
  }) {
    return StudySessionModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedDurationSeconds: plannedDurationSeconds ?? this.plannedDurationSeconds,
      actualDurationSeconds: actualDurationSeconds ?? this.actualDurationSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'plannedDurationSeconds': plannedDurationSeconds,
      'actualDurationSeconds': actualDurationSeconds,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory StudySessionModel.fromMap(Map<String, dynamic> map) {
    return StudySessionModel(
      id: map['id'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      endTime: map['endTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int) : null,
      plannedDurationSeconds: map['plannedDurationSeconds'] as int,
      actualDurationSeconds: map['actualDurationSeconds'] as int,
      isCompleted: (map['isCompleted'] as int) == 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory StudySessionModel.fromJson(String source) => StudySessionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
