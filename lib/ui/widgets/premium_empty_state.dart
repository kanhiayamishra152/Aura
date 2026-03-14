import 'package:flutter/material.dart';

class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const PremiumEmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF333333),
                width: 2.0,
              ),
            ),
            child: Icon(
              icon,
              size: 48.0,
              color: const Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 24.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 15.0,
              height: 1.5,
            ),
          ),
          if (actionText != null && onActionPressed != null) ...[
            const SizedBox(height: 32.0),
            GestureDetector(
              onTap: onActionPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: const Color(0xFF39FF14),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  actionText!.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF39FF14),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
