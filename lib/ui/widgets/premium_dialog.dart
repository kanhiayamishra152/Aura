import 'package:flutter/material.dart';
import 'dart:ui';

class PremiumDialog extends StatefulWidget {
  final String title;
  final String message;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final bool isDestructive;

  const PremiumDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.isDestructive = false,
  }) : super(key: key);

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String message,
    required String primaryButtonText,
    required VoidCallback onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    bool isDestructive = false,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PremiumDialog',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return PremiumDialog(
          title: title,
          message: message,
          primaryButtonText: primaryButtonText,
          onPrimaryPressed: onPrimaryPressed,
          secondaryButtonText: secondaryButtonText,
          onSecondaryPressed: onSecondaryPressed,
          isDestructive: isDestructive,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: animation.value * 8.0,
            sigmaY: animation.value * 8.0,
          ),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  State<PremiumDialog> createState() => _PremiumDialogState();
}

class _PremiumDialogState extends State<PremiumDialog> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDestructive ? Colors.redAccent : const Color(0xFF39FF14);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: const Color(0xFF333333),
            width: 1.5,
          ),
          boxShadow:[
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 24.0,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 16.0,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32.0),
            Row(
              children:[
                if (widget.secondaryButtonText != null) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onSecondaryPressed ?? () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: const Color(0xFF555555),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.secondaryButtonText!.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                ],
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onPrimaryPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow:[
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 12.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.primaryButtonText.toUpperCase(),
                          style: TextStyle(
                            color: widget.isDestructive ? Colors.white : Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
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
