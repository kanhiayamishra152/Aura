import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_constants.dart';

/// Centralized local storage service using SharedPreferences.
/// Battery Optimized:
/// - Single SharedPreferences instance cached after first load.
/// - No repeated disk reads - instance reused across all calls.
/// - Writes are async and non-blocking.
/// - Only stores primitive data types to minimize storage footprint.
class StorageService {
  StorageService._internal();
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  SharedPreferences? _prefs;

  /// Initialize and cache the SharedPreferences instance.
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure prefs is available before any operation.
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // --- String Operations ---

  Future<void> setString(String key, String value) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getString(key);
  }

  // --- Int Operations ---

  Future<void> setInt(String key, int value) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setInt(key, value);
  }

  Future<int> getInt(String key, {int defaultValue = 0}) async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getInt(key) ?? defaultValue;
  }

  // --- Double Operations ---

  Future<void> setDouble(String key, double value) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setDouble(key, value);
  }

  Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getDouble(key) ?? defaultValue;
  }

  // --- Bool Operations ---

  Future<void> setBool(String key, bool value) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setBool(key, value);
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getBool(key) ?? defaultValue;
  }

  // --- StringList Operations ---

  Future<void> setStringList(String key, List<String> value) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setStringList(key, value);
  }

  Future<List<String>> getStringList(String key) async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getStringList(key) ?? <String>[];
  }

  // --- Remove and Clear ---

  Future<void> remove(String key) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.remove(key);
  }

  Future<void> clearAll() async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.clear();
  }

  Future<bool> containsKey(String key) async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.containsKey(key);
  }

  // --- User Data Convenience Methods ---

  Future<void> saveUserData({
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhoto,
  }) async {
    await setString(AppConstants.prefUserId, userId);
    await setString(AppConstants.prefUserName, userName);
    await setString(AppConstants.prefUserEmail, userEmail);
    if (userPhoto != null) {
      await setString(AppConstants.prefUserPhoto, userPhoto);
    }
  }

  Future<Map<String, String?>> getUserData() async {
    return {
      'userId': await getString(AppConstants.prefUserId),
      'userName': await getString(AppConstants.prefUserName),
      'userEmail': await getString(AppConstants.prefUserEmail),
      'userPhoto': await getString(AppConstants.prefUserPhoto),
    };
  }

  Future<void> clearUserData() async {
    await remove(AppConstants.prefUserId);
    await remove(AppConstants.prefUserName);
    await remove(AppConstants.prefUserEmail);
    await remove(AppConstants.prefUserPhoto);
  }

  Future<bool> isLoggedIn() async {
    final String? userId = await getString(AppConstants.prefUserId);
    return userId != null && userId.isNotEmpty;
  }

  // --- Focus Stats Convenience Methods ---

  Future<void> addFocusTime(int seconds) async {
    final int current = await getInt(AppConstants.prefTotalFocusTime);
    await setInt(AppConstants.prefTotalFocusTime, current + seconds);
  }

  Future<int> getTotalFocusTime() async {
    return await getInt(AppConstants.prefTotalFocusTime);
  }

  Future<void> incrementSessionCount() async {
    final int current = await getInt(AppConstants.prefTotalSessions);
    await setInt(AppConstants.prefTotalSessions, current + 1);
  }

  Future<int> getTotalSessions() async {
    return await getInt(AppConstants.prefTotalSessions);
  }

  // --- Streak Management ---

  Future<void> updateStreak() async {
    final String? lastDateStr = await getString(
      AppConstants.prefLastSessionDate,
    );
    final String todayStr = DateTime.now().toIso8601String().split('T')[0];

    if (lastDateStr == null) {
      await setInt(AppConstants.prefCurrentStreak, 1);
      await setString(AppConstants.prefLastSessionDate, todayStr);
      await _updateBestStreak(1);
      return;
    }

    if (lastDateStr == todayStr) {
      return;
    }

    final DateTime lastDate = DateTime.parse(lastDateStr);
    final DateTime today = DateTime.now();
    final int daysDifference = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime(
      lastDate.year,
      lastDate.month,
      lastDate.day,
    )).inDays;

    int currentStreak = await getInt(AppConstants.prefCurrentStreak);

    if (daysDifference == 1) {
      currentStreak += 1;
    } else {
      currentStreak = 1;
    }

    await setInt(AppConstants.prefCurrentStreak, currentStreak);
    await setString(AppConstants.prefLastSessionDate, todayStr);
    await _updateBestStreak(currentStreak);
  }

  Future<void> _updateBestStreak(int currentStreak) async {
    final int bestStreak = await getInt(AppConstants.prefBestStreak);
    if (currentStreak > bestStreak) {
      await setInt(AppConstants.prefBestStreak, currentStreak);
    }
  }

  Future<int> getCurrentStreak() async {
    return await getInt(AppConstants.prefCurrentStreak);
  }

  Future<int> getBestStreak() async {
    return await getInt(AppConstants.prefBestStreak);
  }
}
