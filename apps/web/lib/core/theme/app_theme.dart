import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _seed = Color(0xFF155EEF);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _seed),
      scaffoldBackgroundColor: const Color(0xFFF6F8FC),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
      ),
    );
  }
}
