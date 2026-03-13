import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:focus_flow/core/services/audio_service.dart';
import 'package:focus_flow/core/services/storage_service.dart';
import 'package:focus_flow/core/models/blocked_app_model.dart';
import 'package:focus_flow/config/app_constants.dart';

class FocusModeProvider extends ChangeNotifier {
  final AudioService _audioService;
  final StorageService _storageService;

  static const MethodChannel _channel =
      MethodChannel('com.example.focus_app/app_blocker');

  // State
  bool _isFocusModeActive = false;
  bool _isAccessibilityEnabled = false;
  bool _isUsageStatsGranted = false;
  bool _isLoading = false;
  String? _errorMessage;

  List<BlockedAppModel> _installedApps = [];
  List<BlockedAppModel> _blockedApps = [];
  List<String> _essentialPackages = [];

  // Focus session tracking
  DateTime? _focusStartTime;
  Timer? _focusDurationTimer;
  Duration _currentFocusDuration = Duration.zero;

  FocusModeProvider({
    required AudioService audioService,
    required StorageService storageService,
  })  : _audioService = audioService,
        _storageService = storageService {
    _initialize();
  }

  // Getters
  bool get isFocusModeActive => _isFocusModeActive;
  bool get isAccessibilityEnabled => _isAccessibilityEnabled;
  bool get isUsageStatsGranted => _isUsageStatsGranted;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BlockedAppModel> get installedApps => List.unmodifiable(_installedApps);
  List<BlockedAppModel> get blockedApps => List.unmodifiable(_blockedApps);
  Duration get currentFocusDuration => _currentFocusDuration;
  bool get hasRequiredPermissions =>
      _isAccessibilityEnabled && _isUsageStatsGranted;

  String get focusDurationFormatted {
    final hours = _currentFocusDuration.inHours;
    final minutes = _currentFocusDuration.inMinutes.remainder(60);
    final seconds = _currentFocusDuration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  int get blockedAppCount => _blockedApps.length;

  Future<void> _initialize() async {
    await _loadBlockedApps();
    await _loadEssentialPackages();
    await checkPermissions();
    await _checkActiveFocusSession();
  }

  // ---------------------------------------------------------------------------
  // PERMISSION MANAGEMENT
  // ---------------------------------------------------------------------------

  Future<void> checkPermissions() async {
    try {
      final bool accessibilityResult = await _channel.invokeMethod<bool>(
            'checkAccessibilityPermission',
          ) ??
          false;

      final bool usageStatsResult = await _channel.invokeMethod<bool>(
            'checkUsageStatsPermission',
          ) ??
          false;

      _isAccessibilityEnabled = accessibilityResult;
      _isUsageStatsGranted = usageStatsResult;
      _errorMessage = null;
      notifyListeners();
    } on PlatformException catch (e) {
      _errorMessage = 'Permission check failed: ${e.message}';
      debugPrint('FocusModeProvider: Permission check error - ${e.message}');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Unexpected error checking permissions';
      debugPrint('FocusModeProvider: Unexpected error - $e');
      notifyListeners();
    }
  }

  Future<void> requestAccessibilityPermission() async {
    try {
      await _channel.invokeMethod<void>('openAccessibilitySettings');
    } on PlatformException catch (e) {
      _errorMessage = 'Could not open accessibility settings: ${e.message}';
      notifyListeners();
    }
  }

  Future<void> requestUsageStatsPermission() async {
    try {
      await _channel.invokeMethod<void>('openUsageStatsSettings');
    } on PlatformException catch (e) {
      _errorMessage = 'Could not open usage stats settings: ${e.message}';
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // APP LOADING
  // ---------------------------------------------------------------------------

  Future<void> loadInstalledApps() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<dynamic>? result =
          await _channel.invokeMethod<List<dynamic>>('getInstalledApps');

      if (result != null) {
        _installedApps = result.map((app) {
          final Map<String, dynamic> appMap =
              Map<String, dynamic>.from(app as Map);
          return BlockedAppModel(
            packageName: appMap['packageName'] as String? ?? '',
            appName: appMap['appName'] as String? ?? 'Unknown',
            isBlocked: _blockedApps.any(
              (blocked) =>
                  blocked.packageName == (appMap['packageName'] as String? ?? ''),
            ),
            isEssential: _essentialPackages.contains(
              appMap['packageName'] as String? ?? '',
            ),
          );
        }).toList();

        _installedApps.sort((a, b) {
          if (a.isEssential && !b.isEssential) return 1;
          if (!a.isEssential && b.isEssential) return -1;
          return a.appName.toLowerCase().compareTo(b.appName.toLowerCase());
        });
      }

      _isLoading = false;
      notifyListeners();
    } on PlatformException catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load apps: ${e.message}';
      debugPrint('FocusModeProvider: Load apps error - ${e.message}');
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Unexpected error loading apps';
      debugPrint('FocusModeProvider: Unexpected error - $e');
      notifyListeners();
    }
  }

