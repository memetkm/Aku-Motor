import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/auth_providers.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemoAccount() {
    setState(() {
      _emailController.text = 'budi@akumotor.id';
      _passwordController.text = 'password123';
      _errorMessage = null;
    });
  }

  Future<void> _handleLogin() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final success = await ref.read(authStateProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil masuk. Selamat datang!')),
      );
      Navigator.of(context).pop(true);
    } else {
      final state = ref.read(authStateProvider);
      setState(() {
        _errorMessage = state.hasError
            ? state.error.toString().replaceAll('FormatException: ', '')
            : 'Login gagal. Periksa kembali email dan kata sandi Anda.';
      });
    }
  }

  Future<void> _handleGuestLogin() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    await ref.read(authStateProvider.notifier).loginAsGuest();
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Masuk dalam mode Tamu')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Masuk Akun'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.two_wheeler,
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aku Motor ID',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Masuk untuk sinkronisasi data',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        key: const Key('loginEmailField'),
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'nama@domain.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email wajib diisi';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('loginPasswordField'),
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kata sandi wajib diisi';
                          }
                          if (value.trim().length < 6) {
                            return 'Kata sandi minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        key: const Key('loginSubmitButton'),
                        onPressed: _isSubmitting ? null : _handleLogin,
                        child: _isSubmitting
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Masuk'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        key: const Key('demoAccountButton'),
                        onPressed: _isSubmitting ? null : _fillDemoAccount,
                        icon: const Icon(Icons.auto_fix_high),
                        label: const Text('Isi Cepat Akun Demo (Budi)'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        key: const Key('guestLoginButton'),
                        onPressed: _isSubmitting ? null : _handleGuestLogin,
                        child: const Text('Lanjut sebagai Tamu (Tanpa Akun)'),
                      ),
                      const Divider(height: 32),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('Belum punya akun?'),
                          TextButton(
                            key: const Key('toRegisterButton'),
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.pushNamed(
                                      context,
                                      RegisterScreen.routeName,
                                    ),
                            child: const Text('Daftar di sini'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
