import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/installed_app_model.dart';

class NativeBridgeService {
  // MUST match the MethodChannel name in MainActivity.kt
  static const MethodChannel _channel = MethodChannel('com.example.focus_app/app_blocker');

  /// Checks if Usage Stats and Accessibility permissions are granted
  Future<bool> checkPermissions() async {
    if (!defaultTargetPlatform.isAndroid) return true; // Only applicable for Android
    try {
      final bool hasPermission = await _channel.invokeMethod('checkPermissions');
      return hasPermission;
    } on PlatformException catch (e) {
      debugPrint('NativeBridgeService checkPermissions Error: ${e.message}');
      return false;
    }
  }

  /// Opens Android Settings to request necessary permissions
  Future<void> requestPermissions() async {
    if (!defaultTargetPlatform.isAndroid) return;
    try {
      await _channel.invokeMethod('requestPermissions');
    } on PlatformException catch (e) {
      debugPrint('NativeBridgeService requestPermissions Error: ${e.message}');
    }
  }

  /// Starts the App Blocker Service (Accessibility Service)
  Future<bool> startBlocker() async {
    if (!defaultTargetPlatform.isAndroid) return false;
    try {
      final bool success = await _channel.invokeMethod('startBlocker');
      return success;
    } on PlatformException catch (e) {
      debugPrint('NativeBridgeService startBlocker Error: ${e.message}');
      return false;
    }
  }

  /// Stops the App Blocker Service
  Future<bool> stopBlocker() async {
    if (!defaultTargetPlatform.isAndroid) return false;
    try {
      final bool success = await _channel.invokeMethod('stopBlocker');
      return success;
    } on PlatformException catch (e) {
      debugPrint('NativeBridgeService stopBlocker Error: ${e.message}');
      return false;
    }
  }

  /// Sends the list of allowed package names to the Native Kotlin Service
  Future<void> updateWhitelist(List<String> allowedPackages) async {
    if (!defaultTargetPlatform.isAndroid) return;
    try {
      await _channel.invokeMethod('updateWhitelist', {'packages': allowedPackages});
    } on PlatformException catch (e) {
      debugPrint('NativeBridgeService updateWhitelist Error: ${e.message}');
    }
  }

  /// Fetches all user-installed applications from Android
  Future<List<InstalledAppModel>> getInstalledApps() async {
    if (!defaultTargetPlatform.isAndroid) return[];
    try {
      final List<dynamic> appsList = await _channel.invokeMethod('getInstalledApps');
      return appsList.map((appMap) => InstalledAppModel.fromMap(appMap as Map<dynamic, dynamic>)).toList();
    } on PlatformException catch (e) {
      debugPrint('NativeBridgeService getInstalledApps Error: ${e.message}');
      return[];
    }
  }
}
