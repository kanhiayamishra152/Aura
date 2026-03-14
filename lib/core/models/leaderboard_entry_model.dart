import 'dart:convert';

class LeaderboardEntryModel {
  final String userId;
  final String username;
  final int totalStudySeconds;
  final int rank;
  final DateTime lastSynced;

  const LeaderboardEntryModel({
    required this.userId,
    required this.username,
    required this.totalStudySeconds,
    required this.rank,
    required this.lastSynced,
  });

  LeaderboardEntryModel copyWith({
    String? userId,
    String? username,
    int? totalStudySeconds,
    int? rank,
    DateTime? lastSynced,
  }) {
    return LeaderboardEntryModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      totalStudySeconds: totalStudySeconds ?? this.totalStudySeconds,
      rank: rank ?? this.rank,
      lastSynced: lastSynced ?? this.lastSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'totalStudySeconds': totalStudySeconds,
      'rank': rank,
      'lastSynced': lastSynced.millisecondsSinceEpoch,
    };
  }

  factory LeaderboardEntryModel.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntryModel(
      userId: map['userId'] as String,
      username: map['username'] as String,
      totalStudySeconds: map['totalStudySeconds'] as int,
      rank: map['rank'] as int,
      lastSynced: DateTime.fromMillisecondsSinceEpoch(map['lastSynced'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory LeaderboardEntryModel.fromJson(String source) => LeaderboardEntryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
