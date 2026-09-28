import 'package:flutter/material.dart';
import 'core/route/app_navigator.dart';
import 'core/route/route_generator.dart';
import 'core/route/route_names.dart';
import 'core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: RouteNames.splash,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
