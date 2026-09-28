import 'package:flutter/material.dart';
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
    await Future.delayed(const Duration(seconds: 3));

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
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/splash_icon.png',
              width: 320,
              height: 241,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 14),
            Text(
              'Ntodo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}