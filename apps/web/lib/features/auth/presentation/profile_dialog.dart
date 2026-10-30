import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/auth_providers.dart';
import '../domain/user.dart';
import 'login_screen.dart';

class ProfileDialog extends ConsumerStatefulWidget {
  const ProfileDialog({required this.user, super.key});

  final User user;

  @override
  ConsumerState<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends ConsumerState<ProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    final success = await ref.read(authStateProvider.notifier).updateProfile(
          name: _nameController.text,
          phoneNumber: _phoneController.text,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authStateProvider.notifier).logout();
      if (!mounted) return;
      Navigator.pop(context); // close profile dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi telah diakhiri.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).valueOrNull ?? widget.user;

    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              user.isGuest ? Icons.person_outline : Icons.person,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.isGuest ? 'Mode Tamu' : 'Akun Terverifikasi',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: user.isGuest ? Colors.amber.shade900 : Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: _isEditing
              ? Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        key: const Key('profileNameField'),
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('profilePhoneField'),
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Nomor HP'),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Nomor HP wajib diisi' : null,
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(user.email),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.phone_outlined),
                      title: const Text('Nomor Telepon'),
                      subtitle: Text(
                        user.phoneNumber.isEmpty ? '-' : user.phoneNumber,
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Terdaftar Sejak'),
                      subtitle: Text(
                        user.createdAt.toIso8601String().split('T').first,
                      ),
                    ),
                    if (user.isGuest) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.amber.shade900, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Anda sedang menggunakan mode tamu. Masuk atau daftar akun untuk menyimpan data ke cloud.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
      actions: [
        if (_isEditing) ...[
          TextButton(
            onPressed: _isSubmitting ? null : () => setState(() => _isEditing = false),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const Key('saveProfileButton'),
            onPressed: _isSubmitting ? null : _handleSave,
            child: _isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Simpan'),
          ),
        ] else ...[
          if (!user.isGuest)
            TextButton.icon(
              key: const Key('editProfileButton'),
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit'),
            ),
          if (user.isGuest)
            FilledButton.tonal(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, LoginScreen.routeName);
              },
              child: const Text('Masuk / Daftar Akun'),
            ),
          OutlinedButton(
            key: const Key('logoutButton'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
            ),
            onPressed: _handleLogout,
            child: const Text('Keluar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ],
    );
  }
}

