import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// A custom painter widget to display a premium bar chart for weekly activity.
class WeeklyActivityChart extends StatelessWidget {
  final List<int> dailyDurations; // List of 7 integers representing seconds focused for each day
  final double maxHeight; 

  const WeeklyActivityChart({
    Key? key,
    required this.dailyDurations,
    this.maxHeight = 150,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find max value to scale bars correctly
    final int maxSeconds = dailyDurations.isEmpty 
        ? 1 
        : (dailyDurations.reduce((a, b) => a > b ? a : b)).clamp(1, double.maxFinite.toInt());

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[850]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Weekly Activity",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.bar_chart_rounded, color: Colors.grey[600]),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: maxHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _buildBars(maxSeconds),
            ),
          ),
          const SizedBox(height: 12),
          _buildLabels(),
        ],
      ),
    );
  }

  List<Widget> _buildBars(int maxSeconds) {
    return dailyDurations.map((seconds) {
      // Calculate height percentage
      double heightFactor = seconds / maxSeconds;
      // Clamp heightFactor to avoid visual issues if data is weird
      if (heightFactor.isNaN) heightFactor = 0;
      
      double barHeight = (maxHeight * heightFactor).clamp(5.0, maxHeight);

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: barHeight),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Container(
            width: 28,
            height: value,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentGreen, Color(0xFF00E676)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGreen.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ],
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildLabels() {
    final now = DateTime.now();
    List<String> days = [];
    
    // Generate labels for last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      days.add(_getDayAbbreviation(date.weekday));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days.map((day) {
        return SizedBox(
          width: 28,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        );
      }).toList(),
    );
  }

  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case 1: return "M";
      case 2: return "T";
      case 3: return "W";
      case 4: return "T";
      case 5: return "F";
      case 6: return "S";
      case 7: return "S";
      default: return "";
    }
  }
}
