import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../core/utils/asset_utils.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;
  final bool showParticles;
  final String? brandLightAsset;
  final String? brandDarkAsset;
  final double brandOverlayOpacity;

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
    this.brandLightAsset,
    this.brandDarkAsset,
    this.brandOverlayOpacity = 0.15,
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
  bool _hasLightBg = false;
  bool _hasDarkBg = false;

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

    _checkBrandAssets();
  }

  Future<void> _checkBrandAssets() async {
    bool light = false;
    bool dark = false;
    if (widget.brandLightAsset != null) {
      light = await AssetUtils.exists(widget.brandLightAsset!);
    }
    if (widget.brandDarkAsset != null) {
      dark = await AssetUtils.exists(widget.brandDarkAsset!);
    }
    if (mounted) {
      setState(() {
        _hasLightBg = light;
        _hasDarkBg = dark;
      });
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    String? brandAsset;
    if (brightness == Brightness.dark) {
      brandAsset = _hasDarkBg
          ? widget.brandDarkAsset
          : (_hasLightBg ? widget.brandLightAsset : null);
    } else {
      brandAsset = _hasLightBg
          ? widget.brandLightAsset
          : (_hasDarkBg ? widget.brandDarkAsset : null);
    }

    return Stack(
      children: [
        if (brandAsset != null)
          Positioned.fill(
            child: Image.asset(
              brandAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return AnimatedBuilder(
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
                                0.3 *
                                    math.sin(
                                        _gradientAnimation.value * 2 * math.pi),
                            1.0,
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        else
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
                          0.3 *
                              math.sin(_gradientAnimation.value * 2 * math.pi),
                      1.0,
                    ],
                  ),
                ),
              );
            },
          ),

        if (brandAsset != null)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                // Use subtler overlay in light mode to avoid washing out image
                color: (brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white)
                    .withValues(
                        alpha: brightness == Brightness.dark
                            ? widget.brandOverlayOpacity
                            : (widget.brandOverlayOpacity * 0.5)),
              ),
            ),
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
      ..color = Colors.white.withValues(alpha: 0.1);

    for (final particle in particles) {
      final x = (particle.x + animationValue * particle.speed) % 1.0;
      final y = (particle.y + animationValue * particle.speed * 0.5) % 1.0;

      final center = Offset(x * size.width, y * size.height);

      paint.color = Colors.white.withValues(alpha: particle.opacity);
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

      paint.color = color.withValues(alpha: 0.3 - (i * 0.1));

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