  void _loadEssentialPackages() {
    _essentialPackages = [
      'com.android.dialer',
      'com.google.android.dialer',
      'com.samsung.android.dialer',
      'com.android.contacts',
      'com.google.android.contacts',
      'com.android.mms',
      'com.google.android.apps.messaging',
      'com.samsung.android.messaging',
      'com.whatsapp',
      'com.whatsapp.w4b',
      'org.telegram.messenger',
      'com.android.settings',
      'com.google.android.gm',
      'com.android.camera',
      'com.google.android.calculator',
      'com.android.emergency',
    ];
  }

  // ---------------------------------------------------------------------------
  // BLOCK / UNBLOCK APPS
  // ---------------------------------------------------------------------------

  Future<void> toggleAppBlocked(String packageName) async {
    if (_essentialPackages.contains(packageName)) {
      _errorMessage = 'Essential apps cannot be blocked';
      await _audioService.playError();
      notifyListeners();
      Future.delayed(const Duration(seconds: 2), () {
        _errorMessage = null;
        notifyListeners();
      });
      return;
    }

    final installedIndex = _installedApps.indexWhere(
      (a) => a.packageName == packageName,
    );

    if (installedIndex == -1) return;

    final app = _installedApps[installedIndex];
    final isCurrentlyBlocked = app.isBlocked;

    _installedApps[installedIndex] = app.copyWith(
      isBlocked: !isCurrentlyBlocked,
    );

    if (isCurrentlyBlocked) {
      _blockedApps.removeWhere((a) => a.packageName == packageName);
    } else {
      _blockedApps.add(app.copyWith(isBlocked: true));
    }

    await _saveBlockedApps();
    await _audioService.playButtonClick();

    if (_isFocusModeActive) {
      await _syncBlockedAppsToNative();
    }

    notifyListeners();
  }

  Future<void> blockAllSocialMedia() async {
    const socialMediaPackages = [
      'com.facebook.katana',
      'com.facebook.lite',
      'com.instagram.android',
      'com.twitter.android',
      'com.zhiliaoapp.musically',
      'com.snapchat.android',
      'com.pinterest',
      'com.reddit.frontpage',
      'com.tumblr',
      'com.linkedin.android',
      'com.google.android.youtube',
      'com.amazon.avod.thirdpartyclient',
      'com.netflix.mediaclient',
      'in.mohalla.sharechat',
      'com.roposo.android',
      'com.mxtech.videoplayer.ad',
    ];

    for (final pkg in socialMediaPackages) {
      final index = _installedApps.indexWhere(
        (a) => a.packageName == pkg,
      );
      if (index != -1 && !_installedApps[index].isBlocked) {
        _installedApps[index] = _installedApps[index].copyWith(
          isBlocked: true,
        );
        if (!_blockedApps.any((a) => a.packageName == pkg)) {
          _blockedApps.add(_installedApps[index]);
        }
      }
    }

    await _saveBlockedApps();
    await _audioService.playSuccess();

    if (_isFocusModeActive) {
      await _syncBlockedAppsToNative();
    }

    notifyListeners();
  }

