import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'glass.dart';

enum TourGesture { tap, swipeLeft, longPress }

class TourStep {
  final GlobalKey target;
  final IconData icon;
  final String title;
  final String body;
  final TourGesture? gesture;
  final double radius;
  final EdgeInsets inflate;

  const TourStep({
    required this.target,
    required this.icon,
    required this.title,
    required this.body,
    this.gesture,
    this.radius = 20,
    this.inflate = const EdgeInsets.all(8),
  });
}

/// Dims the screen, cuts a spotlight around each step's widget and explains
/// it in a glass card. Steps whose widget isn't on screen are skipped.
Future<void> showSpotlightTour(BuildContext context, List<TourStep> steps) {
  final done = Completer<void>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _TourOverlay(
      steps: steps,
      onFinish: () {
        entry.remove();
        done.complete();
      },
    ),
  );
  Overlay.of(context, rootOverlay: true).insert(entry);
  return done.future;
}

class _TourOverlay extends StatefulWidget {
  final List<TourStep> steps;
  final VoidCallback onFinish;
  const _TourOverlay({required this.steps, required this.onFinish});

  @override
  State<_TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<_TourOverlay> with TickerProviderStateMixin {
  late final List<TourStep> _steps =
      widget.steps.where((s) => s.target.currentContext != null).toList();
  int _index = 0;

  late final _fadeIn = AnimationController(vsync: this, duration: const Duration(milliseconds: 350))
    ..forward();
  late final _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat();
  late final _gesture = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat();

  @override
  void initState() {
    super.initState();
    if (_steps.isEmpty) WidgetsBinding.instance.addPostFrameCallback((_) => widget.onFinish());
  }

  @override
  void dispose() {
    _fadeIn.dispose();
    _pulse.dispose();
    _gesture.dispose();
    super.dispose();
  }

  Rect _rectOf(TourStep step) {
    final box = step.target.currentContext!.findRenderObject() as RenderBox;
    final r = box.localToGlobal(Offset.zero) & box.size;
    return Rect.fromLTRB(
      r.left - step.inflate.left,
      r.top - step.inflate.top,
      r.right + step.inflate.right,
      r.bottom + step.inflate.bottom,
    );
  }

  Future<void> _next() async {
    HapticFeedback.selectionClick();
    if (_index < _steps.length - 1) {
      setState(() => _index++);
    } else {
      await _fadeIn.reverse();
      widget.onFinish();
    }
  }

  Future<void> _skip() async {
    await _fadeIn.reverse();
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) return const SizedBox.shrink();
    final step = _steps[_index];
    final size = MediaQuery.sizeOf(context);

    return FadeTransition(
      opacity: _fadeIn,
      child: Material(
        type: MaterialType.transparency,
        child: TweenAnimationBuilder<Rect?>(
          tween: RectTween(end: _rectOf(step)),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, hole, _) {
            final rect = hole!;
            final below = rect.center.dy < size.height * 0.55;

            return Stack(
              children: [
                // Dim layer with the spotlight hole; any tap advances.
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _next,
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, _) => CustomPaint(
                        painter: _SpotlightPainter(
                          hole: rect,
                          radius: step.radius,
                          pulse: _pulse.value,
                        ),
                      ),
                    ),
                  ),
                ),
                if (step.gesture != null)
                  _GestureHint(rect: rect, gesture: step.gesture!, animation: _gesture),
                Positioned(
                  left: 20,
                  right: 20,
                  top: below ? rect.bottom + 20 : null,
                  bottom: below ? null : size.height - rect.top + 20,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween(
                          begin: Offset(0, below ? 0.08 : -0.08),
                          end: Offset.zero,
                        ).animate(a),
                        child: child,
                      ),
                    ),
                    child: _TourCard(
                      key: ValueKey(_index),
                      step: step,
                      index: _index,
                      count: _steps.length,
                      onNext: _next,
                      onSkip: _skip,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect hole;
  final double radius;
  final double pulse;

  _SpotlightPainter({required this.hole, required this.radius, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(hole, Radius.circular(radius));
    final dim = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(rrect);
    canvas.drawPath(dim, Paint()..color = const Color(0xC7090614));

    // Soft outline + expanding pulse ring draw the eye to the target.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xCCFFFFFF),
    );
    final grow = 14 * Curves.easeOut.transform(pulse);
    canvas.drawRRect(
      rrect.inflate(grow),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = AppPalette.accent.withValues(alpha: 0.9 * (1 - pulse)),
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.hole != hole || old.pulse != pulse || old.radius != radius;
}

/// Animated finger that demonstrates the gesture on the highlighted widget.
class _GestureHint extends StatelessWidget {
  final Rect rect;
  final TourGesture gesture;
  final Animation<double> animation;

  const _GestureHint({required this.rect, required this.gesture, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) {
        final v = animation.value;
        var dx = rect.center.dx;
        var scale = 1.0;
        var opacity = 1.0;

        switch (gesture) {
          case TourGesture.tap:
            scale = 1 - 0.18 * math.sin(math.pi * (v * 2 % 1));
          case TourGesture.swipeLeft:
            final t = Curves.easeInOut.transform(math.min(v / 0.75, 1));
            dx = rect.right - 40 - t * (rect.width - 110);
            opacity = v < 0.75 ? 1 : 1 - (v - 0.75) / 0.25;
          case TourGesture.longPress:
            scale = v < 0.3 ? 1 - v : (v < 0.8 ? 0.7 : 0.7 + (v - 0.8) * 1.5);
        }

        return Positioned(
          left: dx - 12,
          top: rect.center.dy - 6,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity.clamp(0, 1),
              child: Transform.scale(
                scale: scale,
                child: const Icon(
                  Icons.touch_app_rounded,
                  size: 46,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 12, color: Color(0x99000000))],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TourCard extends StatelessWidget {
  final TourStep step;
  final int index;
  final int count;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TourCard({
    super.key,
    required this.step,
    required this.index,
    required this.count,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final last = index == count - 1;

    return Glass(
      color: const Color(0x33FFFFFF),
      borderColor: const Color(0x40FFFFFF),
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppPalette.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(step.icon, color: AppPalette.brandDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            step.body,
            style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 14.5, height: 1.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(
                count,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 5),
                  width: i == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == index ? AppPalette.accent : const Color(0x66FFFFFF),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const Spacer(),
              if (!last)
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(foregroundColor: const Color(0xCCFFFFFF)),
                  child: const Text('Skip'),
                ),
              TextButton(
                onPressed: onNext,
                style: TextButton.styleFrom(foregroundColor: AppPalette.accent),
                child: Text(last ? 'Got it!' : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
