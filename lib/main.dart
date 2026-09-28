import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/service_locator.dart';
import 'bloc_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bundled Poppins font is OFL-licensed; list it on the licenses page.
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Poppins'], text);
  });

  await initDI();

  runApp(
    MyBlocProvider(
      child: const MyApp(),
    ),
  );
}
