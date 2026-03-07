// lib/core/services/storage_service.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._internal();

  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  static StorageService get instance => _instance;

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyMasterVolume = 'master_volume';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserAvatar = 'user_avatar';
  static const String keyTotalFocusMinutes = 'total_focus_minutes';
  static const String keyTotalSessions = 'total_sessions';
  static const String keyCurrentStreak = 'current_streak';
  static const String keyBestStreak = 'best_streak';
  static const String keyLastSessionDate = 'last_session_date';
  static const String keyDefaultFocusDuration = 'default_focus_duration';
  static const String keyBlockedApps = 'blocked_apps';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyUserRank = 'user_rank';
  static const String keyPreviousRank = 'previous_rank';
  static const String keyLastSyncTimestamp = 'last_sync_timestamp';

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      debugPrint('StorageService: Initialized successfully.');
    } catch (e) {
      debugPrint('StorageService: Error during initialization - $e');
      _isInitialized = false;
    }
  }

  // -------------------------------------------------------
  // String Operations
  // -------------------------------------------------------

  Future<bool> setString(String key, String value) async {
    try {
      if (_prefs == null) {
        await initialize();
      }
      return await _prefs!.setString(key, value);
    } catch (e) {
      debugPrint('StorageService: Error setting string $key - $e');
      return false;
    }
  }

  String getString(String key, {String defaultValue = ''}) {
    try {
      if (_prefs == null) {
        return defaultValue;
      }
      return _prefs!.getString(key) ?? defaultValue;
    } catch (e) {
      debugPrint('StorageService: Error getting string $key - $e');
      return defaultValue;
    }
  }

  // -------------------------------------------------------
  // Integer Operations
  // -------------------------------------------------------

  Future<bool> setInt(String key, int value) async {
    try {
      if (_prefs == null) {
        await initialize();
      }
      return await _prefs!.setInt(key, value);
    } catch (e) {
      debugPrint('StorageService: Error setting int $key - $e');
      return false;
    }
  }

  int getInt(String key, {int defaultValue = 0}) {
    try {
      if (_prefs == null) {
        return defaultValue;
      }
      return _prefs!.getInt(key) ?? defaultValue;
    } catch (e) {
      debugPrint('StorageService: Error getting int $key - $e');
      return defaultValue;
    }
  }

  // -------------------------------------------------------
  // Double Operations
  // -------------------------------------------------------

  Future<bool> setDouble(String key, double value) async {
    try {
      if (_prefs == null) {
        await initialize();
      }
      return await _prefs!.setDouble(key, value);
    } catch (e) {
      debugPrint('StorageService: Error setting double $key - $e');
      return false;
    }
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      if (_prefs == null) {
        return defaultValue;
      }
      return _prefs!.getDouble(key) ?? defaultValue;
    } catch (e) {
      debugPrint('StorageService: Error getting double $key - $e');
      return defaultValue;
    }
  }

  // -------------------------------------------------------
  // Boolean Operations
  // -------------------------------------------------------

  Future<bool> setBool(String key, bool value) async {
    try {
      if (_prefs == null) {
        await initialize();
      }
      return await _prefs!.setBool(key, value);
    } catch (e) {
      debugPrint('StorageService: Error setting bool $key - $e');
      return false;
    }
  }

  bool getBool(String key, {bool defaultValue = false}) {
    try {
      if (_prefs == null) {
        return defaultValue;
      }
      return _prefs!.getBool(key) ?? defaultValue;
    } catch (e) {
      debugPrint('StorageService: Error getting bool $key - $e');
      return defaultValue;
    }
  }

  // -------------------------------------------------------
  // String List Operations
  // -------------------------------------------------------

  Future<bool> setStringList(String key, List<String> value) async {
    try {
      if (_prefs == null) {
        await initialize();
      }
      return await _prefs!.setStringList(key, value);
    } catch (e) {
      debugPrint('StorageService: Error setting string list $key - $e');
      return false;
    }
  }

  List<String> getStringList(String key, {List<String>? defaultValue}) {
    try {
      if (_prefs == null) {
        return defaultValue ?? <String>[];
      }
      return _prefs!.getStringList(key) ?? defaultValue ?? <String>[];
    } catch (e) {
      debugPrint('StorageService: Error getting string list $key - $e');
      return defaultValue ?? <String>[];
    }
  }

  // -------------------------------------------------------
  // Convenience Getters and Setters
  // -------------------------------------------------------

  // Theme
  Future<bool> saveThemeMode(String mode) async {
    return await setString(keyThemeMode, mode);
  }

  String getThemeMode() {
    return getString(keyThemeMode, defaultValue: 'system');
  }

  // Sound
  Future<bool> saveSoundEnabled(bool enabled) async {
    return await setBool(keySoundEnabled, enabled);
  }

  bool getSoundEnabled() {
    return getBool(keySoundEnabled, defaultValue: true);
  }

  // Volume
  Future<bool> saveMasterVolume(double volume) async {
    return await setDouble(keyMasterVolume, volume);
  }

  double getMasterVolume() {
    return getDouble(keyMasterVolume, defaultValue: 1.0);
  }

  // Auth State
  Future<bool> saveLoginState(bool isLoggedIn) async {
    return await setBool(keyIsLoggedIn, isLoggedIn);
  }

  bool getLoginState() {
    return getBool(keyIsLoggedIn, defaultValue: false);
  }

  // User Info
  Future<void> saveUserInfo({
    required String userId,
    required String userName,
    required String userEmail,
    String userAvatar = '',
  }) async {
    await setString(keyUserId, userId);
    await setString(keyUserName, userName);
    await setString(keyUserEmail, userEmail);
    await setString(keyUserAvatar, userAvatar);
    await saveLoginState(true);
  }

  Map<String, String> getUserInfo() {
    return <String, String>{
      'userId': getString(keyUserId),
      'userName': getString(keyUserName),
      'userEmail': getString(keyUserEmail),
      'userAvatar': getString(keyUserAvatar),
    };
  }

  // Focus Stats
  Future<void> saveFocusStats({
    required int totalMinutes,
    required int totalSessions,
    required int currentStreak,
    required int bestStreak,
  }) async {
    await setInt(keyTotalFocusMinutes, totalMinutes);
    await setInt(keyTotalSessions, totalSessions);
    await setInt(keyCurrentStreak, currentStreak);
    await setInt(keyBestStreak, bestStreak);
    await setString(keyLastSessionDate, DateTime.now().toIso8601String());
  }

  Map<String, int> getFocusStats() {
    return <String, int>{
      'totalMinutes': getInt(keyTotalFocusMinutes),
      'totalSessions': getInt(keyTotalSessions),
      'currentStreak': getInt(keyCurrentStreak),
      'bestStreak': getInt(keyBestStreak),
    };
  }

  Future<bool> addFocusMinutes(int minutes) async {
    final int current = getInt(keyTotalFocusMinutes);
    return await setInt(keyTotalFocusMinutes, current + minutes);
  }

  Future<bool> incrementSessions() async {
    final int current = getInt(keyTotalSessions);
    return await setInt(keyTotalSessions, current + 1);
  }

  // Default Focus Duration in minutes
  Future<bool> saveDefaultFocusDuration(int minutes) async {
    return await setInt(keyDefaultFocusDuration, minutes);
  }

  int getDefaultFocusDuration() {
    return getInt(keyDefaultFocusDuration, defaultValue: 25);
  }

  // Blocked Apps
  Future<bool> saveBlockedApps(List<String> packageNames) async {
    return await setStringList(keyBlockedApps, packageNames);
  }

  List<String> getBlockedApps() {
    return getStringList(keyBlockedApps);
  }

  // First Launch
  Future<bool> setFirstLaunchDone() async {
    return await setBool(keyIsFirstLaunch, true);
  }

  bool isFirstLaunch() {
    return !getBool(keyIsFirstLaunch, defaultValue: false);
  }

  // Rank
  Future<void> saveRank(int newRank) async {
    final int currentRank = getInt(keyUserRank, defaultValue: 0);
    await setInt(keyPreviousRank, currentRank);
    await setInt(keyUserRank, newRank);
  }

  int getUserRank() {
    return getInt(keyUserRank, defaultValue: 0);
  }

  int getPreviousRank() {
    return getInt(keyPreviousRank, defaultValue: 0);
  }

  bool hasRankImproved() {
    final int current = getUserRank();
    final int previous = getPreviousRank();
    if (current == 0 || previous == 0) {
      return false;
    }
    return current < previous;
  }

  // Sync Timestamp
  Future<bool> saveLastSyncTimestamp() async {
    return await setString(
      keyLastSyncTimestamp,
      DateTime.now().toIso8601String(),
    );
  }

  DateTime? getLastSyncTimestamp() {
    final String timestamp = getString(keyLastSyncTimestamp);
    if (timestamp.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      return null;
    }
  }

  // -------------------------------------------------------
  // Delete and Clear Operations
  // -------------------------------------------------------

  Future<bool> remove(String key) async {
    try {
      if (_prefs == null) {
        await initialize();
      }
      return await _prefs!.remove(key);
    } catch (e) {
      debugPrint('StorageService: Error removing $key - $e');
      return false;
    }
  }

  Future<void> clearUserData() async {
    try {
      await remove(keyUserId);
      await remove(keyUserName);
      await remove(keyUserEmail);
      await remove(keyUserAvatar);
      await remove(keyIsLoggedIn);
      await remove(keyTotalFocusMinutes);
      await remove(keyTotalSessions);
      await remove(keyCurrentStreak);
      await remove(keyBestStreak);
      await remove(keyLastSessionDate);
      await remove(keyUserRank);
      await remove(keyPreviousRank);
      debugPrint('StorageService: User data cleared.');
    } catch (e) {
      debugPrint('StorageService: Error clearing user data - $e');
    }
  }

  Future<bool> clearAll() async {
    try {
      if (_prefs == null) {
        await initialize();
      }
      return await _prefs!.clear();
    } catch (e) {
      debugPrint('StorageService: Error clearing all data - $e');
      return false;
    }
  }
}
