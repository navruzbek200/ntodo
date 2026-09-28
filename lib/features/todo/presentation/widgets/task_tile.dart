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

  const TaskTile({
    super.key,
    required this.title,
    required this.checked,
    required this.selecting,
    required this.selected,
    required this.onCheck,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF1EDFF) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? AppPalette.brand : Colors.transparent,
          width: 1.6,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x0F2C1D5E), blurRadius: 16, offset: Offset(0, 6)),
        ],
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
                  checked: selecting ? selected : checked,
                  isSelection: selecting,
                  onTap: selecting ? onTap : onCheck,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                      color: checked ? AppPalette.muted : AppPalette.ink,
                      decoration: checked ? TextDecoration.lineThrough : null,
                      decorationColor: AppPalette.muted,
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

  const _Check({required this.checked, required this.isSelection, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked ? AppPalette.brand : Colors.transparent,
                border: Border.all(
                  color: checked ? AppPalette.brand : const Color(0xFFC9BFE6),
                  width: 2,
                ),
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
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
