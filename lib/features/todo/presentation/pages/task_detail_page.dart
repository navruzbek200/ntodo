import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  final String title;
  final bool checked;
  final VoidCallback onTap;
  final VoidCallback onCheck;
  final Color iconBg;
  final bool strikeThrough;

  const TaskTile({
    super.key,
    required this.title,
    required this.checked,
    required this.onTap,
    required this.onCheck,
    required this.iconBg,
    this.strikeThrough = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEDEDED))),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.notes_rounded, size: 20, color: Color(0xFF3F4B5A)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: strikeThrough ? const Color(0xFFB5B5B5) : const Color(0xFF2E2E2E),
                  decoration: strikeThrough ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            InkWell(
              onTap: onCheck,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: primary, width: 1.6),
                  color: checked ? primary : Colors.transparent,
                ),
                child: checked
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
