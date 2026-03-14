import 'package:flutter/material.dart';
import '../../core/models/task_model.dart';

class TaskListItem extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskListItem({
    Key? key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  }) : super(key: key);

  String _formatTime(int seconds) {
    if (seconds == 0) return '0m';
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24.0),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: task.isCompleted ? const Color(0xFF39FF14).withOpacity(0.3) : const Color(0xFF333333),
            width: 1.0,
          ),
        ),
        child: Row(
          children:[
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28.0,
                height: 28.0,
                decoration: BoxDecoration(
                  color: task.isCompleted ? const Color(0xFF39FF14) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isCompleted ? const Color(0xFF39FF14) : const Color(0xFF777777),
                    width: 2.0,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 18.0, color: Colors.black)
                    : null,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: task.isCompleted ? const Color(0xFF777777) : Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    child: Text(task.title),
                  ),
                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      task.description!,
                      style: const TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 13.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                _formatTime(task.timeSpentSeconds),
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
