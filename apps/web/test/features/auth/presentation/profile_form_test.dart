import 'package:aku_motor/features/auth/presentation/profile_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ProfileForm merender input name dan phone serta memvalidasi', (tester) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    var submitted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileForm(
            formKey: formKey,
            nameController: nameController,
            phoneController: phoneController,
            onSubmit: () {
              submitted = true;
            },
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('profileNameField')), findsOneWidget);
    expect(find.byKey(const Key('profilePhoneField')), findsOneWidget);

    // Trigger validation on empty fields
    formKey.currentState!.validate();
    await tester.pumpAndSettle();

    expect(find.text('Nama wajib diisi'), findsOneWidget);
    expect(find.text('Nomor HP wajib diisi'), findsOneWidget);
    expect(submitted, isFalse);

    // Isi data valid
    await tester.enterText(find.byKey(const Key('profileNameField')), 'Budi Santoso');
    await tester.enterText(find.byKey(const Key('profilePhoneField')), '081234567890');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(formKey.currentState!.validate(), isTrue);
    expect(submitted, isTrue);
  });

  testWidgets('ProfileForm menonaktifkan field ketika isSubmitting bernilai true', (tester) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: 'Budi');
    final phoneController = TextEditingController(text: '081234567890');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileForm(
            formKey: formKey,
            nameController: nameController,
            phoneController: phoneController,
            isSubmitting: true,
            onSubmit: () {},
          ),
        ),
      ),
    );

    final nameField = tester.widget<TextFormField>(find.byKey(const Key('profileNameField')));
    final phoneField = tester.widget<TextFormField>(find.byKey(const Key('profilePhoneField')));

    expect(nameField.enabled, isFalse);
    expect(phoneField.enabled, isFalse);
  });
}
