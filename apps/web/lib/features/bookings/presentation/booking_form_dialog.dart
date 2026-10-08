import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/booking_providers.dart';
import '../domain/booking.dart';

const List<String> kServiceTypes = [
  'Servis Berkala / Rutin',
  'Ganti Oli & Filter',
  'Tune Up & CVT',
  'Perbaikan Mesin & Kelistrikan',
];

class BookingFormDialog extends ConsumerStatefulWidget {
  const BookingFormDialog({this.booking, super.key});

  final Booking? booking;

  @override
  ConsumerState<BookingFormDialog> createState() => _BookingFormDialogState();
}

class _BookingFormDialogState extends ConsumerState<BookingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _motorController;
  late final TextEditingController _workshopController;
  late final TextEditingController _dateController;
  late final TextEditingController _notesController;
  String? _selectedServiceType;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final booking = widget.booking;
    _motorController = TextEditingController(text: booking?.motorDescription);
    _workshopController = TextEditingController(text: booking?.workshopName);
    _dateController = TextEditingController(
      text: booking != null
          ? booking.bookingDate.toIso8601String().split('T').first
          : DateTime.now().toIso8601String().split('T').first,
    );
    _notesController = TextEditingController(text: booking?.notes);
    _selectedServiceType = booking?.serviceType ?? kServiceTypes.first;
  }

  @override
  void dispose() {
    _motorController.dispose();
    _workshopController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.booking != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit booking servis' : 'Buat booking servis'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const Key('motorField'),
                  controller: _motorController,
                  decoration: const InputDecoration(
                    labelText: 'Motor (Merek & Model)',
                    hintText: 'Contoh: Honda Vario 160 (B 1234 ABC)',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('workshopField'),
                  controller: _workshopController,
                  decoration: const InputDecoration(
                    labelText: 'Bengkel tujuan',
                    hintText: 'Contoh: Bengkel Resmi AHASS 001',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Wajib diisi';
                    }
                    if (value.trim().length < 3) {
                      return 'Nama bengkel minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: const Key('serviceTypeField'),
                  value: _selectedServiceType,
                  decoration: const InputDecoration(
                    labelText: 'Jenis layanan servis',
                  ),
                  items: kServiceTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ),
                      )
                      .toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          setState(() => _selectedServiceType = value);
                        },
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Pilih jenis servis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('dateField'),
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Tanggal servis (YYYY-MM-DD)',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _isSubmitting ? null : _pickDate,
                    ),
                  ),
                  keyboardType: TextInputType.datetime,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Wajib diisi';
                    }
                    final parsed = DateTime.tryParse(value.trim());
                    if (parsed == null) {
                      return 'Format tanggal salah (YYYY-MM-DD)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('notesField'),
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Keluhan / Catatan perawatan',
                    hintText: 'Jelaskan kondisi motor atau kebutuhan servis',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Wajib diisi';
                    }
                    if (value.trim().length < 5) {
                      return 'Keluhan minimal 5 karakter';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          key: const Key('submitBookingButton'),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox.square(
                  key: Key('submitBookingLoading'),
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Simpan perubahan' : 'Konfirmasi booking'),
        ),
      ],
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wajib diisi';
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final date = DateTime.parse(_dateController.text.trim());
    final draft = BookingDraft(
      motorDescription: _motorController.text.trim(),
      workshopName: _workshopController.text.trim(),
      serviceType: _selectedServiceType ?? kServiceTypes.first,
      bookingDate: date,
      notes: _notesController.text.trim(),
      status: widget.booking?.status ?? 'Menunggu Konfirmasi',
    );

    final notifier = ref.read(bookingListProvider.notifier);
    final succeeded = widget.booking == null
        ? await notifier.create(draft)
        : await notifier.update(widget.booking!.id, draft);

    if (!mounted) return;
    if (succeeded) {
      Navigator.pop(context, true);
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking gagal disimpan. Coba lagi.')),
      );
    }
  }
}

