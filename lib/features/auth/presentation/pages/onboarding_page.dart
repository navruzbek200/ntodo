import 'package:flutter/material.dart';
import '../../../../core/route/route_names.dart';
import '../widgets/onboarding_item.dart';
import '../widgets/primary_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  void _goToSignUp() {
    Navigator.pushReplacementNamed(context, RouteNames.signUp);
  }

  void _next() {
    if (_index == 0) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    } else {
      _goToSignUp();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: active ? 20 : 8,
      decoration: BoxDecoration(
        color: active
            ? Theme.of(context).primaryColor
            : const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _goToSignUp,
                  style: TextButton.styleFrom(
                    foregroundColor: primary,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Skip'),
                ),
              ),

              // Content (center)
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (v) => setState(() => _index = v),
                  children: const [
                    OnboardingItem(
                      imagePath: 'assets/images/onboarding1.png',
                      title: 'Manage your task',
                      highlight: 'Every day',
                      subtitle: 'Organize, plan, and collaborate on tasks with Ntodo.',
                    ),
                    OnboardingItem(
                      imagePath: 'assets/images/onboarding2.png',
                      title: 'Start manage your task\nwith',
                      highlight: 'Ntodo',
                      subtitle:
                      'Your busy life deserves this. you can manage checklist and your goal.',
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(_index == 0),
                  _dot(_index == 1),
                ],
              ),

              const SizedBox(height: 22),

              PrimaryButton(
                text: _index == 0 ? 'CONTINUE' : 'GET STARTED',
                onPressed: _next,
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