  Future<void> unblockAll() async {
    for (int i = 0; i < _installedApps.length; i++) {
      if (_installedApps[i].isBlocked) {
        _installedApps[i] = _installedApps[i].copyWith(isBlocked: false);
      }
    }

    _blockedApps.clear();
    await _saveBlockedApps();
    await _audioService.playButtonClick();

    if (_isFocusModeActive) {
      await _syncBlockedAppsToNative();
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // FOCUS MODE ACTIVATION / DEACTIVATION
  // ---------------------------------------------------------------------------

  Future<bool> activateFocusMode() async {
    if (_isFocusModeActive) return true;

    if (!hasRequiredPermissions) {
      _errorMessage = 'Required permissions are not granted';
      await _audioService.playError();
      notifyListeners();
      return false;
    }

    if (_blockedApps.isEmpty) {
      _errorMessage = 'Please select at least one app to block';
      await _audioService.playError();
      notifyListeners();
      Future.delayed(const Duration(seconds: 2), () {
        _errorMessage = null;
        notifyListeners();
      });
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _syncBlockedAppsToNative();

      final bool result = await _channel.invokeMethod<bool>(
            'startFocusMode',
          ) ??
          false;

      if (result) {
        _isFocusModeActive = true;
        _focusStartTime = DateTime.now();
        _currentFocusDuration = Duration.zero;
        _startFocusDurationTracking();

        await _storageService.setBool(
          AppConstants.keyFocusModeActive,
          true,
        );
        await _storageService.setString(
          AppConstants.keyFocusStartTime,
          _focusStartTime!.toIso8601String(),
        );

        await _audioService.playFocusModeOn();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to activate focus mode';
        await _audioService.playError();
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on PlatformException catch (e) {
      _isLoading = false;
      _errorMessage = 'Focus mode error: ${e.message}';
      await _audioService.playError();
      debugPrint('FocusModeProvider: Activate error - ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Unexpected error activating focus mode';
      await _audioService.playError();
      debugPrint('FocusModeProvider: Unexpected error - $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivateFocusMode() async {
    if (!_isFocusModeActive) return true;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final bool result = await _channel.invokeMethod<bool>(
            'stopFocusMode',
          ) ??
          false;

      if (result) {
        _isFocusModeActive = false;
        _focusDurationTimer?.cancel();
        _focusStartTime = null;

        await _storageService.setBool(
          AppConstants.keyFocusModeActive,
          false,
        );
        await _storageService.remove(AppConstants.keyFocusStartTime);

        await _audioService.playFocusModeOff();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to deactivate focus mode';
        await _audioService.playError();
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on PlatformException catch (e) {
      _isLoading = false;
      _errorMessage = 'Focus mode error: ${e.message}';
      await _audioService.playError();
      debugPrint('FocusModeProvider: Deactivate error - ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Unexpected error deactivating focus mode';
      await _audioService.playError();
      debugPrint('FocusModeProvider: Unexpected error - $e');
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // NATIVE SYNC
  // ---------------------------------------------------------------------------

  Future<void> _syncBlockedAppsToNative() async {
    try {
      final List<String> packageNames =
          _blockedApps.map((a) => a.packageName).toList();

      await _channel.invokeMethod<void>(
        'setBlockedApps',
        {'packages': packageNames},
      );
    } on PlatformException catch (e) {
      debugPrint(
        'FocusModeProvider: Sync blocked apps error - ${e.message}',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // FOCUS DURATION TRACKING
  // ---------------------------------------------------------------------------

  void _startFocusDurationTracking() {
    _focusDurationTimer?.cancel();
    _focusDurationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (_focusStartTime != null) {
          _currentFocusDuration = DateTime.now().difference(_focusStartTime!);
          notifyListeners();
        }
      },
    );
  }

  Future<void> _checkActiveFocusSession() async {
    final isActive = _storageService.getBool(
      AppConstants.keyFocusModeActive,
    );

    if (isActive) {
      final startTimeString = _storageService.getString(
        AppConstants.keyFocusStartTime,
      );

      if (startTimeString != null) {
        _focusStartTime = DateTime.tryParse(startTimeString);
        if (_focusStartTime != null) {
          _isFocusModeActive = true;
          _currentFocusDuration =
              DateTime.now().difference(_focusStartTime!);
          _startFocusDurationTracking();
          notifyListeners();
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // PERSISTENCE
  // ---------------------------------------------------------------------------

  Future<void> _loadBlockedApps() async {
    _blockedApps = await _storageService.loadBlockedApps();
    notifyListeners();
  }

  Future<void> _saveBlockedApps() async {
    await _storageService.saveBlockedApps(_blockedApps);
  }

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------

  List<BlockedAppModel> searchApps(String query) {
    if (query.isEmpty) return _installedApps;

    final lowerQuery = query.toLowerCase();
    return _installedApps.where((app) {
      return app.appName.toLowerCase().contains(lowerQuery) ||
          app.packageName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // UTILITY
  // ---------------------------------------------------------------------------

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _focusDurationTimer?.cancel();
    super.dispose();
  }
}
