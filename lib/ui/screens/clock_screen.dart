import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({Key? key}) : super(key: key);

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Stopwatch State
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _stopwatchTimer;
  final List<String> _laps =[];

  // Mock Alarms
  final List<Map<String, dynamic>> _alarms =[
    {'id': '1', 'time': '06:00 AM', 'label': 'Morning Routine', 'isActive': true},
    {'id': '2', 'time': '08:30 AM', 'label': 'Deep Work Start', 'isActive': false},
    {'id': '3', 'time': '10:00 PM', 'label': 'Wind Down', 'isActive': true},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stopwatchTimer?.cancel();
    super.dispose();
  }

  void _toggleStopwatch() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _stopwatchTimer?.cancel();
      } else {
        _stopwatch.start();
        _stopwatchTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
          setState(() {}); // Update UI for stopwatch milliseconds
        });
      }
    });
  }

  void _resetStopwatch() {
    HapticFeedback.mediumImpact();
    setState(() {
      _stopwatch.stop();
      _stopwatch.reset();
      _stopwatchTimer?.cancel();
      _laps.clear();
    });
  }

  void _recordLap() {
    if (_stopwatch.isRunning) {
      HapticFeedback.lightImpact();
      setState(() {
        _laps.insert(0, _formattedStopwatchTime(_stopwatch.elapsedMilliseconds));
      });
    }
  }

  String _formattedStopwatchTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate() % 100;
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / (1000 * 60)).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    String hundredsStr = hundreds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr.$hundredsStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'TIME CENTER',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00FF00),
          labelColor: const Color(0xFF00FF00),
          unselectedLabelColor: Colors.grey,
          dividerColor: Colors.transparent,
          tabs: const[
            Tab(text: 'CLOCK'),
            Tab(text: 'ALARM'),
            Tab(text: 'STOPWATCH'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children:[
          _buildClockTab(),
          _buildAlarmTab(),
          _buildStopwatchTab(),
        ],
      ),
    );
  }

  Widget _buildClockTab() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Text(
            '$hour:$minute',
            style: const TextStyle(
              fontSize: 80.0,
              fontWeight: FontWeight.w200,
              color: Colors.white,
              letterSpacing: 4.0,
            ),
          ),
          Text(
            period,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00FF00),
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _alarms.length,
      itemBuilder: (context, index) {
        final alarm = _alarms[index];
        return Dismissible(
          key: Key(alarm['id']),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16.0),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 32.0),
          ),
          onDismissed: (direction) {
            HapticFeedback.heavyImpact();
            setState(() {
              _alarms.removeAt(index);
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFF1A1A1A)),
            ),
            child: Row(
              children:[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm['time'],
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.w300,
                        color: alarm['isActive'] ? Colors.white : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      alarm['label'],
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Switch(
                  value: alarm['isActive'],
                  activeColor: const Color(0xFF00FF00),
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      alarm['isActive'] = val;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStopwatchTab() {
    return Column(
      children:[
        const SizedBox(height: 60.0),
        Text(
          _formattedStopwatchTime(_stopwatch.elapsedMilliseconds),
          style: const TextStyle(
            fontSize: 64.0,
            fontWeight: FontWeight.w200,
            color: Colors.white,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 48.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            IconButton(
              onPressed: _resetStopwatch,
              icon: const Icon(Icons.refresh),
              color: Colors.grey,
              iconSize: 32.0,
            ),
            GestureDetector(
              onTap: _toggleStopwatch,
              child: Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _stopwatch.isRunning ? Colors.transparent : const Color(0xFF00FF00),
                  border: Border.all(color: const Color(0xFF00FF00), width: 2.0),
                ),
                child: Icon(
                  _stopwatch.isRunning ? Icons.pause : Icons.play_arrow,
                  color: _stopwatch.isRunning ? const Color(0xFF00FF00) : Colors.black,
                  size: 40.0,
                ),
              ),
            ),
            IconButton(
              onPressed: _recordLap,
              icon: const Icon(Icons.flag_outlined),
              color: _stopwatch.isRunning ? Colors.white : Colors.grey,
              iconSize: 32.0,
            ),
          ],
        ),
        const SizedBox(height: 40.0),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF121212),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
            ),
            child: ListView.builder(
