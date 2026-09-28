import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'glass.dart';

enum TourGesture { tap, swipeLeft, longPress }

class TourStep {
  final String id;
  final GlobalKey target;
  final IconData icon;
  final String title;
  final String body;
  final TourGesture? gesture;

  /// The user has to perform the action on the highlighted widget; the page
  /// calls [TourController.next] when it happens. No "Next" button.
  final bool interactive;
  final double radius;
  final EdgeInsets inflate;

  const TourStep({
    required this.id,
    required this.target,
    required this.icon,
    required this.title,
    required this.body,
    this.gesture,
    this.interactive = false,
    this.radius = 20,
    this.inflate = const EdgeInsets.all(8),
  });
}

/// Drives a [SpotlightTour]. The owning page decides when interactive steps
/// are done (e.g. "task created") and calls [next].
class TourController extends ChangeNotifier {
  List<TourStep> _steps = const [];
  int? _index;
  bool _suspended = false;

  /// Called once when the tour ends, finished or skipped.
  VoidCallback? onFinish;

  bool get active => _index != null;
  bool get suspended => _suspended;
  int get index => _index ?? 0;
  int get length => _steps.length;
  TourStep? get current => _index == null ? null : _steps[_index!];
  bool isAt(String id) => current?.id == id;

  void start(List<TourStep> steps) {
    if (steps.isEmpty) return;
    _steps = steps;
    _index = 0;
    _suspended = false;
    notifyListeners();
  }

  void next() {
    if (_index == null) return;
    if (_index! + 1 >= _steps.length) return finish();
    _index = _index! + 1;
    _suspended = false;
    notifyListeners();
  }

  /// Hide the spotlight while the user is busy (e.g. in a bottom sheet).
  void suspend([bool value = true]) {
    if (_suspended == value) return;
    _suspended = value;
    notifyListeners();
  }

  void finish() {
    if (_index == null) return;
    _index = null;
    _suspended = false;
    notifyListeners();
    onFinish?.call();
  }
}

/// Puts a spotlight layer above [child]. Only the highlighted area receives
/// touches, so users can try each action for real; the rest is dimmed.
///
/// Lives inside the page (not the root Overlay) so sheets and dialogs the
/// user opens from the spotlight appear above it.
class SpotlightTour extends StatelessWidget {
  final TourController controller;
  final Widget child;

  const SpotlightTour({super.key, required this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          // Sits outside the Scaffold, so it needs its own Material for
          // text styles and ink effects.
          child: Material(
            type: MaterialType.transparency,
            child: ListenableBuilder(
              listenable: controller,
              builder: (_, _) => controller.active
                  ? _TourLayer(controller: controller)
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}

class _TourLayer extends StatefulWidget {
  final TourController controller;
  const _TourLayer({required this.controller});

  @override
  State<_TourLayer> createState() => _TourLayerState();
}

class _TourLayerState extends State<_TourLayer> with TickerProviderStateMixin {
  late final _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
  late final _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat();
  late final _gesture = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat();
  late final _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  /// Rect currently drawn; eases toward the target every frame so the
  /// spotlight glides between steps and follows moving widgets.
  Rect? _shown;
  int _lastIndex = -1;

  TourController get _c => widget.controller;

  @override
  void dispose() {
    _fade.dispose();
    _pulse.dispose();
    _gesture.dispose();
    _shake.dispose();
    super.dispose();
  }

  Rect? _targetRect(TourStep step) {
    final target = step.target.currentContext?.findRenderObject();
    final layer = context.findRenderObject();
    if (target is! RenderBox || !target.attached || !target.hasSize) return null;
    if (layer is! RenderBox || !layer.hasSize) return null;
    final topLeft = layer.globalToLocal(target.localToGlobal(Offset.zero));
    final r = topLeft & target.size;
    return Rect.fromLTRB(
      r.left - step.inflate.left,
      r.top - step.inflate.top,
      r.right + step.inflate.right,
      r.bottom + step.inflate.bottom,
    );
  }

  bool? _fadeTarget;

  /// Starts the fade after the frame – animations can't be kicked off
  /// while this builder is running.
  void _syncFade(bool show) {
    if (_fadeTarget == show) return;
    _fadeTarget = show;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      show ? _fade.forward() : _fade.reverse();
    });
  }

  Future<void> _close() async {
    await _fade.reverse();
    _c.finish();
  }

  void _onDimTap(TourStep step) {
    if (step.interactive) {
      // Nudge: the user has to do the highlighted action.
      HapticFeedback.mediumImpact();
      _shake.forward(from: 0);
    } else if (_c.index == _c.length - 1) {
      _close();
    } else {
      HapticFeedback.selectionClick();
      _c.next();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulse, _shake, _fade]),
      builder: (context, _) {
        final step = _c.current;
        if (step == null) return const SizedBox.shrink();

        if (_c.index != _lastIndex) {
          _lastIndex = _c.index;
          HapticFeedback.selectionClick();
        }

        final target = _targetRect(step);
        final show = target != null && !_c.suspended;
        _syncFade(show);
        if (target != null) {
          _shown = _shown == null ? target : Rect.lerp(_shown, target, 0.2);
        }
        final hole = _shown;
        if (hole == null) return const SizedBox.shrink();

        final size = MediaQuery.sizeOf(context);
        final below = hole.center.dy < size.height * 0.55;
        final shakeDx = math.sin(_shake.value * math.pi * 6) * 10 * (1 - _shake.value);

        return IgnorePointer(
          ignoring: !show,
          child: Opacity(
            opacity: _fade.value,
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _SpotlightPainter(hole: hole, radius: step.radius, pulse: _pulse.value),
                    ),
                  ),
                ),
                // Touch blockers around the hole – the hole itself stays
                // open so the real widget underneath can be used.
                ..._blockers(hole, size, () => _onDimTap(step)),
                if (step.gesture != null)
                  _GestureHint(rect: hole, gesture: step.gesture!, animation: _gesture),
                Positioned(
                  left: 20,
                  right: 20,
                  top: below ? hole.bottom + 18 : null,
                  bottom: below ? null : size.height - hole.top + 18,
                  child: Transform.translate(
                    offset: Offset(shakeDx, 0),
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
                        key: ValueKey(step.id),
                        step: step,
                        index: _c.index,
                        count: _c.length,
                        onNext: () => _onDimTap(step),
                        onSkip: _close,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _blockers(Rect hole, Size size, VoidCallback onTap) {
    Widget block(Rect r) => Positioned.fromRect(
          rect: r,
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap),
        );
    final top = math.max(0.0, hole.top);
    final bottom = math.min(size.height, hole.bottom);
    return [
      block(Rect.fromLTRB(0, 0, size.width, top)),
      block(Rect.fromLTRB(0, bottom, size.width, size.height)),
      block(Rect.fromLTRB(0, top, math.max(0, hole.left), bottom)),
      block(Rect.fromLTRB(math.min(size.width, hole.right), top, size.width, bottom)),
    ];
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
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
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
              if (step.interactive)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFB547),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'Your turn 👆',
                    style: TextStyle(color: AppPalette.accent, fontWeight: FontWeight.w600),
                  ),
                )
              else
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
