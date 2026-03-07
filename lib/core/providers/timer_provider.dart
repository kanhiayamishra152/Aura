import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:focus_app/core/services/audio_service.dart';
import 'package:focus_app/core/services/storage_service.dart';
import 'package:focus_app/core/services/notification_service.dart';

enum TimerState {
  idle,
  running,
  paused,
  completed,
}

class TimerProvider extends ChangeNotifier {
  final AudioService audioService;
  final StorageService storageService;
  final NotificationService notificationService;

  TimerState _timerState = TimerState.idle;
  int _totalDurationSeconds = 0;
  int _remainingSeconds = 0;
  DateTime? _startTimestamp;
  DateTime? _pauseTimestamp;
  int _elapsedBeforePause = 0;
  Ticker? _ticker;
  TickerProvider? _tickerProvider;

  int _totalFocusSessionsCompleted = 0;
  int _totalFocusMinutesAccumulated = 0;
  int _currentStreakDays = 0;
  DateTime? _lastSessionDate;

  TimerState get timerState => _timerState;
  int get totalDurationSeconds => _totalDurationSeconds;
  int get remainingSeconds => _remainingSeconds;
  int get elapsedSeconds => _totalDurationSeconds - _remainingSeconds;
  double get progress {
    if (_totalDurationSeconds == 0) return 0.0;
    return elapsedSeconds / _totalDurationSeconds;
  }

  String get formattedRemaining => _formatDuration(_remainingSeconds);
  String get formattedTotal => _formatDuration(_totalDurationSeconds);
  String get formattedElapsed => _formatDuration(elapsedSeconds);

  int get totalFocusSessionsCompleted => _totalFocusSessionsCompleted;
  int get totalFocusMinutesAccumulated => _totalFocusMinutesAccumulated;
  int get currentStreakDays => _currentStreakDays;

  bool get isIdle => _timerState == TimerState.idle;
  bool get isRunning => _timerState == TimerState.running;
  bool get isPaused => _timerState == TimerState.paused;
  bool get isCompleted => _timerState == TimerState.completed;

  TimerProvider({
    required this.audioService,
    required this.storageService,
    required this.notificationService,
  }) {
    _loadStats();
    _restoreTimerState();
  }

  void attachTickerProvider(TickerProvider provider) {
    _tickerProvider = provider;
    if (_timerState == TimerState.running) {
      _startTicker();
    }
  }

  void detachTickerProvider() {
    _disposeTicker();
    _tickerProvider = null;
  }

  Future<void> startTimer({
    required int hours,
    required int minutes,
  }) async {
    final totalSeconds = (hours * 3600) + (minutes * 60);
    if (totalSeconds <= 0) return;

    _totalDurationSeconds = totalSeconds;
    _remainingSeconds = totalSeconds;
    _elapsedBeforePause = 0;
    _startTimestamp = DateTime.now();
    _pauseTimestamp = null;
    _timerState = TimerState.running;

    _saveTimerState();
    _startTicker();

    await audioService.play('timer_start.mp3');
    notifyListeners();
  }

  Future<void> pauseTimer() async {
    if (_timerState != TimerState.running) return;

    _pauseTimestamp = DateTime.now();
    if (_startTimestamp != null) {
      _elapsedBeforePause += _pauseTimestamp!.difference(_startTimestamp!).inSeconds;
    }
    _startTimestamp = null;
    _timerState = TimerState.paused;

    _disposeTicker();
    _saveTimerState();

    await audioService.play('button_click.mp3');
    notifyListeners();
  }

  Future<void> resumeTimer() async {
    if (_timerState != TimerState.paused) return;

    _startTimestamp = DateTime.now();
    _pauseTimestamp = null;
    _timerState = TimerState.running;

    _startTicker();
    _saveTimerState();

    await audioService.play('timer_start.mp3');
    notifyListeners();
  }

  Future<void> stopTimer() async {
    _timerState = TimerState.idle;
    _totalDurationSeconds = 0;
    _remainingSeconds = 0;
    _startTimestamp = null;
    _pauseTimestamp = null;
    _elapsedBeforePause = 0;

    _disposeTicker();
    _clearTimerState();

    await audioService.play('button_click.mp3');
    notifyListeners();
  }

