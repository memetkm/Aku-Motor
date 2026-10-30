import 'package:aku_motor/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LoginScreen menampilkan form login dan validasi', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Masuk Akun'), findsOneWidget);
    expect(find.byKey(const Key('loginEmailField')), findsOneWidget);
    expect(find.byKey(const Key('loginPasswordField')), findsOneWidget);
    expect(find.byKey(const Key('loginSubmitButton')), findsOneWidget);

    // Coba tekan masuk tanpa isi form (harus memvalidasi)
    await tester.tap(find.byKey(const Key('loginSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi'), findsOneWidget);

    // Tombol demo account mengisi otomatis
    await tester.tap(find.byKey(const Key('demoAccountButton')));
    await tester.pumpAndSettle();

    expect(find.text('budi@akumotor.id'), findsOneWidget);
    expect(find.text('password123'), findsOneWidget);
  });
}
