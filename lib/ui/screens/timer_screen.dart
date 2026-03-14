import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/neon_circular_timer.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      _pulseController.repeat(reverse: true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _stopTimer();
          _onTimerComplete();
        }
      });
    } else {
      _pulseController.stop();
      _timer?.cancel();
    }
  }

  void _stopTimer() {
    HapticFeedback.heavyImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
    });
    _pulseController.stop();
    _pulseController.reset();
  }

  void _onTimerComplete() {
    HapticFeedback.vibrate();
    if (!mounted) return;
    
    // In production, sync with TimerProvider / NotificationService here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Focus Session Completed!',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF00FF00),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds == 0 ? 0.0 : 1.0 - (_remainingSeconds / _totalSeconds);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            const Spacer(),
            Center(
              child: NeonCircularTimer(
                progress: progress,
                timeLabel: _formattedTime,
              ),
            ),
            const Spacer(),
            _buildControls(),
            const SizedBox(height: 48.0),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
        IconButton(
          onPressed: _stopTimer,
          icon: const Icon(Icons.stop_rounded),
          color: Colors.white54,
          iconSize: 42.0,
        ),
        const SizedBox(width: 32.0),
        GestureDetector(
          onTap: _toggleTimer,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _isRunning ? 1.0 + (_pulseController.value * 0.05) : 1.0,
                child: Container(
                  height: 80.0,
                  width: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRunning ? Colors.transparent : const Color(0xFF00FF00),
                    border: Border.all(
                      color: const Color(0xFF00FF00),
                      width: 2.0,
                    ),
                    boxShadow: _isRunning
                        ? []
                        :[
                            BoxShadow(
                              color: const Color(0xFF00FF00).withOpacity(0.3),
                              blurRadius: 20.0,
                              spreadRadius: 5.0,
                            )
                          ],
                  ),
                  child: Icon(
                    _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: _isRunning ? const Color(0xFF00FF00) : Colors.black,
                    size: 42.0,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 32.0),
        IconButton(
          onPressed: () {
            // Future logic to adjust time limits
          },
          icon: const Icon(Icons.tune_rounded),
          color: Colors.white54,
          iconSize: 42.0,
        ),
      ],
    );
  }
}
