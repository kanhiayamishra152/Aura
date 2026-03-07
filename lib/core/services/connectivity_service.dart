// lib/core/services/connectivity_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectionStatus {
  online,
  offline,
  unknown,
}

class ConnectivityService {
  ConnectivityService._internal();

  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() {
    return _instance;
  }

  static ConnectivityService get instance => _instance;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final StreamController<ConnectionStatus> _statusController =
      StreamController<ConnectionStatus>.broadcast();

  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  ConnectionStatus _currentStatus = ConnectionStatus.unknown;
  ConnectionStatus get currentStatus => _currentStatus;

  bool get isOnline => _currentStatus == ConnectionStatus.online;
  bool get isOffline => _currentStatus == ConnectionStatus.offline;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      final List<ConnectivityResult> initialResult =
          await _connectivity.checkConnectivity();
      _updateStatus(initialResult);

      _subscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          _updateStatus(results);
        },
        onError: (dynamic error) {
          debugPrint('ConnectivityService: Stream error - $error');
          _currentStatus = ConnectionStatus.unknown;
          _statusController.add(_currentStatus);
        },
      );

      _isInitialized = true;
      debugPrint(
        'ConnectivityService: Initialized. Status: $_currentStatus',
      );
    } catch (e) {
      debugPrint('ConnectivityService: Error during initialization - $e');
      _currentStatus = ConnectionStatus.unknown;
      _statusController.add(_currentStatus);
    }
  }

  void _updateStatus(List<ConnectivityResult> results) {
    ConnectionStatus newStatus;

    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      newStatus = ConnectionStatus.offline;
    } else if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.ethernet)) {
      newStatus = ConnectionStatus.online;
    } else {
      newStatus = ConnectionStatus.unknown;
    }

    if (newStatus != _currentStatus) {
      final ConnectionStatus previousStatus = _currentStatus;
      _currentStatus = newStatus;
      _statusController.add(_currentStatus);

      debugPrint(
        'ConnectivityService: Status changed from $previousStatus to $_currentStatus',
      );
    }
  }

  Future<ConnectionStatus> checkNow() async {
    try {
      final List<ConnectivityResult> result =
          await _connectivity.checkConnectivity();
      _updateStatus(result);
      return _currentStatus;
    } catch (e) {
      debugPrint('ConnectivityService: Error checking connectivity - $e');
      return ConnectionStatus.unknown;
    }
  }

  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (isOnline) {
      return true;
    }

    try {
      final Completer<bool> completer = Completer<bool>();

      Timer? timeoutTimer;

      final StreamSubscription<ConnectionStatus> sub =
          statusStream.listen((ConnectionStatus status) {
        if (status == ConnectionStatus.online && !completer.isCompleted) {
          timeoutTimer?.cancel();
          completer.complete(true);
        }
      });

      timeoutTimer = Timer(timeout, () {
        if (!completer.isCompleted) {
          sub.cancel();
          completer.complete(false);
        }
      });

      final bool result = await completer.future;
      await sub.cancel();
      return result;
    } catch (e) {
      debugPrint('ConnectivityService: Error waiting for connection - $e');
      return false;
    }
  }

  String getStatusMessage() {
    switch (_currentStatus) {
      case ConnectionStatus.online:
        return 'Connected to the internet';
      case ConnectionStatus.offline:
        return 'No internet connection';
      case ConnectionStatus.unknown:
        return 'Connection status unknown';
    }
  }

  Future<void> dispose() async {
    try {
      await _subscription?.cancel();
      _subscription = null;
      await _statusController.close();
      _isInitialized = false;
      debugPrint('ConnectivityService: Disposed.');
    } catch (e) {
      debugPrint('ConnectivityService: Error during dispose - $e');
    }
  }
}
