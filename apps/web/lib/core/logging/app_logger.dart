import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'log_entry.dart';

/// Sistem logging runtime terpusat untuk aplikasi Aku Motor.
/// Membantu tracing masalah, error diagnostik, dan aktivitas aplikasi pada running mode.
class AppLogger {
  AppLogger._();

  static final AppLogger instance = AppLogger._();

  static const String _storageKey = 'aku_motor.runtime_logs.v1';
  static const int _maxInMemoryLogs = 300;

  final List<LogEntry> _logs = [];
  final ValueNotifier<List<LogEntry>> logsNotifier = ValueNotifier([]);
  SharedPreferences? _preferences;
  bool _initialized = false;

  /// Inisialisasi logger dengan SharedPreferences untuk persistensi lokal.
  Future<void> init({SharedPreferences? preferences}) async {
    if (_initialized) return;
    _preferences = preferences;
    if (_preferences != null) {
      _loadSavedLogs();
    }
    _initialized = true;
    i('Logging system diinisialisasi.', tag: 'SYSTEM');
  }

  /// Mengambil daftar riwayat entri log saat ini (read-only snapshot).
  List<LogEntry> get logs => List.unmodifiable(_logs);

  void _loadSavedLogs() {
    try {
      final raw = _preferences?.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final loaded = decoded
              .map((e) => LogEntry.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
          _logs.addAll(loaded);
          logsNotifier.value = List.unmodifiable(_logs);
        }
      }
    } catch (e) {
      developer.log('Gagal memuat log lokal: $e', name: 'AppLogger');
    }
  }

  Future<void> _persistLogs() async {
    final prefs = _preferences;
    if (prefs == null) return;
    try {
      // Simpan maksimal 150 entri terbaru ke persistent storage
      final toSave = _logs.length > 150 ? _logs.sublist(_logs.length - 150) : _logs;
      final encoded = jsonEncode(toSave.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {
      // Abaikan kegagalan I/O pada persistensi log agar tidak mengganggu alur utama
    }
  }

  void log({
    required LogLevel level,
    required String message,
    String tag = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
    );

    _logs.add(entry);
    if (_logs.length > _maxInMemoryLogs) {
      _logs.removeAt(0);
    }

    // Trigger update untuk UI pemantau log
    logsNotifier.value = List.unmodifiable(_logs);

    // Kirim ke developer console / adb logcat
    developer.log(
      message,
      name: tag,
      level: _levelToInt(level),
      error: error,
      stackTrace: stackTrace,
    );

    if (kDebugMode) {
      debugPrint('[${level.label}] [$tag] $message');
      if (error != null) debugPrint('  Error: $error');
    }

    _persistLogs();
  }

  void d(String message, {String tag = 'DEBUG'}) {
    log(level: LogLevel.debug, message: message, tag: tag);
  }

  void i(String message, {String tag = 'INFO'}) {
    log(level: LogLevel.info, message: message, tag: tag);
  }

  void w(
    String message, {
    String tag = 'WARNING',
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      level: LogLevel.warning,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void e(
    String message, {
    String tag = 'ERROR',
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      level: LogLevel.error,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Menghapus seluruh riwayat log.
  Future<void> clear() async {
    _logs.clear();
    logsNotifier.value = const [];
    await _preferences?.remove(_storageKey);
    i('Seluruh riwayat log dibersihkan.', tag: 'SYSTEM');
  }

  /// Ekspor seluruh log dalam bentuk teks berformat rapi.
  String exportLogsAsText() {
    final buffer = StringBuffer();
    buffer.writeln('=== AKU MOTOR SYSTEM DIAGNOSTIC LOG ===');
    buffer.writeln('Waktu Ekspor: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total Baris Log: ${_logs.length}');
    buffer.writeln('----------------------------------------');
    for (final entry in _logs) {
      buffer.writeln(entry.toFormattedString());
    }
    buffer.writeln('========================================');
    return buffer.toString();
  }

  static int _levelToInt(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}
