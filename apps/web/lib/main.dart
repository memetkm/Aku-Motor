import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/logging/app_log_observer.dart';
import 'core/logging/app_logger.dart';
import 'features/motors/application/motor_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  // 1. Inisialisasi sistem logging runtime
  await AppLogger.instance.init(preferences: preferences);

  // 2. Pasang global error listener untuk menangkap unhandled Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.instance.e(
      'Framework Error: ${details.exceptionAsString()}',
      tag: 'FlutterFramework',
      stackTrace: details.stack,
    );
  };

  // 3. Pasang platform dispatcher error listener untuk asynchronous Dart exceptions
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.instance.e(
      'Uncaught Async Error: $error',
      tag: 'PlatformDispatcher',
      stackTrace: stack,
    );
    return true;
  };

  AppLogger.instance.i('Aplikasi Aku Motor berhasil dimulai.', tag: 'APP_LIFECYCLE');

  runApp(
    ProviderScope(
      observers: const [AppLogObserver()],
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const AkuMotorApp(),
    ),
  );
}
