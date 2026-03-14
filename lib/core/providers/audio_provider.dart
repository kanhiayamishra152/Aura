import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioService _audioService;

  bool _isPlaying = false;
  String? _currentTrackId;
  double _volume = 0.5;

  AudioProvider(this._audioService);

  bool get isPlaying => _isPlaying;
  String? get currentTrackId => _currentTrackId;
  double get volume => _volume;

  final Map<String, String> premiumSoundscapes = {
    'deep_focus': 'Deep Space Ambient',
    'rain_cafe': 'Rain on Window & Cafe',
    'binaural_alpha': 'Alpha Waves (40Hz)',
    'forest_wind': 'Midnight Forest',
  };

  Future<void> playTrack(String trackId) async {
    try {
      await _audioService.play(trackId);
      _currentTrackId = trackId;
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('AudioProvider Play Error: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _audioService.pause();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      debugPrint('AudioProvider Pause Error: $e');
    }
  }

  Future<void> togglePlayback() async {
    if (_isPlaying) {
      await pause();
    } else if (_currentTrackId != null) {
      await playTrack(_currentTrackId!);
    } else {
      // Default track
      await playTrack('deep_focus');
    }
  }

  Future<void> setVolume(double newVolume) async {
    _volume = newVolume.clamp(0.0, 1.0);
    await _audioService.setVolume(_volume);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
