import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass.dart';

enum HeaderMenu { tips, privacy, deleteAccount, logout }

/// Gradient header: greeting + date + today's progress.
/// Switches to a selection toolbar while tasks are being selected.
class HomeHeader extends StatelessWidget {
  final String username;
  final int total;
  final int done;
  final bool selecting;
  final int selectedCount;
  final bool loggingOut;
  final VoidCallback onToggleTheme;
  final ValueChanged<HeaderMenu> onMenu;
  final VoidCallback onCloseSelect;
  final VoidCallback onDeleteSelected;

  /// Targets for the onboarding tour.
  final Key? themeKey;
  final Key? progressKey;

  const HomeHeader({
    super.key,
    required this.username,
    required this.total,
    required this.done,
    required this.selecting,
    required this.selectedCount,
    required this.loggingOut,
    required this.onToggleTheme,
    required this.onMenu,
    required this.onCloseSelect,
    required this.onDeleteSelected,
    this.themeKey,
    this.progressKey,
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
      decoration: BoxDecoration(
        gradient: context.tokens.headerGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: const [
          BoxShadow(color: Color(0x332C1D5E), blurRadius: 30, offset: Offset(0, 12)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 8, 24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: selecting ? _selectionBar() : _greeting(context, name),
          ),
        ),
      ),
    );
  }

  Widget _greeting(BuildContext context, String name) {
    final progress = total == 0 ? 0.0 : done / total;
    final allDone = total > 0 && done == total;

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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_today, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 13)),
                  Text(
                    'Hi, $name 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            IconButton(
              key: themeKey,
              tooltip: context.isDark ? 'Light mode' : 'Dark mode',
              onPressed: onToggleTheme,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, a) => RotationTransition(
                  turns: Tween(begin: 0.6, end: 1.0).animate(a),
                  child: FadeTransition(opacity: a, child: child),
                ),
                child: Icon(
                  context.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey(context.isDark),
                  color: Colors.white,
                ),
              ),
            ),
            loggingOut
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  )
                : PopupMenuButton<HeaderMenu>(
                    tooltip: 'More',
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                    position: PopupMenuPosition.under,
                    onSelected: onMenu,
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: HeaderMenu.tips,
                        child: _MenuRow(Icons.lightbulb_outline_rounded, 'Show tips'),
                      ),
                      PopupMenuItem(
                        value: HeaderMenu.privacy,
                        child: _MenuRow(Icons.privacy_tip_outlined, 'Privacy policy'),
                      ),
                      PopupMenuItem(
                        value: HeaderMenu.deleteAccount,
                        child: _MenuRow(Icons.person_remove_outlined, 'Delete account'),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: HeaderMenu.logout,
                        child: _MenuRow(Icons.logout_rounded, 'Log out'),
                      ),
                    ],
                  ),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Glass(
            key: progressKey,
            color: const Color(0x24FFFFFF),
            borderColor: const Color(0x33FFFFFF),
            borderRadius: BorderRadius.circular(22),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Today's progress",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, a) => ScaleTransition(
                    scale: Tween(begin: 0.85, end: 1.0).animate(
                      CurvedAnimation(parent: a, curve: Curves.easeOutBack),
                    ),
                    child: FadeTransition(opacity: a, child: child),
                  ),
                  child: Text(
                    allDone
                        ? 'All done – great job! 🎉'
                        : total == 0
                            ? 'No tasks yet – add your first one'
                            : '$done of $total tasks done',
                    key: ValueKey(allDone ? 'all' : '$done/$total'),
                    style: TextStyle(
                      color: allDone ? Colors.white : const Color(0xCCFFFFFF),
                      fontSize: 13,
                      fontWeight: allDone ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: progress),
                    duration: const Duration(milliseconds: 600),
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
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
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

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuRow(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.tokens.muted),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}
