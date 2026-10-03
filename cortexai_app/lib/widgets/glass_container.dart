import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final Color? borderColor;
  final double blur;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.backgroundGradient,
    this.borderColor,
    this.blur = 16.0,
    this.borderWidth = 1.0,
    this.boxShadow,
  });

  /// Factory for futuristic glass with subtle icy-blue sheen
  factory GlassContainer.blueGlass({
    Key? key,
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    double blur = 20.0,
    double borderWidth = 1.0,
    Color? customTint,
  }) {
    return GlassContainer(
      key: key,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius ?? BorderRadius.circular(20.0),
      blur: blur,
      borderWidth: borderWidth,
      borderColor: const Color(0x38409CFF), // subtle blue-lit hairline border
      backgroundColor:
          customTint ?? const Color(0x180A2540), // subtle blue glass
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0x1F007AFF).withOpacity(0.12),
          const Color(0x0A001A33).withOpacity(0.08),
        ],
      ),
      boxShadow: const [
        BoxShadow(color: Color(0x14007AFF), blurRadius: 16, spreadRadius: 1),
      ],
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(20.0);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        border: Border.all(
          color: borderColor ?? const Color(0x1FFFFFFF),
          width: borderWidth,
        ),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundGradient == null
                  ? (backgroundColor ?? const Color(0x14FFFFFF))
                  : null,
              gradient: backgroundGradient,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
