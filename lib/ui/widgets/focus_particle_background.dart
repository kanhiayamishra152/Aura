import 'dart:math';
import 'package:flutter/material.dart';

class FocusParticleBackground extends StatefulWidget {
  final Widget child;
  final bool isActive;

  const FocusParticleBackground({
    Key? key,
    required this.child,
    this.isActive = true,
  }) : super(key: key);

  @override
  State<FocusParticleBackground> createState() => _FocusParticleBackgroundState();
}

class _FocusParticleBackgroundState extends State<FocusParticleBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles =[];
  final Random _random = Random();
  int _lastTime = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateParticles);

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(FocusParticleBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_particles.isEmpty) {
      final size = MediaQuery.of(context).size;
      _generateParticles(size);
    }
  }

  void _generateParticles(Size size) {
    for (int i = 0; i < 30; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height,
          speed: _random.nextDouble() * 0.5 + 0.1,
          radius: _random.nextDouble() * 2.0 + 1.0,
          opacity: _random.nextDouble() * 0.5 + 0.1,
        ),
      );
    }
  }

  void _updateParticles() {
    if (!mounted) return;
    
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (_lastTime == 0) _lastTime = currentTime;
    
    // Delta time calculation for smooth 120Hz movement
    final dt = (currentTime - _lastTime) / 16.0;
    _lastTime = currentTime;

    final size = MediaQuery.of(context).size;

    for (var particle in _particles) {
      particle.y -= particle.speed * dt;
      
      // Floating wave effect
      particle.x += sin(currentTime / 1000.0 + particle.speed) * 0.5 * dt;

      if (particle.y < -10) {
        particle.y = size.height + 10;
        particle.x = _random.nextDouble() * size.width;
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children:[
        CustomPaint(
          painter: _ParticlePainter(_particles),
          size: Size.infinite,
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  double speed;
  double radius;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Paint _paint;

  _ParticlePainter(this.particles) : _paint = Paint()..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      _paint.color = const Color(0xFF39FF14).withOpacity(particle.opacity);
      _paint.maskFilter = MaskFilter.blur(BlurStyle.normal, particle.radius * 0.5);
      canvas.drawCircle(Offset(particle.x, particle.y), particle.radius, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
