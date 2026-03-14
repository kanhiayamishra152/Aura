import 'package:flutter/material.dart';

class PremiumPageTransition<T> extends PageRouteBuilder<T> {
  final Widget page;
  final bool slideUp;

  PremiumPageTransition({
    required this.page,
    this.slideUp = false,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (slideUp) {
              final slideAnimation = Tween<Offset>(
                begin: const Offset(0.0, 0.15),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutQuint,
                reverseCurve: Curves.easeInQuint,
              ));

              return SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            }

            // Default Fade & Subtle Scale for High Refresh Rate displays
            final scaleAnimation = Tween<double>(
              begin: 0.96,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            ));

            return ScaleTransition(
              scale: scaleAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}
