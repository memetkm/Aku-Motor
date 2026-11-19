import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_logger.dart';

/// Riverpod ProviderObserver untuk mencatat perubahan state dan error provider secara otomatis.
class AppLogObserver extends ProviderObserver {
  const AppLogObserver();

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    final name = provider.name ?? provider.runtimeType.toString();
    AppLogger.instance.d(
      'Provider "$name" updated: $newValue',
      tag: 'STATE',
    );
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    final name = provider.name ?? provider.runtimeType.toString();
    AppLogger.instance.e(
      'Provider "$name" mengalami kegagalan: $error',
      tag: 'PROVIDER_ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
