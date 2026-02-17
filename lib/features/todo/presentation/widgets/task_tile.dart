import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class TaskTile extends StatelessWidget {
  final String title;
  final bool checked;
  final bool selected;
  final VoidCallback onCheck;
  final VoidCallback? onTap;
  final bool isCompletedStyle;

  const TaskTile({
    super.key,
    required this.title,
    required this.checked,
    required this.selected,
    required this.onCheck,
    this.onTap,
    this.isCompletedStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? const Color(0xFFF4F1FF) : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompletedStyle
                    ? const Color(0xFFFFF2DD)
                    : const Color(0xFFDCEBFA),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  isCompletedStyle
                      ? 'assets/icons/completed_icon.png'
                      : 'assets/icons/todo_icon.png',
                  width: 22,
                  height: 22,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isCompletedStyle
                          ? const Color(0xFFB5B5B5)
                          : const Color(0xFF2E2E2E),
                      decoration:
                      isCompletedStyle ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: Color(0xFFECECEC)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            InkWell(
              onTap: onCheck,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.buttonColor,
                    width: 1.6,
                  ),
                  color: checked ? AppColors.buttonColor : Colors.transparent,
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
