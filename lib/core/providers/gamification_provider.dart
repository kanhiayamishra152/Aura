import 'dart:math';
import 'package:flutter/material.dart';
import '../services/gamification_service.dart';
import '../models/leaderboard_entry_model.dart';
import '../../utils/haptic_utils.dart';

class GamificationProvider extends ChangeNotifier {
  final GamificationService _service;

  int _currentXp = 0;
  int _currentLevel = 1;
  int _streakDays = 0;
  bool _isLoading = false;

  GamificationProvider(this._service) {
    _loadUserData();
  }

  int get currentXp => _currentXp;
  int get currentLevel => _currentLevel;
  int get streakDays => _streakDays;
  bool get isLoading => _isLoading;

  int get xpForNextLevel => _calculateXpForLevel(_currentLevel + 1);
  int get xpForCurrentLevel => _calculateXpForLevel(_currentLevel);
  
  double get levelProgress {
    final range = xpForNextLevel - xpForCurrentLevel;
    final progress = _currentXp - xpForCurrentLevel;
    if (range <= 0) return 0.0;
    return (progress / range).clamp(0.0, 1.0);
  }

  Future<void> _loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Assuming service returns a map or user stats object
      final stats = await _service.getUserGamificationStats();
      _currentXp = stats['xp'] ?? 0;
      _streakDays = stats['streak'] ?? 0;
      _currentLevel = _calculateLevelFromXp(_currentXp);
    } catch (e) {
      debugPrint('Error loading gamification data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int _calculateLevelFromXp(int xp) {
    // Premium scaling curve for levels: Level 1 = 0 XP, Level 2 = 1000 XP...
    return max(1, (sqrt(xp / 1000) * 2).floor() + 1);
  }

  int _calculateXpForLevel(int level) {
    if (level <= 1) return 0;
    return (pow((level - 1) / 2, 2) * 1000).ceil();
  }

  Future<bool> addXp(int amount) async {
    final previousLevel = _currentLevel;
    _currentXp += amount;
    _currentLevel = _calculateLevelFromXp(_currentXp);

    notifyListeners();
    await _service.updateUserXp(_currentXp);

    if (_currentLevel > previousLevel) {
      HapticUtils.successVibrate();
      return true; // Indicates level up occurred
    }
    return false;
  }
}
