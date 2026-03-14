import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class HapticUtils {
  static bool _hapticsEnabled = true;

  static void setHapticsEnabled(bool enabled) {
    _hapticsEnabled = enabled;
  }

  static Future<void> lightImpact() async {
    if (!_hapticsEnabled || kIsWeb) return;
    await HapticFeedback.lightImpact();
  }

  static Future<void> mediumImpact() async {
    if (!_hapticsEnabled || kIsWeb) return;
    await HapticFeedback.mediumImpact();
  }

  static Future<void> heavyImpact() async {
    if (!_hapticsEnabled || kIsWeb) return;
    await HapticFeedback.heavyImpact();
  }

  static Future<void> selectionClick() async {
    if (!_hapticsEnabled || kIsWeb) return;
    await HapticFeedback.selectionClick();
  }

  static Future<void> successVibrate() async {
    if (!_hapticsEnabled || kIsWeb) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  static Future<void> errorVibrate() async {
    if (!_hapticsEnabled || kIsWeb) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
  }
}
