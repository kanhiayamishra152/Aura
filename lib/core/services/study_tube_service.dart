import 'package:flutter/foundation.dart';

/// Manages the whitelist logic for Study Tube feature.
/// Ensures only educational content is accessible.
class StudyTubeService {
  // Pre-defined list of educational channel IDs.
  // In a production app, this would come from a remote config or backend.
  static const List<String> _whitelistedChannelIds = [
    'UCJ0-OtVpF0wOKEqT2Z1HEtA', // ElectroBOOM
    'UC6107grRI4m0o2-exgo1gig', // Mathologer
    'UCSHZKyawb77iyD7GPsdcOlA', // Science ABC
    'UC4JX40jDee_tINbkjycV4Sg', // Tutorial channels
    'UCwRXb5dUK4cvsHbx-rGDeSg', // MIT OpenCourseWare
    'UCi0E7e_Knv1oHBwZW9JH6Gg', // Physics Wallah (Example localized content)
  ];

  // List of keywords allowed in search queries
  static const List<String> _allowedKeywords = [
    'math', 'physics', 'chemistry', 'biology', 'history', 
    'coding', 'programming', 'science', 'education', 'lecture',
    'tutorial', 'algorithm', 'flutter', 'dev'
  ];

  /// Checks if a channel ID is whitelisted.
  bool isChannelAllowed(String channelId) {
    return _whitelistedChannelIds.contains(channelId);
  }

  /// Sanitizes user search query to ensure it aligns with educational content.
  /// Returns null if the query seems irrelevant or inappropriate.
  String? sanitizeSearchQuery(String query) {
    final lowerQuery = query.toLowerCase().trim();
    
    // Check if query contains at least one educational keyword
    bool hasValidKeyword = _allowedKeywords.any((keyword) => lowerQuery.contains(keyword));
    
    if (hasValidKeyword) {
      return query;
    }
    return null; // Block the search
  }

  /// Returns the list of whitelisted channel IDs for the UI to display suggestions.
  List<String> getWhitelistedChannels() {
    return _whitelistedChannelIds;
  }
}
