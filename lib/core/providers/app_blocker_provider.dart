import 'package:flutter/material.dart';
import '../services/native_bridge_service.dart';
import '../models/installed_app_model.dart';
import 'database_service.dart';

class AppBlockerProvider extends ChangeNotifier {
  final NativeBridgeService _nativeBridgeService;
  final DatabaseService _databaseService;

  List<InstalledAppModel> _installedApps = [];
  List<String> _whitelistedPackages =[];
  bool _isLoading = false;
  bool _isBlockerActive = false;
  bool _hasPermissions = false;

  AppBlockerProvider(this._nativeBridgeService, this._databaseService) {
    _initialize();
  }

  List<InstalledAppModel> get installedApps => _installedApps;
  List<String> get whitelistedPackages => _whitelistedPackages;
  bool get isLoading => _isLoading;
  bool get isBlockerActive => _isBlockerActive;
  bool get hasPermissions => _hasPermissions;

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    _hasPermissions = await _nativeBridgeService.checkPermissions();
    _installedApps = await _nativeBridgeService.getInstalledApps();
    
    // Sort apps alphabetically
    _installedApps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

    // Load saved whitelist from database/shared prefs
    _whitelistedPackages = await _databaseService.getWhitelistedApps();
    
    // Sync with native layer
    if (_whitelistedPackages.isNotEmpty) {
      await _nativeBridgeService.updateWhitelist(_whitelistedPackages);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkPermissions() async {
    _hasPermissions = await _nativeBridgeService.checkPermissions();
    notifyListeners();
  }

  Future<void> requestPermissions() async {
    await _nativeBridgeService.requestPermissions();
    // Re-check after returning from settings
    await Future.delayed(const Duration(seconds: 2));
    await checkPermissions();
  }

  Future<void> toggleAppWhitelist(String packageName) async {
    if (_whitelistedPackages.contains(packageName)) {
      _whitelistedPackages.remove(packageName);
    } else {
      _whitelistedPackages.add(packageName);
    }
    
    notifyListeners();
    
    // Save to local database
    await _databaseService.saveWhitelistedApps(_whitelistedPackages);
    // Sync with Native Service
    await _nativeBridgeService.updateWhitelist(_whitelistedPackages);
  }

  Future<void> startFocusMode() async {
    if (!_hasPermissions) {
      await checkPermissions();
      if (!_hasPermissions) return;
    }
    _isBlockerActive = await _nativeBridgeService.startBlocker();
    notifyListeners();
  }

  Future<void> stopFocusMode() async {
    _isBlockerActive = !(await _nativeBridgeService.stopBlocker());
    notifyListeners();
  }
}
