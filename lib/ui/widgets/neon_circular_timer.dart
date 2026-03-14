import 'dart:math';
import 'package:flutter/material.dart';

class NeonCircularTimer extends StatelessWidget {
  final double progress;
  final String timeLabel;
  final double size;

  const NeonCircularTimer({
    Key? key,
    required this.progress,
    required this.timeLabel,
    this.size = 280.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children:[
            CustomPaint(
              size: Size(size, size),
              painter: _NeonTimerPainter(progress: progress),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children:[
                Text(
                  timeLabel,
                  style: const TextStyle(
                    fontSize: 48.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'REMAINING',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 4.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NeonTimerPainter extends CustomPainter {
  final double progress;

  _NeonTimerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 15.0;

    // Background Track
    final trackPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Neon Glow Arc
    final glowPaint = Paint()
      ..color = const Color(0xFF00FF00).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    // Solid Neon Arc
    final progressPaint = Paint()
      ..color = const Color(0xFF00FF00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    final startAngle = -pi / 2;

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NeonTimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
