import 'package:flutter/material.dart';

import '../domain/validation.dart';

/// Form input data profil pengguna dengan penanganan status UI & validasi input.
/// Memisahkan tanggung jawab input form dari dialog dan layar profil.
class ProfileForm extends StatelessWidget {
  const ProfileForm({
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.onSubmit,
    this.isSubmitting = false,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            key: const Key('profileNameField'),
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap',
              prefixIcon: Icon(Icons.person_outline),
            ),
            enabled: !isSubmitting,
            textInputAction: TextInputAction.next,
            scrollPadding: const EdgeInsets.only(bottom: 80),
            validator: ValidationRules.validateName,
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('profilePhoneField'),
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Nomor HP',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            enabled: !isSubmitting,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            scrollPadding: const EdgeInsets.only(bottom: 80),
            onFieldSubmitted: (_) => onSubmit(),
            validator: ValidationRules.validatePhone,
          ),
        ],
      ),
    );
  }
}
