// lib/core/services/audio_service.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum AppSound {
  appStartup,
  buttonClick,
  buttonHover,
  timerStart,
  timerTick,
  timerPause,
  timerResume,
  timerComplete,
  alarmRing,
  alarmSnooze,
  rankUp,
  notification,
  tabSwitch,
  error,
  success,
  focusModeOn,
  focusModeOff,
}

class AudioService {
  AudioService._internal();

  static final AudioService _instance = AudioService._internal();

  factory AudioService() {
    return _instance;
  }

  static AudioService get instance => _instance;

  final Map<AppSound, AudioPlayer> _players = <AppSound, AudioPlayer>{};
  final Map<AppSound, String> _soundPaths = <AppSound, String>{
    AppSound.appStartup: 'audio/app_startup.mp3',
    AppSound.buttonClick: 'audio/button_click.mp3',
    AppSound.buttonHover: 'audio/button_hover.mp3',
    AppSound.timerStart: 'audio/timer_start.mp3',
    AppSound.timerTick: 'audio/timer_tick.mp3',
    AppSound.timerPause: 'audio/timer_pause.mp3',
    AppSound.timerResume: 'audio/timer_resume.mp3',
    AppSound.timerComplete: 'audio/timer_complete.mp3',
    AppSound.alarmRing: 'audio/alarm_ring.mp3',
    AppSound.alarmSnooze: 'audio/alarm_snooze.mp3',
    AppSound.rankUp: 'audio/rank_up.mp3',
    AppSound.notification: 'audio/notification.mp3',
    AppSound.tabSwitch: 'audio/tab_switch.mp3',
    AppSound.error: 'audio/error.mp3',
    AppSound.success: 'audio/success.mp3',
    AppSound.focusModeOn: 'audio/focus_mode_on.mp3',
    AppSound.focusModeOff: 'audio/focus_mode_off.mp3',
  };

  bool _isInitialized = false;
  bool _isSoundEnabled = true;
  double _masterVolume = 1.0;

  bool get isInitialized => _isInitialized;
  bool get isSoundEnabled => _isSoundEnabled;
  double get masterVolume => _masterVolume;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      for (final AppSound sound in AppSound.values) {
        final AudioPlayer player = AudioPlayer();
        player.setReleaseMode(ReleaseMode.stop);
        await player.setSource(AssetSource(_soundPaths[sound]!));
        await player.setVolume(_masterVolume);
        _players[sound] = player;
      }

      _isInitialized = true;
      debugPrint('AudioService: All sounds pre-loaded successfully.');
    } catch (e) {
      debugPrint('AudioService: Error during initialization - $e');
      _isInitialized = false;
    }
  }

  Future<void> play(AppSound sound) async {
    if (!_isSoundEnabled) {
      return;
    }

    if (!_isInitialized) {
      debugPrint('AudioService: Not initialized. Attempting late init.');
      await initialize();
    }

    try {
      final AudioPlayer? player = _players[sound];
      if (player == null) {
        debugPrint('AudioService: No player found for $sound');
        return;
      }

      await player.stop();
      await player.setVolume(_masterVolume);
      await player.setSource(AssetSource(_soundPaths[sound]!));
      await player.resume();
    } catch (e) {
      debugPrint('AudioService: Error playing $sound - $e');
    }
  }

  Future<void> playLooping(AppSound sound) async {
    if (!_isSoundEnabled) {
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }

    try {
      final AudioPlayer? player = _players[sound];
      if (player == null) {
        return;
      }

      await player.stop();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(_masterVolume);
      await player.setSource(AssetSource(_soundPaths[sound]!));
      await player.resume();
    } catch (e) {
      debugPrint('AudioService: Error looping $sound - $e');
    }
  }

  Future<void> stop(AppSound sound) async {
    try {
      final AudioPlayer? player = _players[sound];
      if (player == null) {
        return;
      }

      await player.stop();
      await player.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('AudioService: Error stopping $sound - $e');
    }
  }

  Future<void> stopAll() async {
    try {
      for (final AudioPlayer player in _players.values) {
        await player.stop();
        await player.setReleaseMode(ReleaseMode.stop);
      }
    } catch (e) {
      debugPrint('AudioService: Error stopping all sounds - $e');
    }
  }

  Future<void> pause(AppSound sound) async {
    try {
      final AudioPlayer? player = _players[sound];
      if (player == null) {
        return;
      }

      await player.pause();
    } catch (e) {
      debugPrint('AudioService: Error pausing $sound - $e');
    }
  }

  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);

    try {
      for (final AudioPlayer player in _players.values) {
        await player.setVolume(_masterVolume);
      }
    } catch (e) {
      debugPrint('AudioService: Error setting volume - $e');
    }
  }

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;

    if (!enabled) {
      stopAll();
    }

    debugPrint('AudioService: Sound ${enabled ? "enabled" : "disabled"}.');
  }

  Future<void> playWithVolume(AppSound sound, double volume) async {
    if (!_isSoundEnabled) {
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }

    try {
      final AudioPlayer? player = _players[sound];
      if (player == null) {
        return;
      }

      final double clampedVolume = volume.clamp(0.0, 1.0);
      await player.stop();
      await player.setVolume(clampedVolume);
      await player.setSource(AssetSource(_soundPaths[sound]!));
      await player.resume();
    } catch (e) {
      debugPrint('AudioService: Error playing $sound with volume - $e');
    }
  }

  Future<void> dispose() async {
    try {
      for (final AudioPlayer player in _players.values) {
        await player.stop();
        await player.dispose();
      }
      _players.clear();
      _isInitialized = false;
      debugPrint('AudioService: All players disposed.');
    } catch (e) {
      debugPrint('AudioService: Error during dispose - $e');
    }
  }
}
