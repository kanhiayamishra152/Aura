import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_constants.dart';

/// Centralized Audio Service for the entire application.
/// Battery Optimized:
/// - Uses a single AudioPlayer instance instead of creating new ones per sound.
/// - Preloads nothing into memory - plays directly from asset path.
/// - Releases resources immediately after playback completes.
/// - Respects user preference for sound on/off.
/// - Volume kept optimal to reduce speaker power consumption.
class AudioService {
  AudioService._internal();
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioPlayer? _player;
  bool _isSoundEnabled = true;
  bool _isInitialized = false;

  // --- Sound File Paths ---
  static const String appStartup = 'audio/app_startup.mp3';
  static const String buttonClick = 'audio/button_click.mp3';
  static const String buttonHover = 'audio/button_hover.mp3';
  static const String timerStart = 'audio/timer_start.mp3';
  static const String timerTick = 'audio/timer_tick.mp3';
  static const String timerPause = 'audio/timer_pause.mp3';
  static const String timerResume = 'audio/timer_resume.mp3';
  static const String timerComplete = 'audio/timer_complete.mp3';
  static const String alarmRing = 'audio/alarm_ring.mp3';
  static const String alarmSnooze = 'audio/alarm_snooze.mp3';
  static const String rankUp = 'audio/rank_up.mp3';
  static const String notification = 'audio/notification.mp3';
  static const String tabSwitch = 'audio/tab_switch.mp3';
  static const String error = 'audio/error.mp3';
  static const String success = 'audio/success.mp3';
  static const String focusModeOn = 'audio/focus_mode_on.mp3';
  static const String focusModeOff = 'audio/focus_mode_off.mp3';

  /// Initialize the audio service.
  /// Loads user sound preference from SharedPreferences.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _isSoundEnabled = prefs.getBool(AppConstants.prefSoundEnabled) ?? true;
      _isInitialized = true;
    } catch (e) {
      _isSoundEnabled = true;
      _isInitialized = true;
    }
  }

  /// Play a sound from the asset path.
  /// Battery Optimization:
  /// - Creates player only when needed.
  /// - Stops any currently playing sound before starting new one.
  /// - Uses low volume (0.7) to reduce speaker power draw.
  /// - Releases player state after completion.
  Future<void> play(String assetPath) async {
    if (!_isSoundEnabled) return;

    try {
      // Stop and release previous player if exists
      if (_player != null) {
        await _player!.stop();
        await _player!.release();
        _player = null;
      }

      _player = AudioPlayer();
      _player!.setReleaseMode(ReleaseMode.stop);

      await _player!.setVolume(0.7);
      await _player!.play(AssetSource(assetPath));

      // Auto-release after playback completes
      _player!.onPlayerComplete.listen((_) {
        _releasePlayer();
      });
    } catch (e) {
      // Silent fail - audio should never crash the app
      _releasePlayer();
    }
  }

  /// Play a sound with custom volume.
  /// Used for subtle sounds like button_hover and tab_switch.
  Future<void> playWithVolume(String assetPath, double volume) async {
    if (!_isSoundEnabled) return;

    try {
      if (_player != null) {
        await _player!.stop();
        await _player!.release();
        _player = null;
      }

      _player = AudioPlayer();
      _player!.setReleaseMode(ReleaseMode.stop);

      final double clampedVolume = volume.clamp(0.0, 1.0);
      await _player!.setVolume(clampedVolume);
      await _player!.play(AssetSource(assetPath));

      _player!.onPlayerComplete.listen((_) {
        _releasePlayer();
      });
    } catch (e) {
      _releasePlayer();
    }
  }

  /// Play alarm sound in loop mode.
  /// Used only for alarm_ring.mp3 which needs continuous playback.
  Future<void> playLoop(String assetPath) async {
    if (!_isSoundEnabled) return;

    try {
      if (_player != null) {
        await _player!.stop();
        await _player!.release();
        _player = null;
      }

      _player = AudioPlayer();
      _player!.setReleaseMode(ReleaseMode.loop);

      await _player!.setVolume(0.9);
      await _player!.play(AssetSource(assetPath));
    } catch (e) {
      _releasePlayer();
    }
  }

  /// Stop any currently playing sound.
  Future<void> stop() async {
    try {
      if (_player != null) {
        await _player!.stop();
        _releasePlayer();
      }
    } catch (e) {
      _releasePlayer();
    }
  }

  /// Update sound enabled/disabled preference.
  Future<void> setSoundEnabled(bool enabled) async {
    _isSoundEnabled = enabled;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefSoundEnabled, enabled);

      // If sound is disabled, stop any currently playing audio
      if (!enabled) {
        await stop();
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Get current sound enabled state.
  bool get isSoundEnabled => _isSoundEnabled;

  /// Release the player and free memory.
  void _releasePlayer() {
    try {
      _player?.release();
      _player = null;
    } catch (e) {
      _player = null;
    }
  }

  /// Dispose the service completely.
  /// Call this only when the app is being terminated.
  Future<void> dispose() async {
    try {
      if (_player != null) {
        await _player!.stop();
        await _player!.release();
        _player = null;
      }
      _isInitialized = false;
    } catch (e) {
      _player = null;
      _isInitialized = false;
    }
  }

  // --- Convenience Methods ---
  // These make it easy to call specific sounds from anywhere in the app.

  Future<void> playAppStartup() async {
    await play(appStartup);
  }

  Future<void> playButtonClick() async {
    await playWithVolume(buttonClick, 0.6);
  }

  Future<void> playButtonHover() async {
    await playWithVolume(buttonHover, 0.3);
  }

  Future<void> playTimerStart() async {
    await play(timerStart);
  }

  Future<void> playTimerTick() async {
    await playWithVolume(timerTick, 0.4);
  }

  Future<void> playTimerPause() async {
    await play(timerPause);
  }

  Future<void> playTimerResume() async {
    await play(timerResume);
  }

  Future<void> playTimerComplete() async {
    await play(timerComplete);
  }

  Future<void> playAlarmRing() async {
    await playLoop(alarmRing);
  }

  Future<void> playAlarmSnooze() async {
    await play(alarmSnooze);
  }

  Future<void> playRankUp() async {
    await play(rankUp);
  }

  Future<void> playNotification() async {
    await playWithVolume(notification, 0.5);
  }

  Future<void> playTabSwitch() async {
    await playWithVolume(tabSwitch, 0.3);
  }

  Future<void> playError() async {
    await playWithVolume(error, 0.5);
  }

  Future<void> playSuccess() async {
    await play(success);
  }

  Future<void> playFocusModeOn() async {
    await play(focusModeOn);
  }

  Future<void> playFocusModeOff() async {
    await play(focusModeOff);
  }
}
