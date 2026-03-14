import 'package:flutter/material.dart';

class PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PremiumBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withOpacity(0.95),
        borderRadius: BorderRadius.circular(32.0),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1.0,
        ),
        boxShadow: const[
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20.0,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:[
              _buildNavItem(Icons.dashboard_rounded, 'Home', 0),
              _buildNavItem(Icons.timer_rounded, 'Focus', 1),
              _buildNavItem(Icons.leaderboard_rounded, 'Rank', 2),
              _buildNavItem(Icons.person_rounded, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFF39FF14) : const Color(0xFF777777);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF39FF14).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children:[
            Icon(
              icon,
              color: color,
              size: 24.0,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8.0),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
