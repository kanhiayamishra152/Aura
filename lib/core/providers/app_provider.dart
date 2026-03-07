import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:focus_app/core/services/audio_service.dart';
import 'package:focus_app/core/services/storage_service.dart';
import 'package:focus_app/core/services/connectivity_service.dart';
import 'package:focus_app/core/services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService storageService;
  final AudioService audioService;
  final ConnectivityService connectivityService;
  final NotificationService notificationService;

  static const MethodChannel _channel = MethodChannel('com.example.focus_app/blocker');

  bool _isFocusModeActive = false;
  bool _isAccessibilityEnabled = false;
  bool _isUsageStatsGranted = false;
  bool _isBatteryOptimizationIgnored = false;
  List<String> _blockedPackages = [];
  String? _lastBlockedPackage;
  bool _showFocusShield = false;

  bool get isFocusModeActive => _isFocusModeActive;
  bool get isAccessibilityEnabled => _isAccessibilityEnabled;
  bool get isUsageStatsGranted => _isUsageStatsGranted;
  bool get isBatteryOptimizationIgnored => _isBatteryOptimizationIgnored;
  List<String> get blockedPackages => List.unmodifiable(_blockedPackages);
  String? get lastBlockedPackage => _lastBlockedPackage;
  bool get showFocusShield => _showFocusShield;

  AppProvider({
    required this.storageService,
    required this.audioService,
    required this.connectivityService,
    required this.notificationService,
  }) {
    _initializeState();
    _setupMethodCallHandler();
  }

  Future<void> _initializeState() async {
    final savedPackages = storageService.getStringList('blocked_packages');
    if (savedPackages != null) {
      _blockedPackages = List<String>.from(savedPackages);
    }
    await checkAllPermissions();
    notifyListeners();
  }

  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onAppBlocked':
          final String packageName = call.arguments as String;
          _lastBlockedPackage = packageName;
          _showFocusShield = true;
          notifyListeners();
          await audioService.play('focus_mode_on.mp3');
          break;
        case 'onFocusModeStatusChanged':
          final bool active = call.arguments as bool;
          _isFocusModeActive = active;
          notifyListeners();
          break;
        default:
          break;
      }
    });
  }

  Future<void> checkAllPermissions() async {
    _isAccessibilityEnabled = await _checkAccessibilityPermission();
    _isUsageStatsGranted = await _checkUsageStatsPermission();
    _isBatteryOptimizationIgnored = await _checkBatteryOptimization();
    notifyListeners();
  }

  Future<bool> _checkAccessibilityPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAccessibilityEnabled');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('AppProvider: Failed to check accessibility: ${e.message}');
      return false;
    } on MissingPluginException {
      debugPrint('AppProvider: MethodChannel not available for accessibility check');
      return false;
    }
  }

  Future<bool> _checkUsageStatsPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('isUsageStatsGranted');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('AppProvider: Failed to check usage stats: ${e.message}');
      return false;
    } on MissingPluginException {
      debugPrint('AppProvider: MethodChannel not available for usage stats check');
      return false;
    }
  }

  Future<bool> _checkBatteryOptimization() async {
    try {
      final result = await _channel.invokeMethod<bool>('isBatteryOptimizationIgnored');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('AppProvider: Failed to check battery optimization: ${e.message}');
      return false;
    } on MissingPluginException {
      debugPrint('AppProvider: MethodChannel not available for battery check');
      return false;
    }
  }

  Future<void> requestAccessibilityPermission() async {
    try {
      await _channel.invokeMethod<void>('openAccessibilitySettings');
    } on PlatformException catch (e) {
      debugPrint('AppProvider: Failed to open accessibility settings: ${e.message}');
    } on MissingPluginException {
      debugPrint('AppProvider: MethodChannel not available');
    }
  }

  Future<void> requestUsageStatsPermission() async {
    try {
      await _channel.invokeMethod<void>('openUsageStatsSettings');
    } on PlatformException catch (e) {
      debugPrint('AppProvider: Failed to open usage stats settings: ${e.message}');
    } on MissingPluginException {
      debugPrint('AppProvider: MethodChannel not available');
    }
  }

  Future<void> requestBatteryOptimizationExemption() async {
    try {
      await _channel.invokeMethod<void>('requestBatteryOptimization');
    } on PlatformException catch (e) {
      debugPrint('AppProvider: Failed to request battery optimization: ${e.message}');
    } on MissingPluginException {
      debugPrint('AppProvider: MethodChannel not available');
    }
  }

  Future<void> startFocusMode(List<String> packages) async {
    if (!_isAccessibilityEnabled || !_isUsageStatsGranted) {
      debugPrint('AppProvider: Required permissions not granted for focus mode');
      return;
    }

    _blockedPackages = List<String>.from(packages);
    await storageService.setStringList('blocked_packages', _blockedPackages);

    try {
      final result = await _channel.invokeMethod<bool>('startFocusMode', {
        'packages': _blockedPackages,
      });
      if (result == true) {
        _isFocusModeActive = true;
        await audioService.play('focus_mode_on.mp3');
        notifyListeners();
      }
    } on PlatformException catch (e) {
      debugPrint('AppProvider: Failed to start focus mode: ${e.message}');
    } on MissingPluginException {
      debugPrint('AppProvider: MethodChannel not available');
    }
  }

  Future<void> stopFocusMode() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopFocusMode');
      if (result == true) {
        _isFocusModeActive = false;
        _showFocusShield = false;
        _lastBlockedPackage = null;
        await audioService.play('focus_mode_off.mp3');
        notifyListeners();
      }
    } on PlatformException catch (e) {
      debugPrint('AppProvider: Failed to stop focus mode: ${e.message}');
    } on MissingPluginException {
      debugPrint('AppProvider: MethodChannel not available');
    }
  }

  void dismissFocusShield() {
    _showFocusShield = false;
    _lastBlockedPackage = null;
    notifyListeners();
  }

  Future<void> updateBlockedPackages(List<String> packages) async {
    _blockedPackages = List<String>.from(packages);
    await storageService.setStringList('blocked_packages', _blockedPackages);

    if (_isFocusModeActive) {
      try {
        await _channel.invokeMethod<void>('updateBlockedPackages', {
          'packages': _blockedPackages,
        });
      } on PlatformException catch (e) {
        debugPrint('AppProvider: Failed to update blocked packages: ${e.message}');
      } on MissingPluginException {
        debugPrint('AppProvider: MethodChannel not available');
      }
    }
    notifyListeners();
  }

  Future<List<Map<String, String>>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getInstalledApps');
      if (result != null) {
        return result.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          return {
            'packageName': map['packageName']?.toString() ?? '',
            'appName': map['appName']?.toString() ?? '',
          };
        }).toList();
      }
    } on PlatformException catch (e) {
      debugPrint('AppProvider: Failed to get installed apps: ${e.message}');
    } on MissingPluginException {
      debugPrint('AppProvider: MethodChannel not available');
    }
    return [];
  }

  bool get areAllPermissionsGranted {
    return _isAccessibilityEnabled &&
        _isUsageStatsGranted &&
        _isBatteryOptimizationIgnored;
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    super.dispose();
  }
}
