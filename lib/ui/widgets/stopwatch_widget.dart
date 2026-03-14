import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class StopwatchWidget extends StatefulWidget {
  const StopwatchWidget({Key? key}) : super(key: key);

  @override
  _StopwatchWidgetState createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends State<StopwatchWidget> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  final List<String> _laps = [];

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(const Duration(milliseconds: 30), _updateTimer);
  }

  void _updateTimer(Timer timer) {
    if (_stopwatch.isRunning) {
      setState(() {});
    }
  }

  void _handleStartStop() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    } else {
      _stopwatch.start();
    }
    setState(() {});
  }

  void _handleLap() {
    if (_stopwatch.isRunning) {
      String lapTime = _formatTime(_stopwatch.elapsedMilliseconds);
      setState(() {
        _laps.add(lapTime);
      });
    }
  }

  void _handleReset() {
    _stopwatch.stop();
    _stopwatch.reset();
    setState(() {
      _laps.clear();
    });
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate() % 100;
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / (1000 * 60)).truncate() % 60;
    int hours = (milliseconds / (1000 * 60 * 60)).truncate();

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    String hundredsStr = hundreds.toString().padLeft(2, '0');

    if (hours > 0) {
      return "$hoursStr:$minutesStr:$secondsStr.$hundredsStr";
    }
    return "$minutesStr:$secondsStr.$hundredsStr";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[850]!),
      ),
      child: Column(
        children: [
          // Timer Display
          FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              _formatTime(_stopwatch.elapsedMilliseconds),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 60,
                fontWeight: FontWeight.w200,
                fontFeatures: [FontFeature.tabularFigures()],
                letterSpacing: 2,
              ),
            ),
          ),
          
          const SizedBox(height: 30),

          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Reset Button
              GestureDetector(
                onTap: _handleReset,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[800],
                  ),
                  child: const Icon(Icons.refresh, color: Colors.white, size: 24),
                ),
              ),

              // Start/Stop Button
              GestureDetector(
                onTap: _handleStartStop,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _stopwatch.isRunning ? Colors.redAccent : AppColors.accentGreen,
                    boxShadow: [
                      BoxShadow(
                        color: (_stopwatch.isRunning ? Colors.redAccent : AppColors.accentGreen).withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Icon(
                    _stopwatch.isRunning ? Icons.pause : Icons.play_arrow,
                    color: _stopwatch.isRunning ? Colors.white : Colors.black,
                    size: 36,
                  ),
                ),
              ),

              // Lap Button
              GestureDetector(
                onTap: _handleLap,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[800],
                  ),
                  child: const Icon(Icons.flag, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Laps List
          if (_laps.isNotEmpty)
            Container(
              height: 150,
              child: ListView.builder(
                itemCount: _laps.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Lap ${index + 1}",
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    trailing: Text(
                      _laps[index],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
