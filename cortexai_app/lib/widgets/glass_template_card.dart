import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GlassCardTheme {
  final Color primary;
  final Color secondary;
  final String tier;
  final IconData icon;

  const GlassCardTheme({
    required this.primary,
    required this.secondary,
    required this.tier,
    required this.icon,
  });

  static GlassCardTheme forTemplate(Template tpl, int index) {
    switch (tpl.id) {
      case 'tpl-weather':
        return const GlassCardTheme(
          primary: Color(0xFF2979FF),
          secondary: Color(0xFF1565C0),
          tier: 'Standard',
          icon: Icons.cloud_rounded,
        );
      case 'tpl-score':
        return const GlassCardTheme(
          primary: Color(0xFFE58A38),
          secondary: Color(0xFFB45309),
          tier: 'Premium',
          icon: Icons.sports_score_rounded,
        );
      case 'tpl-temp-hum':
        return const GlassCardTheme(
          primary: Color(0xFF9333EA),
          secondary: Color(0xFF6B21A8),
          tier: 'Ultimate',
          icon: Icons.thermostat_rounded,
        );
      case 'tpl-on-led':
        return const GlassCardTheme(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF047857),
          tier: 'Active',
          icon: Icons.lightbulb_rounded,
        );
      case 'tpl-off-led':
        return const GlassCardTheme(
          primary: Color(0xFF64748B),
          secondary: Color(0xFF334155),
          tier: 'Standby',
          icon: Icons.lightbulb_outline_rounded,
        );
      case 'tpl-notification':
        return const GlassCardTheme(
          primary: Color(0xFFF43F5E),
          secondary: Color(0xFF9F1239),
          tier: 'Push',
          icon: Icons.notifications_active_rounded,
        );
      case 'tpl-read-sensor':
        return const GlassCardTheme(
          primary: Color(0xFF06B6D4),
          secondary: Color(0xFF0891B2),
          tier: 'Sensor',
          icon: Icons.sensors_rounded,
        );
      case 'tpl-trigger-alert':
        return const GlassCardTheme(
          primary: Color(0xFFEF4444),
          secondary: Color(0xFF991B1B),
          tier: 'Alert',
          icon: Icons.warning_rounded,
        );
      default:
        final cycle = index % 3;
        if (cycle == 0) {
          return const GlassCardTheme(
            primary: Color(0xFF2979FF),
            secondary: Color(0xFF1565C0),
            tier: 'Standard',
            icon: Icons.widgets_rounded,
          );
        } else if (cycle == 1) {
          return const GlassCardTheme(
            primary: Color(0xFFE58A38),
            secondary: Color(0xFFB45309),
            tier: 'Premium',
            icon: Icons.bolt_rounded,
          );
        } else {
          return const GlassCardTheme(
            primary: Color(0xFF9333EA),
            secondary: Color(0xFF6B21A8),
            tier: 'Ultimate',
            icon: Icons.memory_rounded,
          );
        }
    }
  }
}

/// Target Crosshair icon matching the reference card design
class TargetCrosshairIcon extends StatelessWidget {
  final double size;
  final Color color;

  const TargetCrosshairIcon({
    super.key,
    this.size = 22,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TargetCrosshairPainter(color: color),
    );
  }
}

class _TargetCrosshairPainter extends CustomPainter {
  final Color color;

  _TargetCrosshairPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    // Outer circle
    canvas.drawCircle(center, radius, strokePaint);

    // Inner circle
    canvas.drawCircle(center, radius * 0.32, strokePaint);

    // 4 Crosshair ticks extending through perimeter
    final tickOverlap = size.width * 0.14;
    // Top tick
    canvas.drawLine(
      Offset(center.dx, center.dy - radius - tickOverlap),
      Offset(center.dx, center.dy - radius + tickOverlap),
      strokePaint,
    );
    // Bottom tick
    canvas.drawLine(
      Offset(center.dx, center.dy + radius - tickOverlap),
      Offset(center.dx, center.dy + radius + tickOverlap),
      strokePaint,
    );
    // Left tick
    canvas.drawLine(
      Offset(center.dx - radius - tickOverlap, center.dy),
      Offset(center.dx - radius + tickOverlap, center.dy),
      strokePaint,
    );
    // Right tick
    canvas.drawLine(
      Offset(center.dx + radius - tickOverlap, center.dy),
      Offset(center.dx + radius + tickOverlap, center.dy),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Glass Template Card faithfully replicating the reference design:
/// - 3D offset colored backing slab on the right
/// - Front frosted glass panel with blur and specular hairline border
/// - Internal vertical diffused frosted glow matching the accent color
/// - Clean non-AI typography: 'Card' at top-left, Target at top-right,
///   Template title at bottom-left, Tier at bottom-right
class GlassTemplateCard extends StatefulWidget {
  final Template template;
  final int index;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  const GlassTemplateCard({
    super.key,
    required this.template,
    required this.index,
    required this.onTap,
    this.width,
    this.height,
  });

  @override
  State<GlassTemplateCard> createState() => _GlassTemplateCardState();
}

class _GlassTemplateCardState extends State<GlassTemplateCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = GlassCardTheme.forTemplate(widget.template, widget.index);

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ==========================================
              // LAYER 1: 3D Offset Colored Backing Slab
              // Visible as an edge extending to the right
              // ==========================================
              Positioned(
                top: 0,
                bottom: 0,
                left: 14,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [theme.primary, theme.secondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(3, 6),
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================
              // LAYER 2: Front Frosted Glass Panel
              // Positioned with right margin to expose the back slab
              // ==========================================
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 12, // Exposes the right curve of the colored slab
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x8C000000),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          // Dark translucent glass tint
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0x73222834), // Lighter translucent tint
                              Color(0x8A11141A),
                            ],
                          ),
                          // Subtle specular glass hairline border
                          border: Border.all(
                            color: const Color(0x33FFFFFF),
                            width: 1.1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // ==========================================
                            // Internal Diffused Vertical Frosted Glow
                            // Replicates optical refraction from back slab
                            // ==========================================
                            Positioned(
                              top: 0,
                              bottom: 0,
                              right: 0,
                              width: 82,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(24),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      theme.primary.withValues(alpha: 0.0),
                                      theme.primary.withValues(alpha: 0.24),
                                      theme.primary.withValues(alpha: 0.58),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Soft radial glow plume near top-right crosshair
                            Positioned(
                              top: -10,
                              right: -10,
                              width: 110,
                              height: 110,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      theme.primary.withValues(alpha: 0.38),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // ==========================================
                            // Content: Clean non-AI layout
                            // ==========================================
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 16.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Row: Icon + Category
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        theme.icon,
                                        color: theme.primary,
                                        size: 24,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: const Color(0x33FFFFFF),
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Text(
                                          theme.tier.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  // Title
                                  Text(
                                    widget.template.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Description
                                  Text(
                                    widget.template.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0x99FFFFFF),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
