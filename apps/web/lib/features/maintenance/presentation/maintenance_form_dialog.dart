import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../camera/application/camera_providers.dart';
import '../../camera/presentation/photo_preview_dialog.dart';
import '../../motors/application/motor_providers.dart';
import '../application/maintenance_providers.dart';
import '../domain/maintenance_record.dart';
import '../domain/part_catalog.dart';

class MaintenanceFormDialog extends ConsumerStatefulWidget {
  const MaintenanceFormDialog({
    this.record,
    this.initialMotorId,
    super.key,
  });

  final MaintenanceRecord? record;
  final String? initialMotorId;

  @override
  ConsumerState<MaintenanceFormDialog> createState() =>
      _MaintenanceFormDialogState();
}

class _MaintenanceFormDialogState extends ConsumerState<MaintenanceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kilometerController;
  late final TextEditingController _dateController;
  late final TextEditingController _notesController;
  String? _selectedMotorId;
  String? _selectedPartType;
  String _photoUrl = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _selectedMotorId = record?.motorId ?? widget.initialMotorId;
    _selectedPartType = record?.partType ?? PartCatalog.partNames.first;
    _photoUrl = record?.photoUrl ?? '';
    _kilometerController = TextEditingController(
      text: record?.lastReplacedKilometer.toString() ?? '',
    );
    _dateController = TextEditingController(
      text: record != null
          ? record.lastReplacedAt.toIso8601String().split('T').first
          : DateTime.now().toIso8601String().split('T').first,
    );
    _notesController = TextEditingController(text: record?.notes ?? '');
  }

  @override
  void dispose() {
    _kilometerController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final cameraService = ref.read(cameraServiceProvider);
    final result = await cameraService.takePhoto(
      label: 'Nota ${_selectedPartType ?? "Servis"}',
    );

    if (!mounted) return;
    if (result.isCancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengambilan foto dibatalkan.')),
      );
      return;
    }
    if (result.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage!)),
      );
      return;
    }
    if (result.isSuccess) {
      setState(() => _photoUrl = result.photoUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto bukti nota berhasil dilampirkan!'),
        ),
      );
    }
  }

  Future<void> _pickGallery() async {
    final cameraService = ref.read(cameraServiceProvider);
    final result = await cameraService.pickFromGallery(
      label: 'Nota Galeri ${_selectedPartType ?? "Servis"}',
    );

    if (!mounted) return;
    if (result.isSuccess) {
      setState(() => _photoUrl = result.photoUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto dari galeri berhasil dilampirkan!'),
        ),
      );
    }
  }

  void _previewPhoto() {
    if (_photoUrl.isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (_) => PhotoPreviewDialog(
        photoUrl: _photoUrl,
        title: 'Bukti Servis: ${_selectedPartType ?? "Part"}',
        date: DateTime.tryParse(_dateController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final motors = ref.watch(motorListProvider).valueOrNull ?? const [];
    if (_selectedMotorId == null && motors.isNotEmpty) {
      _selectedMotorId = motors.first.id;
    }

    final isEditing = widget.record != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Catatan Servis' : 'Catat Servis / Ganti Part'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (motors.isNotEmpty)
                  DropdownButtonFormField<String>(
                    key: const Key('motorSelectField'),
                    initialValue: _selectedMotorId,
                    decoration: const InputDecoration(labelText: 'Pilih Motor'),
                    items: motors
                        .map(
                          (m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(
                              '${m.brand} ${m.model} (${m.currentKilometer} km)',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _isSubmitting
                        ? null
                        : (val) => setState(() => _selectedMotorId = val),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Pilih motor' : null,
                  )
                else
                  TextFormField(
                    key: const Key('motorSelectField'),
                    initialValue: _selectedMotorId ?? 'default-motor',
                    decoration: const InputDecoration(labelText: 'ID / Nama Motor'),
                    onChanged: (val) => _selectedMotorId = val,
                  ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: const Key('partTypeSelectField'),
                  initialValue: _selectedPartType,
                  decoration: const InputDecoration(
                    labelText: 'Komponen yang Diservis / Diganti',
                  ),
                  items: PartCatalog.partNames
                      .map(
                        (part) => DropdownMenuItem(
                          value: part,
                          child: Text(part),
                        ),
                      )
                      .toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (val) => setState(() => _selectedPartType = val),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Pilih komponen' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('lastKilometerField'),
                  controller: _kilometerController,
                  decoration: const InputDecoration(
                    labelText: 'Kilometer saat ganti',
                    hintText: 'Contoh: 12500',
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final km = int.tryParse(value ?? '');
                    if (km == null || km < 0) {
                      return 'Kilometer harus berupa angka 0 atau lebih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('lastDateField'),
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Tanggal servis / ganti (YYYY-MM-DD)',
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
                    if (DateTime.tryParse(value.trim()) == null) {
                      return 'Format tanggal salah (YYYY-MM-DD)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('maintenanceNotesField'),
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan tambahan / merek part (Opsional)',
                    hintText: 'Misal: Oli Shell Advance 10W-40, bengkel resmi',
                  ),
                ),
                const SizedBox(height: 16),
                // Camera / Photo Attachment Section
                Text(
                  'Lampiran Bukti Servis (Kamera / Nota)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                ),
                const SizedBox(height: 6),
                if (_photoUrl.isEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('cameraCaptureButton'),
                          onPressed: _isSubmitting ? null : _takePhoto,
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: const Text('Ambil Foto Nota'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        key: const Key('galleryPickerButton'),
                        onPressed: _isSubmitting ? null : _pickGallery,
                        icon: const Icon(Icons.photo_library_outlined, size: 18),
                        label: const Text('Galeri'),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.receipt_outlined, color: Colors.blue.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Foto bukti nota terlampir',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined, size: 20),
                          tooltip: 'Lihat Foto',
                          onPressed: _previewPhoto,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          tooltip: 'Hapus Foto',
                          color: Colors.red.shade700,
                          onPressed: () => setState(() => _photoUrl = ''),
                        ),
                      ],
                    ),
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
          key: const Key('submitMaintenanceButton'),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox.square(
                  key: Key('submitMaintenanceLoading'),
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Simpan perubahan' : 'Simpan catatan'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
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

    final draft = MaintenanceDraft(
      motorId: _selectedMotorId ?? 'default-motor',
      partType: _selectedPartType ?? 'Oli Mesin',
      lastReplacedAt: DateTime.parse(_dateController.text.trim()),
      lastReplacedKilometer: int.parse(_kilometerController.text.trim()),
      notes: _notesController.text.trim(),
      photoUrl: _photoUrl,
    );

    final notifier = ref.read(maintenanceListProvider.notifier);
    final succeeded = widget.record == null
        ? await notifier.create(draft)
        : await notifier.updateMaintenance(widget.record!.id, draft);

    if (!mounted) return;
    if (succeeded) {
      Navigator.pop(context, true);
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan gagal disimpan. Coba lagi.')),
      );
    }
  }
}
