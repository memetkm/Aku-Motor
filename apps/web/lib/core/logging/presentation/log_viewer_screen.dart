import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_logger.dart';
import '../log_entry.dart';

/// Halaman antarmuka untuk melihat dan menelusuri log sistem secara langsung (runtime tracing).
class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  static const routeName = '/system-logs';

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  final _searchController = TextEditingController();
  LogLevel? _selectedLevel;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Sistem (Tracing)'),
        actions: [
          IconButton(
            key: const Key('copyLogsButton'),
            tooltip: 'Salin Seluruh Log',
            icon: const Icon(Icons.copy_all_outlined),
            onPressed: _handleCopyLogs,
          ),
          IconButton(
            key: const Key('simulateErrorButton'),
            tooltip: 'Simulasi Log Error',
            icon: const Icon(Icons.bug_report_outlined),
            onPressed: () {
              AppLogger.instance.e(
                'Simulasi error runtime berhasil dicatat oleh sistem tracing.',
                tag: 'SIMULATION',
                error: 'Exception: Test Diagnostic Trace',
                stackTrace: StackTrace.current,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Simulasi error berhasil dicatat ke log!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            key: const Key('clearLogsButton'),
            tooltip: 'Bersihkan Riwayat Log',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _handleClearLogs,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              // 1. Search Bar & Filter Chips
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  key: const Key('logSearchField'),
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari log berdasarkan pesan atau tag...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Hapus pencarian',
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                ),
              ),

              // 2. Filter Level Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Semua'),
                      selected: _selectedLevel == null,
                      onSelected: (_) => setState(() => _selectedLevel = null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Error'),
                      selected: _selectedLevel == LogLevel.error,
                      avatar: const Icon(Icons.error_outline, size: 16, color: Colors.red),
                      onSelected: (_) => setState(() => _selectedLevel = LogLevel.error),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Warning'),
                      selected: _selectedLevel == LogLevel.warning,
                      avatar: const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                      onSelected: (_) => setState(() => _selectedLevel = LogLevel.warning),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Info'),
                      selected: _selectedLevel == LogLevel.info,
                      avatar: const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                      onSelected: (_) => setState(() => _selectedLevel = LogLevel.info),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Debug'),
                      selected: _selectedLevel == LogLevel.debug,
                      avatar: const Icon(Icons.bug_report, size: 16, color: Colors.grey),
                      onSelected: (_) => setState(() => _selectedLevel = LogLevel.debug),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),

              // 3. Log Entries List
              Expanded(
                child: ValueListenableBuilder<List<LogEntry>>(
                  valueListenable: AppLogger.instance.logsNotifier,
                  builder: (context, allLogs, _) {
                    final filtered = allLogs.reversed.where((entry) {
                      if (_selectedLevel != null && entry.level != _selectedLevel) {
                        return false;
                      }
                      if (_searchQuery.isNotEmpty) {
                        final query = _searchQuery;
                        final matchesMsg = entry.message.toLowerCase().contains(query);
                        final matchesTag = entry.tag.toLowerCase().contains(query);
                        final matchesErr = entry.error?.toLowerCase().contains(query) ?? false;
                        if (!matchesMsg && !matchesTag && !matchesErr) return false;
                      }
                      return true;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              allLogs.isEmpty
                                  ? 'Belum ada catatan log sistem.'
                                  : 'Tidak ada log yang cocok dengan filter.',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      key: const Key('logsListView'),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _LogTile(entry: item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCopyLogs() async {
    final text = AppLogger.instance.exportLogsAsText();
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seluruh riwayat log disalin ke clipboard!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleClearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bersihkan Seluruh Log?'),
        content: const Text(
          'Semua catatan aktivitas dan tracing akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Bersihkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AppLogger.instance.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Riwayat log berhasil dibersihkan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    Color levelColor;
    IconData levelIcon;
    switch (entry.level) {
      case LogLevel.error:
        levelColor = Colors.red.shade700;
        levelIcon = Icons.error_outline;
        break;
      case LogLevel.warning:
        levelColor = Colors.orange.shade800;
        levelIcon = Icons.warning_amber_rounded;
        break;
      case LogLevel.info:
        levelColor = Colors.blue.shade700;
        levelIcon = Icons.info_outline;
        break;
      case LogLevel.debug:
        levelColor = Colors.grey.shade700;
        levelIcon = Icons.bug_report_outlined;
        break;
    }

    final timeStr =
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: levelColor.withValues(alpha: 0.3)),
      ),
      color: levelColor.withValues(alpha: 0.04),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        leading: Icon(levelIcon, color: levelColor, size: 22),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: levelColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                entry.tag,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: levelColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timeStr,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            entry.message,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        children: [
          if (entry.error != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: SelectableText(
                'Error: ${entry.error}',
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
          if (entry.stackTrace != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: SelectableText(
                entry.stackTrace!,
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
