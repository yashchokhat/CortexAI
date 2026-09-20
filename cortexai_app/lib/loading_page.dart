import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'auth_page.dart';

/// Funky Orbital Painter with dual rotating rings and orbital telemetry nodes
class FunkyOrbitalPainter extends CustomPainter {
  final double rotation;
  final double pulse;

  const FunkyOrbitalPainter({
    required this.rotation,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final innerRadius = size.width / 2 - 12;
    final outerRadius = size.width / 2 + 10;

    // 1. Subtle ambient halo behind center
    final haloPaint = Paint()
      ..color = Color.lerp(
        const Color(0x0AFFFFFF),
        const Color(0x22FFFFFF),
        pulse,
      )!
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawCircle(center, innerRadius * 0.85, haloPaint);

    // 2. Outer dotted orbit (rotates clockwise)
    final dotPaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.fill;

    const numDots = 28;
    for (int i = 0; i < numDots; i++) {
      final angle = (i * 2 * math.pi / numDots) + rotation;
      final x = center.dx + outerRadius * math.cos(angle);
      final y = center.dy + outerRadius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
    }

    // 3. Inner dashed arc (rotates counter-clockwise)
    final arcPaint = Paint()
      ..color = const Color(0x40FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    const segmentCount = 6;
    const arcLength = (2 * math.pi) / (segmentCount * 2);
    for (int i = 0; i < segmentCount; i++) {
      final startAngle = (i * 2 * math.pi / segmentCount) - rotation * 1.5;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle,
        arcLength,
        false,
        arcPaint,
      );
    }

    // 4. Funky Orbital Satellite Nodes
    final nodeAngles = [
      rotation * 2.2,
      rotation * 2.2 + math.pi * 0.75,
      rotation * 2.2 + math.pi * 1.5,
    ];

    for (int i = 0; i < nodeAngles.length; i++) {
      final angle = nodeAngles[i];
      final nodeRadius = (i % 2 == 0) ? outerRadius : innerRadius;
      final nx = center.dx + nodeRadius * math.cos(angle);
      final ny = center.dy + nodeRadius * math.sin(angle);

      // Node glow
      final nodeGlow = Paint()
        ..color = const Color(0x88FFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(nx, ny), 3.0, nodeGlow);

      // Node core
      final nodeCore = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(nx, ny), 1.8, nodeCore);
    }
  }

  @override
  bool shouldRepaint(covariant FunkyOrbitalPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.pulse != pulse;
  }
}

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with TickerProviderStateMixin {
  late AnimationController _orbitalController;
  late AnimationController _pulseController;
  int _statusIndex = 0;

  final List<String> _statusMessages = [
    'CONNECTING EDGE MESH...',
    'SYNCING TELEMETRY ENCLAVE...',
    'SYSTEM ONLINE',
  ];

  @override
  void initState() {
    super.initState();

    // Funky smooth rotation
    _orbitalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Smooth breathing pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // Step through telemetry messages
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _statusIndex = 1);
    });
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) setState(() => _statusIndex = 2);
    });

    // Smooth transition to AuthPage
    Future.delayed(const Duration(milliseconds: 2700), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (context, animation, secondaryAnimation) => const AuthPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _orbitalController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure OLED black
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Funky Animated Orbital Icon Centerpiece
              AnimatedBuilder(
                animation: Listenable.merge([_orbitalController, _pulseController]),
                builder: (context, child) {
                  final pulseVal = _pulseController.value;
                  final scaleVal = 1.0 + (pulseVal * 0.04);

                  return SizedBox(
                    width: 210,
                    height: 210,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Dynamic Orbital Radar Rings
                        Positioned.fill(
                          child: CustomPaint(
                            painter: FunkyOrbitalPainter(
                              rotation: _orbitalController.value * 2 * math.pi,
                              pulse: pulseVal,
                            ),
                          ),
                        ),

                        // Center Pulsing Logo Icon
                        Transform.scale(
                          scale: scaleVal,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF08080A),
                              border: Border.all(
                                color: const Color(0x38FFFFFF),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.06 + 0.06 * pulseVal),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Image.asset(
                                  'assets/icon/icon.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 38),

              // Title Typography with Shimmer and Entry Fade
              const Text(
                'CORTEX AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 5.5,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .shimmer(duration: 1800.ms, color: const Color(0x55FFFFFF)),

              const SizedBox(height: 8),

              const Text(
                'INTELLIGENT EDGE ORCHESTRATION',
                style: TextStyle(
                  color: Color(0x88FFFFFF),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.4,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

              const Spacer(flex: 2),

              // Minimalist Monochrome Beam Progress Indicator
              Container(
                width: 120,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1),
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Animated Dynamic Status Telemetry
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _statusMessages[_statusIndex],
                  key: ValueKey(_statusIndex),
                  style: const TextStyle(
                    color: Color(0x77FFFFFF),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
