import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'study_session_model.dart';

/// Provides processed statistical data derived from raw study sessions.
/// This acts as a bridge between the raw database and the UI charts.
class AnalyticsService {
  final DatabaseService _dbService;

  AnalyticsService(this._dbService);

  /// Calculates the total focus time for the current week (Monday to Sunday).
  Future<int> getWeeklyFocusTimeInSeconds() async {
    final now = DateTime.now();
    // Find the start of the current week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final mondayMidnight = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    final startTimestamp = mondayMidnight.millisecondsSinceEpoch;
    final endTimestamp = now.millisecondsSinceEpoch;

    return await _dbService.getTotalFocusTime(startTimestamp, endTimestamp);
  }

  /// Returns a list of focus durations (in seconds) for the last 7 days.
  /// Useful for drawing a weekly bar chart.
  Future<List<int>> getDailyFocusForWeek() async {
    List<int> dailyDurations = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final duration = await _dbService.getTotalFocusTime(
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      );
      dailyDurations.add(duration);
    }
    return dailyDurations;
  }

  /// Calculates a simple productivity score (0-100) based on today's goal.
  /// Assume a daily goal of 2 hours (7200 seconds) for now.
  Future<double> getDailyProductivityScore() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final totalSeconds = await _dbService.getTotalFocusTime(
      startOfDay.millisecondsSinceEpoch,
      endOfDay.millisecondsSinceEpoch,
    );

    const dailyGoalSeconds = 7200; // 2 Hours
    double score = (totalSeconds / dailyGoalSeconds) * 100;
    return score.clamp(0.0, 100.0);
  }

  /// Gets the most productive time of day (Morning, Afternoon, Evening, Night).
  Future<String> getPeakProductivityTime() async {
    final sessions = await _dbService.getAllStudySessions();
    if (sessions.isEmpty) return "Not enough data";

    Map<String, int> timeBuckets = {
      'Morning': 0,    // 6am - 12pm
      'Afternoon': 0,  // 12pm - 6pm
      'Evening': 0,    // 6pm - 12am
      'Night': 0,      // 12am - 6am
    };

    for (var session in sessions) {
      final hour = DateTime.fromMillisecondsSinceEpoch(session.startTime).hour;
      String bucket;
      if (hour >= 6 && hour < 12) bucket = 'Morning';
      else if (hour >= 12 && hour < 18) bucket = 'Afternoon';
      else if (hour >= 18 && hour < 24) bucket = 'Evening';
      else bucket = 'Night';

      timeBuckets[bucket] = timeBuckets[bucket]! + session.durationSeconds;
    }

    var sortedBuckets = timeBuckets.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sortedBuckets.first.key;
  }
}
