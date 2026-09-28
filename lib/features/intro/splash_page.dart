import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../core/route/route_names.dart';
import '../../features/auth/data/datasource/local/auth_local_remote_datasource.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(milliseconds: 1600));

    final auth = sl<AuthLocalRemoteDatasource>();
    final logged = auth.isLoggedIn();

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      logged ? RouteNames.home : RouteNames.onboarding,
      arguments: logged ? auth.getUsername() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: context.tokens.headerGradient),
          alignment: Alignment.center,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutBack,
            builder: (context, v, child) => Opacity(
              opacity: v.clamp(0, 1),
              child: Transform.scale(scale: 0.7 + 0.3 * v, child: child),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'app-logo',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: const [
                        BoxShadow(color: Color(0x66000000), blurRadius: 40, offset: Offset(0, 16)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.asset('assets/images/app_logo.png', width: 120, height: 120),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Ntodo',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Plan your day. Get things done.',
                  style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
