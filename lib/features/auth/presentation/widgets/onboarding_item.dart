import 'package:flutter/material.dart';

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
    final primary = Theme.of(context).primaryColor;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Illustration (figmada katta)
        Image.asset(
          imagePath,
          width: size.width * 0.78,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 28),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.1,
            color: Color(0xFF2E2E2E),
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
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: Color(0xFF8A8A8A),
            ),
          ),
        ),
      ],
    );
  }
}
