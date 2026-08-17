import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/backup_service.dart';
import '../../services/database_service.dart';
import '../../services/pdf_service.dart';
import '../../services/export_service.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/helpers.dart';
import '../setup/setup_wizard_screen.dart';

/// BackupRestoreScreen — export/import JSON backup, generate PDF/Excel
/// reports for the selected month, and a double-confirmed data wipe.
class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _busy = false;

  Future<void> _runBusy(Future<void> Function() task) async {
    setState(() => _busy = true);
    try {
      await task();
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _backup() async {
    await _runBusy(() async {
      await BackupService.instance.exportBackup();
      Fluttertoast.showToast(msg: 'Backup சேமிக்கப்பட்டது ✓');
    });
  }

  Future<void> _restore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text('பழைய தரவுகள் மாற்றப்படலாம். தொடரவா?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ரத்து')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('தொடரவும்')),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result == null || result.files.single.path == null) return;

    await _runBusy(() async {
      final res = await BackupService.instance.restoreFromFile(result.files.single.path!);
      if (mounted) {
        context.read<TransactionProvider>();
        context.read<CategoryProvider>();
        context.read<SettingsProvider>().refresh();
        Fluttertoast.showToast(
          msg: '${res.transactionsRestored} பரிவர்த்தனைகள் மீட்கப்பட்டன ✓',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    });
  }

  Future<void> _generatePdf() async {
    await _runBusy(() async {
      final txnProvider = context.read<TransactionProvider>();
      final categoryProvider = context.read<CategoryProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      final month = txnProvider.selectedMonth;
      final path = await PdfService.instance.generateMonthlyReport(
        userName: settingsProvider.settings.userName,
        accountName: settingsProvider.settings.accountName,
        year: month.year,
        month: month.month,
        monthLabel: AppHelpers.formatMonthYear(month.year, month.month),
        transactions: txnProvider.forSelectedMonth,
        categoryLookup: categoryProvider.lookup,
      );
      await PdfService.instance.printOrShare(path);
    });
  }

  Future<void> _exportExcel() async {
    await _runBusy(() async {
      final txnProvider = context.read<TransactionProvider>();
      final categoryProvider = context.read<CategoryProvider>();
      final month = txnProvider.selectedMonth;
      await ExportService.instance.exportTransactionsToExcel(
        transactions: txnProvider.forSelectedMonth,
        categoryLookup: categoryProvider.lookup,
        fileNameSuffix: '${AppHelpers.formatMonthYear(month.year, month.month)}'.replaceAll(' ', '_').toLowerCase(),
      );
    });
  }

  Future<void> _clearAllData() async {
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🗑 அனைத்து தரவையும் அழிக்க'),
        content: const Text('இது அனைத்து பரிவர்த்தனைகள், வகைகள், Budget தரவையும் நிரந்தரமாக நீக்கும். தொடரவா?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ரத்து')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('தொடரவும்', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (firstConfirm != true) return;

    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('உறுதிப்படுத்தவும்'),
        content: const Text('இது கடைசி எச்சரிக்கை. அனைத்து தரவும் நிரந்தரமாக நீக்கப்படும்.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ரத்து')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ஆம், அழிக்கவும்', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (secondConfirm != true) return;

    await _runBusy(() async {
      await DatabaseService.instance.clearAllData();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SetupWizardScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.upload_rounded),
                  title: const Text('📤 Backup Data'),
                  subtitle: const Text('அனைத்து தரவையும் JSON ஆக export செய்யவும்'),
                  onTap: _backup,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: const Text('📥 Restore Data'),
                  subtitle: const Text('JSON backup கோப்பிலிருந்து மீட்டமைக்கவும்'),
                  onTap: _restore,
                ),
              ),
              const SizedBox(height: 20),
              Text('அறிக்கைகள் (தேர்ந்தெடுக்கப்பட்ட மாதம்)', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf_rounded),
                  title: const Text('PDF அறிக்கை உருவாக்கு'),
                  onTap: _generatePdf,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.table_chart_rounded),
                  title: const Text('Excel ஆக Export செய்யவும்'),
                  onTap: _exportExcel,
                ),
              ),
              const SizedBox(height: 30),
              Card(
                color: Colors.red.withOpacity(0.06),
                child: ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  title: const Text('🗑 அனைத்து தரவையும் அழிக்க', style: TextStyle(color: Colors.red)),
                  onTap: _clearAllData,
                ),
              ),
            ],
          ),
          if (_busy)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
