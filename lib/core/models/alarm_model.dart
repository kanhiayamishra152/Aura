import 'dart:convert';

/// Model class representing a single alarm.
class AlarmModel {
  final int? id;
  final String time; // Format: "HH:mm"
  final String label;
  final List<int> repeatDays; // 1 = Monday, 7 = Sunday
  final bool isActive;
  final String? ringtone;

  AlarmModel({
    this.id,
    required this.time,
    required this.label,
    required this.repeatDays,
    this.isActive = true,
    this.ringtone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time,
      'label': label,
      'repeatDays': jsonEncode(repeatDays), // Store list as JSON string
      'isActive': isActive ? 1 : 0,
      'ringtone': ringtone,
    };
  }

  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      id: map['id'],
      time: map['time'],
      label: map['label'],
      repeatDays: List<int>.from(jsonDecode(map['repeatDays'])),
      isActive: map['isActive'] == 1,
      ringtone: map['ringtone'],
    );
  }

  AlarmModel copyWith({
    int? id,
    String? time,
    String? label,
    List<int>? repeatDays,
    bool? isActive,
    String? ringtone,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      time: time ?? this.time,
      label: label ?? this.label,
      repeatDays: repeatDays ?? this.repeatDays,
      isActive: isActive ?? this.isActive,
      ringtone: ringtone ?? this.ringtone,
    );
  }
}
