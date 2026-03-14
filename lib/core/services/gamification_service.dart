import 'package:flutter/foundation.dart';
import 'database_service.dart';
import '../models/study_session_model.dart';
import '../models/leaderboard_entry_model.dart';

/// Handles the logic for calculating points, XP, and leaderboard rankings.
class GamificationService {
  final DatabaseService _dbService;

  GamificationService(this._dbService);

  /// Calculates points based on session duration.
  /// Rule: 1 minute of focus = 10 points.
  /// Bonus: 50% extra points for sessions longer than 30 minutes.
  int calculatePointsForSession(StudySessionModel session) {
    if (!session.isCompleted) return 0;

    int minutes = (session.durationSeconds / 60).floor();
    int basePoints = minutes * 10;

    // Bonus calculation
    if (session.durationSeconds >= 1800) { 
      basePoints = (basePoints * 1.5).floor();
    }

    return basePoints;
  }

  /// Updates the local leaderboard entry after a session.
  Future<void> updateLeaderboardAfterSession(StudySessionModel session) async {
    try {
      int newPoints = calculatePointsForSession(session);
      
      // Fetch current entry
      LeaderboardEntryModel? currentEntry = await _dbService.getLocalLeaderboardEntry();
      
      if (currentEntry == null) {
        // Create a new entry if none exists
        currentEntry = LeaderboardEntryModel(
          id: 1,
          userName: "Local User", // In real app, fetch from user profile
          score: newPoints,
          totalTimeFocused: session.durationSeconds,
          lastUpdated: DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        // Update existing entry
        currentEntry.score += newPoints;
        currentEntry.totalTimeFocused += session.durationSeconds;
        currentEntry.lastUpdated = DateTime.now().millisecondsSinceEpoch;
      }

      await _dbService.upsertLocalLeaderboardEntry(currentEntry);
    } catch (e) {
      debugPrint("Error updating leaderboard: $e");
    }
  }

  /// Calculates the user's current level based on total score.
  /// Level up logic: Every 1000 points = 1 Level.
  int getUserLevel(int totalScore) {
    return (totalScore / 1000).floor() + 1;
  }

  /// Returns the progress towards the next level (0.0 to 1.0).
  double getLevelProgress(int totalScore) {
    int currentLevelPoints = (totalScore ~/ 1000) * 1000;
    int pointsInCurrentLevel = totalScore - currentLevelPoints;
    return pointsInCurrentLevel / 1000;
  }
}
