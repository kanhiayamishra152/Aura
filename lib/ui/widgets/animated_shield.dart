import 'package:flutter/material.dart';

class AnimatedShield extends StatefulWidget {
  final bool isActive;
  final double size;

  const AnimatedShield({
    Key? key,
    required this.isActive,
    this.size = 120.0,
  }) : super(key: key);

  @override
  State<AnimatedShield> createState() => _AnimatedShieldState();
}

class _AnimatedShieldState extends State<AnimatedShield> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: false);
    }
  }

  @override
  void didUpdateWidget(AnimatedShield oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: false);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children:[
          if (widget.isActive)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00FF00),
                      ),
                    ),
                  ),
                );
              },
            ),
          Icon(
            widget.isActive ? Icons.security : Icons.security_outlined,
            size: widget.size * 0.5,
            color: widget.isActive ? const Color(0xFF00FF00) : Colors.grey,
          ),
        ],
      ),
    );
  }
}
