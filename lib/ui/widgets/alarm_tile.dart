import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../core/models/alarm_model.dart';

class AlarmTile extends StatelessWidget {
  final AlarmModel alarm;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const AlarmTile({
    Key? key,
    required this.alarm,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  }) : super(key: key);

  String _getRepeatDaysText() {
    if (alarm.repeatDays.isEmpty) {
      return "One time";
    }
    // Simple logic to show days. In production, you might want "Mon, Tue" format
    return "Repeat: ${alarm.repeatDays.length} days";
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(alarm.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        onDelete();
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceBlack,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: alarm.isActive ? AppColors.accentGreen : Colors.grey[850]!,
              width: alarm.isActive ? 1.5 : 1,
            ),
            boxShadow: alarm.isActive
                ? [
                    BoxShadow(
                      color: AppColors.accentGreen.withOpacity(0.1),
                      blurRadius: 10,
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Time and Label Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alarm.time,
                    style: TextStyle(
                      color: alarm.isActive ? Colors.white : Colors.grey[600],
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alarm.label.isEmpty ? "Alarm" : alarm.label,
                    style: TextStyle(
                      color: alarm.isActive ? Colors.white70 : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRepeatDaysText(),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              // Toggle Switch Section
              Switch.adaptive(
                value: alarm.isActive,
                activeColor: AppColors.accentGreen,
                onChanged: (value) => onToggle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
