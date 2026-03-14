import 'package:flutter/material.dart';

class SessionSummaryScreen extends StatefulWidget {
  final int timeFocusedSeconds;
  final int xpGained;
  final int tasksCompleted;

  const SessionSummaryScreen({
    Key? key,
    required this.timeFocusedSeconds,
    required this.xpGained,
    required this.tasksCompleted,
  }) : super(key: key);

  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuint),
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  height: 140.0,
                  width: 140.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF39FF14),
                      width: 3.0,
                    ),
                    boxShadow:[
                      BoxShadow(
                        color: const Color(0xFF39FF14).withOpacity(0.2),
                        blurRadius: 30.0,
                        spreadRadius: 10.0,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Color(0xFF39FF14),
                      size: 64.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48.0),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children:[
                      const Text(
                        'SESSION COMPLETE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'You stayed focused for ${_formatDuration(widget.timeFocusedSeconds)}.',
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 48.0),
                      _buildStatRow(
                        icon: Icons.star_rounded,
                        label: 'XP Gained',
                        value: '+${widget.xpGained}',
                        color: const Color(0xFF39FF14),
                      ),
                      const SizedBox(height: 24.0),
                      _buildStatRow(
                        icon: Icons.task_alt_rounded,
                        label: 'Tasks Completed',
                        value: '${widget.tasksCompleted}',
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: () {
                    // Navigate back to Main Dashboard, clearing stack
                    Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    margin: const EdgeInsets.only(bottom: 32.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF39FF14),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: const[
                        BoxShadow(
                          color: Color(0x6639FF14),
                          blurRadius: 20.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'CONTINUE',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1.0,
        ),
      ),
      child: Row(
        children:[
          Icon(icon, color: color, size: 28.0),
          const SizedBox(width: 16.0),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
