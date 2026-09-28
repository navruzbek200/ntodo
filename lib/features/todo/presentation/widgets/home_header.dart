import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Gradient header: greeting + date + today's progress.
/// Switches to a selection toolbar while tasks are being selected.
class HomeHeader extends StatelessWidget {
  final String username;
  final int total;
  final int done;
  final bool selecting;
  final int selectedCount;
  final bool loggingOut;
  final VoidCallback onLogout;
  final VoidCallback onCloseSelect;
  final VoidCallback onDeleteSelected;

  const HomeHeader({
    super.key,
    required this.username,
    required this.total,
    required this.done,
    required this.selecting,
    required this.selectedCount,
    required this.loggingOut,
    required this.onLogout,
    required this.onCloseSelect,
    required this.onDeleteSelected,
  });

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];

  String get _today {
    final now = DateTime.now();
    return '${_weekdays[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final name = username.isEmpty ? 'there' : username;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppPalette.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: selecting ? _selectionBar() : _greeting(name),
          ),
        ),
      ),
    );
  }

  Widget _greeting(String name) {
    final progress = total == 0 ? 0.0 : done / total;

    return Column(
      key: const ValueKey('greeting'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Same frosted-white surface as the progress card; the accent
            // colour is reserved for progress so it stays the focal point.
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x26FFFFFF),
                border: Border.all(color: const Color(0x4DFFFFFF), width: 1.5),
              ),
              child: Text(
                name.characters.first.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _today,
                    style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
                  ),
                  Text(
                    'Hi, $name 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Log out',
              onPressed: loggingOut ? null : onLogout,
              icon: loggingOut
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.logout_rounded, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x26FFFFFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Today's progress",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: AppPalette.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                total == 0
                    ? 'No tasks yet – add your first one'
                    : '$done of $total tasks done',
                style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: progress),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: const Color(0x33FFFFFF),
                    color: AppPalette.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _selectionBar() {
    return Row(
      key: const ValueKey('selection'),
      children: [
        IconButton(
          tooltip: 'Cancel selection',
          onPressed: onCloseSelect,
          icon: const Icon(Icons.close_rounded, color: Colors.white),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            selectedCount == 0 ? 'Select tasks' : '$selectedCount selected',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Delete selected',
          onPressed: selectedCount == 0 ? null : onDeleteSelected,
          icon: Icon(
            Icons.delete_outline_rounded,
            color: selectedCount == 0 ? const Color(0x66FFFFFF) : Colors.white,
          ),
        ),
      ],
    );
  }
}
