import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di/service_locator.dart';
import 'core/route/app_navigator.dart';
import 'core/route/route_generator.dart';
import 'core/route/route_names.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: sl<ThemeController>(),
      builder: (context, mode, _) => MaterialApp(
        navigatorKey: appNavigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: mode,
        initialRoute: RouteNames.splash,
        onGenerateRoute: onGenerateRoute,
        // Status bar icons follow the theme; screens with a dark header
        // (home) override this with their own AnnotatedRegion.
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: context.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          child: child!,
        ),
      ),
    );
  }
}
