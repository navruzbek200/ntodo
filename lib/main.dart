import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/service_locator.dart';
import 'bloc_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDI();

  runApp(
    MyBlocProvider(
      child: const MyApp(),
    ),
  );
}