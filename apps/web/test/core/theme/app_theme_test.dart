import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aku_motor/core/theme/app_theme.dart';

void main() {
  group('AppTheme Unit Tests', () {
    test('AppTheme.light returns valid ThemeData', () {
      final theme = AppTheme.light;
      expect(theme, isNotNull);
      expect(theme.brightness, Brightness.light);
    });

    test('AppTheme.light enables Material 3', () {
      final theme = AppTheme.light;
      expect(theme.useMaterial3, isTrue);
    });

    test('AppTheme.light has correct scaffoldBackgroundColor', () {
      final theme = AppTheme.light;
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF6F8FC));
    });

    test('AppTheme.light has custom cardTheme with white color and zero elevation', () {
      final theme = AppTheme.light;
      expect(theme.cardTheme.color, Colors.white);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.cardTheme.margin, EdgeInsets.zero);
    });

    test('AppTheme.light has floating snackBarTheme with rounded corners', () {
      final theme = AppTheme.light;
      expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
      expect(theme.snackBarTheme.shape, isA<RoundedRectangleBorder>());
    });

    test('AppTheme.light has dialogTheme with rounded corners and insetPadding', () {
      final theme = AppTheme.light;
      expect(theme.dialogTheme.shape, isA<RoundedRectangleBorder>());
      expect(
        theme.dialogTheme.insetPadding,
        const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      );
    });

    test('AppTheme.light inputDecorationTheme is filled with white background', () {
      final inputTheme = AppTheme.light.inputDecorationTheme;
      expect(inputTheme.filled, isTrue);
      expect(inputTheme.fillColor, Colors.white);
      expect(inputTheme.border, isA<OutlineInputBorder>());
    });

    test('AppTheme.dark returns valid ThemeData with dark brightness', () {
      final theme = AppTheme.dark;
      expect(theme, isNotNull);
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
    });

    test('AppTheme.dark has dark scaffold background color', () {
      final theme = AppTheme.dark;
      expect(theme.scaffoldBackgroundColor, const Color(0xFF111827));
    });

    test('AppTheme.dark cardTheme has dark surface color', () {
      final theme = AppTheme.dark;
      expect(theme.cardTheme.color, const Color(0xFF1F2937));
      expect(theme.cardTheme.elevation, 0);
    });

    test('AppTheme.dark dialogTheme has dark background color', () {
      final theme = AppTheme.dark;
      expect(theme.dialogTheme.backgroundColor, const Color(0xFF1F2937));
      expect(theme.dialogTheme.shape, isA<RoundedRectangleBorder>());
    });

    test('AppTheme.dark inputDecorationTheme has dark fill color', () {
      final inputTheme = AppTheme.dark.inputDecorationTheme;
      expect(inputTheme.filled, isTrue);
      expect(inputTheme.fillColor, const Color(0xFF1F2937));
      expect(inputTheme.border, isA<OutlineInputBorder>());
    });
  });
}