  Future<void> _onTimerComplete() async {
    _timerState = TimerState.completed;
    _remainingSeconds = 0;

    _disposeTicker();
    _clearTimerState();

    final sessionMinutes = _totalDurationSeconds ~/ 60;
    _totalFocusSessionsCompleted += 1;
    _totalFocusMinutesAccumulated += sessionMinutes;
    _updateStreak();
    _saveStats();

    await audioService.play('timer_complete.mp3');

    await notificationService.showNotification(
      title: 'Focus Session Complete',
      body: 'Great work! You stayed focused for $sessionMinutes minutes.',
    );

    notifyListeners();
  }

  void _startTicker() {
    _disposeTicker();
    if (_tickerProvider == null) return;

    _ticker = _tickerProvider!.createTicker(_onTick);
    _ticker!.start();
  }

  void _onTick(Duration elapsed) {
    if (_timerState != TimerState.running || _startTimestamp == null) return;

    final now = DateTime.now();
    final currentElapsed = _elapsedBeforePause + now.difference(_startTimestamp!).inSeconds;
    final newRemaining = _totalDurationSeconds - currentElapsed;

    if (newRemaining <= 0) {
      _remainingSeconds = 0;
      _onTimerComplete();
      return;
    }

    if (newRemaining != _remainingSeconds) {
      _remainingSeconds = newRemaining;
      notifyListeners();
    }
  }

  void _disposeTicker() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
  }

  void recalculateOnResume() {
    if (_timerState != TimerState.running || _startTimestamp == null) return;

    final now = DateTime.now();
    final currentElapsed = _elapsedBeforePause + now.difference(_startTimestamp!).inSeconds;
    final newRemaining = _totalDurationSeconds - currentElapsed;

    if (newRemaining <= 0) {
      _remainingSeconds = 0;
      _onTimerComplete();
      return;
    }

    _remainingSeconds = newRemaining;
    notifyListeners();
  }

  void _saveTimerState() {
    storageService.setString('timer_state', _timerState.name);
    storageService.setInt('timer_total_duration', _totalDurationSeconds);
    storageService.setInt('timer_elapsed_before_pause', _elapsedBeforePause);
    if (_startTimestamp != null) {
      storageService.setString(
        'timer_start_timestamp',
        _startTimestamp!.toIso8601String(),
      );
    } else {
      storageService.remove('timer_start_timestamp');
    }
    if (_pauseTimestamp != null) {
      storageService.setString(
        'timer_pause_timestamp',
        _pauseTimestamp!.toIso8601String(),
      );
    } else {
      storageService.remove('timer_pause_timestamp');
    }
  }

  void _clearTimerState() {
    storageService.remove('timer_state');
    storageService.remove('timer_total_duration');
    storageService.remove('timer_elapsed_before_pause');
    storageService.remove('timer_start_timestamp');
    storageService.remove('timer_pause_timestamp');
  }

  void _restoreTimerState() {
    final savedState = storageService.getString('timer_state');
    if (savedState == null) return;

    final savedTotal = storageService.getInt('timer_total_duration') ?? 0;
    final savedElapsed = storageService.getInt('timer_elapsed_before_pause') ?? 0;
    final savedStartStr = storageService.getString('timer_start_timestamp');
    final savedPauseStr = storageService.getString('timer_pause_timestamp');

    if (savedTotal <= 0) {
      _clearTimerState();
      return;
    }

    _totalDurationSeconds = savedTotal;
    _elapsedBeforePause = savedElapsed;

    if (savedState == TimerState.running.name && savedStartStr != null) {
      _startTimestamp = DateTime.tryParse(savedStartStr);
      if (_startTimestamp != null) {
        final now = DateTime.now();
        final currentElapsed = _elapsedBeforePause + now.difference(_startTimestamp!).inSeconds;
        final remaining = _totalDurationSeconds - currentElapsed;

        if (remaining <= 0) {
          _remainingSeconds = 0;
          _timerState = TimerState.idle;
          _clearTimerState();
          _totalFocusSessionsCompleted += 1;
          _totalFocusMinutesAccumulated += _totalDurationSeconds ~/ 60;
          _updateStreak();
          _saveStats();
        } else {
          _remainingSeconds = remaining;
          _timerState = TimerState.running;
        }
      } else {
        _clearTimerState();
      }
    } else if (savedState == TimerState.paused.name) {
      _startTimestamp = null;
      _pauseTimestamp = savedPauseStr != null ? DateTime.tryParse(savedPauseStr) : 
