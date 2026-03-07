import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:focus_app/core/services/audio_service.dart';
import 'package:focus_app/core/services/storage_service.dart';
import 'package:focus_app/core/services/notification_service.dart';

enum StopwatchState {
  idle,
  running,
  paused,
}

enum NormalTimerState {
  idle,
  running,
  paused,
  completed,
}

class AlarmData {
  final String id;
  final int hour;
  final int minute;
  final bool isEnabled;
  final String label;
  final List<int> repeatDays;

  AlarmData({
    required this.id,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.label = '',
    this.repeatDays = const [],
  });

  AlarmData copyWith({
    String? id,
    int? hour,
    int? minute,
    bool? isEnabled,
    String? label,
    List<int>? repeatDays,
  }) {
    return AlarmData(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      label: label ?? this.label,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }

  String get formattedTime {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'isEnabled': isEnabled ? 1 : 0,
      'label': label,
      'repeatDays': repeatDays.join(','),
    };
  }

  factory AlarmData.fromMap(Map<String, dynamic> map) {
    final repeatStr = map['repeatDays']?.toString() ?? '';
    final days = repeatStr.isEmpty
        ? <int>[]
        : repeatStr.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();
    return AlarmData(
      id: map['id']?.toString() ?? '',
      hour: map['hour'] as int? ?? 0,
      minute: map['minute'] as int? ?? 0,
      isEnabled: (map['isEnabled'] as int? ?? 0) == 1,
      label: map['label']?.toString() ?? '',
      repeatDays: days,
    );
  }
}

class ClockProvider extends ChangeNotifier {
  final AudioService audioService;
  final StorageService storageService;
  final NotificationService notificationService;

  TickerProvider? _tickerProvider;
  Ticker? _clockTicker;
  bool _isClockActive = false;

  DateTime _currentTime = DateTime.now();
  int _lastNotifiedMinute = -1;

  DateTime get currentTime => _currentTime;
  String get formattedTime {
    final h = _currentTime.hour % 12 == 0 ? 12 : _currentTime.hour % 12;
    final period = _currentTime.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:'
        '${_currentTime.minute.toString().padLeft(2, '0')} $period';
  }

  String get formattedTimeWithSeconds {
    final h = _currentTime.hour % 12 == 0 ? 12 : _currentTime.hour % 12;
    final period = _currentTime.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:'
        '${_currentTime.minute.toString().padLeft(2, '0')}:'
        '${_currentTime.second.toString().padLeft(2, '0')} $period';
  }

  String get formattedDate {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    return '${weekdays[_currentTime.weekday - 1]}, '
        '${_currentTime.day} ${months[_currentTime.month - 1]} '
        '${_currentTime.year}';
  }

  // --- Alarm ---
  List<AlarmData> _alarms = [];
  bool _isAlarmRinging = false;
  AlarmData? _ringingAlarm;

  List<AlarmData> get alarms => List.unmodifiable(_alarms);
  bool get isAlarmRinging => _isAlarmRinging;
  AlarmData? get ringingAlarm => _ringingAlarm;

  // --- Stopwatch ---
  StopwatchState _stopwatchState = StopwatchState.idle;
  DateTime? _stopwatchStartTimestamp;
  int _stopwatchElapsedBeforePauseMs = 0;
  int _stopwatchDisplayMs = 0;
  List<int> _laps = [];

  StopwatchState get stopwatchState => _stopwatchState;
  int get stopwatchDisplayMs => _stopwatchDisplayMs;
  List<int> get laps => List.unmodifiable(_laps);
  String get formattedStopwatch => _formatMilliseconds(_stopwatchDisplayMs);

  // --- Normal Timer ---
  NormalTimerState _normalTimerState = NormalTimerState.idle;
  int _normalTimerTotalSeconds = 0;
  int _normalTimerRemainingSeconds = 0;
  DateTime? _normalTimerStartTimestamp;
  int _normalTimerElapsedBeforePause = 0;

  NormalTimerState get normalTimerState => _normalTimerState;
  int get normalTimerTotalSeconds => _normalTimerTotalSeconds;
  int get normalTimerRemainingSeconds => _normalTimerRemainingSeconds;
  double get normalTimerProgress {
    if (_normalTimerTotalSeconds == 0) return 0.0;
    return (_normalTimerTotalSeconds - _normalTimerRemainingSeconds) /
        _normalTimerTotalSeconds;
  }

  String get formattedNormalTimerRemaining =>
      _formatSeconds(_normalTimerRemainingSeconds);

  ClockProvider({
    required this.audioService,
    required this.storageService,
    required this.notificationService,
  }) {
    _loadAlarms();
  }

  void attachTickerProvider(TickerProvider provider) {
    _tickerProvider = provider;
    _startClockTicker();
  }

  void detachTickerProvider() {
    _disposeClockTicker();
    _tickerProvider = null;
  }

  void _startClockTicker() {
    _disposeClockTicker();
    if (_tickerProvider == null) return;

    _isClockActive = true;
    _lastNotifiedMinute = -1;
    _clockTicker = _tickerProvider!.createTicker(_onClockTick);
    _clockTicker!.start();
  }

  void _disposeClockTicker() {
    _isClockActive = false;
    _clockTicker?.stop();
    _clockTicker?.dispose();
    _clockTicker = null;
  }

  void _onClockTick(Duration elapsed) {
    final now = DateTime.now();
    _currentTime = now;

    _updateStopwatchDisplay(now);
    _updateNormalTimerDisplay(now);
    _checkAlarms(now);

    final currentMinute = now.hour * 60 + now.minute;
    if (currentMinute != _lastNotifiedMinute) {
      _lastNotifiedMinute = currentMinute;
      notifyListeners();
    } else if (_stopwatchState == StopwatchState.running ||
        _normalTimerState == NormalTimerState.running) {
      notifyListeners();
    }
  }

  // --- Alarm Methods ---

  Future<void> addAlarm({
    required int hour,
    required int minute,
    String label = '',
    List<int> repeatDays = const [],
  }) async {
    final alarm = AlarmData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      hour: hour,
      minute: minute,
      isEnabled: true,
      label: label,
      repeatDays: repeatDays,
    );
    _alarms.add(alarm);
    _saveAlarms();
    await audioService.play('button_click.mp3');
    notifyListeners();
  }

  Future<void> toggleAlarm(String alarmId) async {
    final index = _alarms.indexWhere((a) => a.id == alarmId);
    if (index == -1) return;

    _alarms[index] = _alarms[index].copyWith(
      isEnabled: !_alarms[index].isEnabled,
    );
    _saveAlarms();
    await audioService.play('button_click.mp3');
    notifyListeners();
  }

  Future<void> deleteAlarm(String alarmId) async {
    _alarms.removeWhere((a) => a.id == alarmId);
    _saveAlarms();
    await audioService.play('button_click.mp3');
    notifyListeners();
  }

  Future<void> dismissAlarm() async {
    _isAlarmRinging = false;
    _ringingAlarm = null;
    await audioService.stop();
    await audioService.play('button_click.mp3');
    notifyListeners();
  }

  void _checkAlarms(DateTime now) {
    if (_isAlarmRinging) return;

    for (final alarm in _alarms) {
      if (!alarm.isEnabled) continue;

      if (alarm.hour == now.hour &&
          alarm.minute == now.minute &&
          now.second == 0) {
        if 
