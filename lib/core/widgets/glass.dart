import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Frosted-glass panel. Blur is costly, so use it for a few large surfaces
/// (header card, sheets, tour card) – not for every list item.
class Glass extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final double blur;

  const Glass({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding,
    this.color,
    this.borderColor,
    this.blur = 18,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? t.glass,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor ?? t.glassBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Soft, slowly drifting colour orbs behind the content – gives the glass
/// surfaces something to blur and makes both themes feel less flat.
class AuroraBackground extends StatefulWidget {
  final Widget child;
  const AuroraBackground({super.key, required this.child});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 14))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ColoredBox(
      color: t.background,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, _) {
                  final v = Curves.easeInOut.transform(_ctrl.value);
                  return Stack(
                    children: [
                      _orb(t.orbA, 340, Alignment(-1.2 + v * 0.5, -0.2 + v * 0.3)),
                      _orb(t.orbB, 280, Alignment(1.3 - v * 0.4, 0.5 - v * 0.4)),
                      _orb(t.orbA, 220, Alignment(0.6 - v * 0.3, 1.2)),
                    ],
                  );
                },
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }

  Widget _orb(Color color, double size, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
