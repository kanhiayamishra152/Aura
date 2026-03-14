import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../widgets/stopwatch_widget.dart';
import '../widgets/alarm_tile.dart';
import '../../core/models/alarm_model.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({Key? key}) : super(key: key);

  @override
  _ClockScreenState createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBlack,
        elevation: 0,
        title: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentGreen,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: "ALARMS"),
            Tab(text: "CLOCK"),
            Tab(text: "TIMER"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlarmsTab(),
          _buildClockTab(),
          _buildStopwatchTab(),
        ],
      ),
    );
  }

  Widget _buildAlarmsTab() {
    // Mock data for demonstration
    final alarms = [
      AlarmModel(id: 1, time: "06:00", label: "Wake Up", repeatDays: [1,2,3,4,5], isActive: true),
      AlarmModel(id: 2, time: "08:30", label: "Workout", repeatDays: [], isActive: false),
    ];

    return ListView.builder(
      itemCount: alarms.length + 1, // +1 for add button
      itemBuilder: (context, index) {
        if (index == alarms.length) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceBlack,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                // Add alarm logic
              },
              icon: const Icon(Icons.add, color: AppColors.accentGreen),
              label: const Text("Add Alarm", style: TextStyle(color: Colors.white)),
            ),
          );
        }
        return AlarmTile(
          alarm: alarms[index],
          onTap: () {},
          onToggle: () {},
          onDelete: () {},
        );
      },
    );
  }

  Widget _buildClockTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              final now = DateTime.now();
              return Text(
                "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.w200,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
            style: TextStyle(color: Colors.grey[500], fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildStopwatchTab() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: StopwatchWidget(),
    );
  }
}
