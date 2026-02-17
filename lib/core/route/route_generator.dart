import 'package:flutter/material.dart';

import '../../features/intro/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/todo/domain/entities/get_entity.dart';
import '../../features/todo/presentation/pages/task_edit_page.dart';
import '../../features/todo/presentation/pages/todo_home_page.dart';

import 'route_names.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RouteNames.splash:
      return MaterialPageRoute(builder: (_) => const SplashPage());

    case RouteNames.onboarding:
      return MaterialPageRoute(builder: (_) => const OnboardingPage());

    case RouteNames.signUp:
      return MaterialPageRoute(builder: (_) => const SignUpPage());

    case RouteNames.login:
      return MaterialPageRoute(builder: (_) => const LoginPage());

    case RouteNames.home:
      final username = settings.arguments as String?;
      return MaterialPageRoute(
        builder: (_) => TodoHomePage(username: username ?? ''),
      );

    case RouteNames.taskDetail:
      final args = settings.arguments as Map<String, dynamic>;
      final task = args['task'] as GetEntity;
      return MaterialPageRoute(
        builder: (_) => TaskEditPage(task: task),
      );

    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Route not found')),
        ),
      );
  }
}