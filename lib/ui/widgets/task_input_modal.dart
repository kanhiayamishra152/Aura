import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class TaskInputModal extends StatefulWidget {
  final Function(String taskName) onStart;

  const TaskInputModal({
    Key? key,
    required this.onStart,
  }) : super(key: key);

  @override
  _TaskInputModalState createState() => _TaskInputModalState();
}

class _TaskInputModalState extends State<TaskInputModal> {
  final TextEditingController _taskController = TextEditingController();
  final List<String> _quickTasks = [
    "Study",
    "Workout",
    "Reading",
    "Coding",
    "Meditation"
  ];

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _handleStart() {
    final task = _taskController.text.trim();
    widget.onStart(task.isEmpty ? "Focus Session" : task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "What are you focusing on?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Text Field
            TextField(
              controller: _taskController,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: "Enter task name...",
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: AppColors.backgroundBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accentGreen, width: 1),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Quick Select Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickTasks.map((task) {
                return GestureDetector(
                  onTap: () {
                    _taskController.text = task;
                  },
                  child: Chip(
                    label: Text(task, style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[700]!),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _handleStart,
                child: const Text(
                  "Start Focus",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
