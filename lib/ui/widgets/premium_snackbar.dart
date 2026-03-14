import 'package:flutter/material.dart';

class PremiumSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    bool isError = false,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final color = isError ? Colors.redAccent : const Color(0xFF39FF14);

    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 1.0,
            ),
            boxShadow:[
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10.0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: color, size: 24.0),
                const SizedBox(width: 16.0),
              ],
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
