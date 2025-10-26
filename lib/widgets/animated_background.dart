import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;
  final bool showParticles;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.colors = const [
      Color(0xFF1a56db),
      Color(0xFF60a5fa),
      Color(0xFF8b5cf6),
    ],
    this.duration = const Duration(seconds: 10),
    this.showParticles = true,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particleController;
  late Animation<double> _gradientAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated Gradient Background
        AnimatedBuilder(
          animation: _gradientAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.colors,
                  stops: [
                    0.0,
                    0.5 +
                        0.3 * math.sin(_gradientAnimation.value * 2 * math.pi),
                    1.0,
                  ],
                ),
              ),
            );
          },
        ),

        // Floating Particles
        if (widget.showParticles)
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particleAnimation.value),
                size: Size.infinite,
              );
            },
          ),

        // Content
        widget.child,
      ],
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;
  final List<Particle> particles;

  ParticlePainter(this.animationValue) : particles = _generateParticles();

  static List<Particle> _generateParticles() {
    final random = math.Random();
    return List.generate(50, (index) {
      return Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1,
        speed: random.nextDouble() * 0.5 + 0.1,
        opacity: random.nextDouble() * 0.5 + 0.1,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.1);

    for (final particle in particles) {
      final x = (particle.x + animationValue * particle.speed) % 1.0;
      final y = (particle.y + animationValue * particle.speed * 0.5) % 1.0;

      final center = Offset(x * size.width, y * size.height);

      paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(center, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class WaveBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;

  const WaveBackground({
    super.key,
    required this.child,
    this.colors = const [Color(0xFF1a56db), Color(0xFF60a5fa)],
    this.duration = const Duration(seconds: 8),
  });

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Wave Background
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: WavePainter(
                animationValue: _animation.value,
                colors: widget.colors,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Content
        widget.child,
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;

  WavePainter({required this.animationValue, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create multiple wave layers
    for (int i = 0; i < colors.length; i++) {
      final color = colors[i];
      final waveHeight = 50.0 + (i * 20.0);
      final frequency = 0.02 + (i * 0.01);
      final phase = animationValue * 2 * math.pi + (i * math.pi / 2);

      paint.color = color.withOpacity(0.3 - (i * 0.1));

      final path = Path();
      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 1) {
        final y = size.height - waveHeight * math.sin(x * frequency + phase);
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
