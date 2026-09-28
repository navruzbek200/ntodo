import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class OnboardingItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String highlight;
  final String subtitle;

  const OnboardingItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.highlight,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final t = context.tokens;
    final primary = t.checkOn;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Illustration (figmada katta)
        // The illustrations have dark details; a soft light disc keeps them
        // readable on the dark theme.
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.isDark ? const Color(0xE6F3F0FA) : Colors.transparent,
          ),
          child: Image.asset(
            imagePath,
            width: size.width * (context.isDark ? 0.62 : 0.78),
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 28),

        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: t.ink,
          ),
        ),
        const SizedBox(height: 6),

        Text(
          highlight,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.1,
            color: primary,
          ),
        ),

        const SizedBox(height: 14),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: t.muted,
            ),
          ),
        ),
      ],
    );
  }
}
