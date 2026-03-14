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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentGreen,
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
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
         return AlarmTile(
           alarm: AlarmModel(id: 1, time: "08:00", label: "Wake Up", repeatDays: []),
           onTap: () {},
           onToggle: () {},
           onDelete: () {},
         );
      },
    );
  }

  Widget _buildClockTab() {
    return Center(
      child: Text("Clock", style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildStopwatchTab() {
    return const StopwatchWidget();
  }
}
