import 'package:flutter/material.dart';

import '../domain/part_catalog.dart';

class PartConsequenceDialog extends StatelessWidget {
  const PartConsequenceDialog({required this.partName, super.key});

  final String partName;

  @override
  Widget build(BuildContext context) {
    final info = PartCatalog.getInfo(partName);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
          const SizedBox(width: 10),
          Expanded(child: Text('Edukasi: ${info.name}')),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Alasan rawan rusak
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kenapa rawan aus: ${info.vulnerabilityReason}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Kalo gak diganti bakal apa?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 10),

              // Level 1: Akibat Ringan
              _ConsequenceTile(
                level: '1. Akibat Awal / Ringan',
                description: info.consequenceLight,
                color: Colors.amber.shade700,
                icon: Icons.notifications_active_outlined,
              ),
              const SizedBox(height: 8),

              // Level 2: Akibat Sedang
              _ConsequenceTile(
                level: '2. Akibat Menengah',
                description: info.consequenceMedium,
                color: Colors.orange.shade800,
                icon: Icons.report_problem_outlined,
              ),
              const SizedBox(height: 8),

              // Level 3: Akibat Fatal
              _ConsequenceTile(
                level: '3. Akibat Fatal / Berbahaya',
                description: info.consequenceFatal,
                color: Colors.red.shade700,
                icon: Icons.dangerous_outlined,
              ),
              const SizedBox(height: 16),

              // Perbandingan Biaya
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perbandingan Biaya Nyata:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ganti tepat waktu:'),
                        Text(
                          'Rp ${_formatNumber(info.estimatedCostNow)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Jika rusak merembet/turun mesin:'),
                        Text(
                          'Rp ${_formatNumber(info.estimatedCostLater)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Saya Paham'),
        ),
      ],
    );
  }

  static String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

class _ConsequenceTile extends StatelessWidget {
  const _ConsequenceTile({
    required this.level,
    required this.description,
    required this.color,
    required this.icon,
  });

  final String level;
  final String description;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 4)),
        color: color.withOpacity(0.08),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                level,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(description),
        ],
      ),
    );
  }
}

