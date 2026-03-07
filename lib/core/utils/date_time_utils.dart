import 'package:intl/intl.dart';

/// Utility class for all date and time formatting operations.
/// Battery Optimized:
/// - Uses static methods only - no instance creation needed.
/// - DateFormat objects created inline to avoid holding memory.
/// - Pure functions with no side effects.
class DateTimeUtils {
  DateTimeUtils._();

  /// Format seconds into HH:MM:SS string.
  /// Used by Timer and Stopwatch displays.
  static String formatSeconds(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;

    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Format seconds into readable text like "2h 30m".
  /// Used in session summaries and leaderboard.
  static String formatSecondsToReadable(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;

    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${totalSeconds}s';
    }
  }

  /// Format DateTime to display date like "25 Dec 2024".
  static String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  /// Format DateTime to display time like "09:30 AM".
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  /// Format DateTime to display full like "25 Dec 2024, 09:30 AM".
  static String formatFull(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  /// Format DateTime to display day name like "Monday".
  static String formatDayName(DateTime dateTime) {
    return DateFormat('EEEE').format(dateTime);
  }

  /// Format DateTime to short date like "25/12/24".
  static String formatShortDate(DateTime dateTime) {
    return DateFormat('dd/MM/yy').format(dateTime);
  }

  /// Get greeting based on current time of day.
  static String getGreeting() {
    final int hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  /// Check if two dates are the same day.
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if the given date is today.
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if the given date is yesterday.
  static bool isYesterday(DateTime date) {
    final DateTime yesterday = DateTime.now().subtract(
      const Duration(days: 1),
    );
    return isSameDay(date, yesterday);
  }

  /// Get relative time string like "2 hours ago", "Just now".
  static String getRelativeTime(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final int minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final int hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final int days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return formatDate(dateTime);
    }
  }

  /// Convert hours and minutes to total seconds.
  /// Used when user sets custom timer duration.
  static int toSeconds({int hours = 0, int minutes = 0}) {
    return (hours * 3600) + (minutes * 60);
  }

  /// Get start of today (midnight).
  static DateTime startOfToday() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Get start of this week (Monday).
  static DateTime startOfWeek() {
    final DateTime now = DateTime.now();
    final int weekday = now.weekday;
    return DateTime(now.year, now.month, now.day - (weekday - 1));
  }

  /// Get start of this month.
  static DateTime startOfMonth() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }
}
