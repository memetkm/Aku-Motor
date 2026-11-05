import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/motor_providers.dart';
import '../domain/motor.dart';

class MotorFormDialog extends ConsumerStatefulWidget {
  const MotorFormDialog({this.motor, super.key});

  final Motor? motor;

  @override
  ConsumerState<MotorFormDialog> createState() => _MotorFormDialogState();
}

class _MotorFormDialogState extends ConsumerState<MotorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _kilometerController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final motor = widget.motor;
    _brandController = TextEditingController(text: motor?.brand);
    _modelController = TextEditingController(text: motor?.model);
    _yearController = TextEditingController(text: motor?.year.toString());
    _kilometerController = TextEditingController(
      text: motor?.currentKilometer.toString(),
    );
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _kilometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.motor != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit motor' : 'Tambah motor'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: const Key('brandField'),
                    controller: _brandController,
                    scrollPadding: const EdgeInsets.only(bottom: 80),
                    decoration: const InputDecoration(
                      labelText: 'Merek',
                      hintText: 'Contoh: Honda, Yamaha, Suzuki',
                      prefixIcon: Icon(Icons.two_wheeler_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('modelField'),
                    controller: _modelController,
                    scrollPadding: const EdgeInsets.only(bottom: 80),
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      hintText: 'Contoh: Vario 160, NMAX 155',
                      prefixIcon: Icon(Icons.motorcycle_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('yearField'),
                    controller: _yearController,
                    scrollPadding: const EdgeInsets.only(bottom: 80),
                    decoration: const InputDecoration(
                      labelText: 'Tahun',
                      hintText: 'Contoh: 2024',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final year = int.tryParse(value ?? '');
                      final maximum = DateTime.now().year + 1;
                      if (year == null || year < 1950 || year > maximum) {
                        return 'Masukkan tahun 1950–$maximum';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('kilometerField'),
                    controller: _kilometerController,
                    scrollPadding: const EdgeInsets.only(bottom: 80),
                    decoration: const InputDecoration(
                      labelText: 'Kilometer saat ini',
                      hintText: 'Contoh: 8500',
                      prefixIcon: Icon(Icons.speed_outlined),
                      suffixText: 'km',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) {
                      final kilometer = int.tryParse(value ?? '');
                      if (kilometer == null || kilometer < 0) {
                        return 'Kilometer harus berupa angka 0 atau lebih';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          key: const Key('submitMotorButton'),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox.square(
                  key: Key('submitLoading'),
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Simpan perubahan' : 'Simpan motor'),
        ),
      ],
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wajib diisi';
    return null;
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final draft = MotorDraft(
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text),
      currentKilometer: int.parse(_kilometerController.text),
    );
    final notifier = ref.read(motorListProvider.notifier);
    final succeeded = widget.motor == null
        ? await notifier.create(draft)
        : await notifier.updateMotor(widget.motor!.id, draft);
    if (!mounted) return;
    if (succeeded) {
      Navigator.pop(context, true);
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Motor gagal disimpan. Coba lagi.')),
      );
    }
  }
}
