import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// One task as a rounded card with an animated round checkbox.
/// In selection mode the checkbox turns into a selection marker.
class TaskTile extends StatelessWidget {
  final String title;
  final bool checked;
  final bool selecting;
  final bool selected;
  final VoidCallback onCheck;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  /// Lets the onboarding tour point at the checkbox.
  final Key? checkKey;

  const TaskTile({
    super.key,
    required this.title,
    required this.checked,
    required this.selecting,
    required this.selected,
    required this.onCheck,
    required this.onTap,
    required this.onLongPress,
    this.checkKey,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: selected ? t.selectedFill : t.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? t.checkOn : t.cardBorder,
          width: selected ? 1.6 : 1,
        ),
        boxShadow: [BoxShadow(color: t.shadow, blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Row(
              children: [
                _Check(
                  key: checkKey,
                  checked: selecting ? selected : checked,
                  isSelection: selecting,
                  onTap: selecting ? onTap : onCheck,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                      color: checked ? t.muted : t.ink,
                      decoration: checked ? TextDecoration.lineThrough : null,
                      decorationColor: t.muted,
                    ),
                    child: Text(title, maxLines: 3, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  final bool checked;
  final bool isSelection;
  final VoidCallback onTap;

  const _Check({super.key, required this.checked, required this.isSelection, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Semantics(
      checked: checked,
      button: true,
      label: isSelection ? 'Select task' : 'Mark task as done',
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked ? t.checkOn : Colors.transparent,
                border: Border.all(color: checked ? t.checkOn : t.checkIdle, width: 2),
                boxShadow: checked
                    ? [BoxShadow(color: t.checkOn.withValues(alpha: 0.45), blurRadius: 10)]
                    : null,
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                scale: checked ? 1 : 0,
                child: const Icon(Icons.check_rounded, size: 17, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fades/slides a list item in once, staggered by [index].
class Entrance extends StatefulWidget {
  final int index;
  final Widget child;
  const Entrance({super.key, required this.index, required this.child});

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final _curve = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 40 * widget.index.clamp(0, 10)), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(_curve),
        child: widget.child,
      ),
    );
  }
}
