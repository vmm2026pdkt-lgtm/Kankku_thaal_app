import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../budget/budget_screen.dart';
import '../recurring/recurring_screen.dart';
import 'pin_lock_screen.dart';
import 'backup_restore_screen.dart';
import 'profile_edit_screen.dart';

/// SettingsScreen — settings hub: profile, appearance, security,
/// budget/recurring shortcuts, backup/restore, and danger zone.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('அமைப்புகள்')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(settings.userName.isNotEmpty ? settings.userName[0] : '?')),
              title: Text(settings.userName.isEmpty ? 'பயனர்' : settings.userName),
              subtitle: Text(settings.accountName),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle(context, 'தோற்றம்'),
          Card(
            child: SwitchListTile(
              title: const Text('இருண்ட தீம் (Dark Mode)'),
              secondary: const Icon(Icons.dark_mode_rounded),
              value: settings.darkMode,
              onChanged: settingsProvider.toggleDarkMode,
            ),
          ),
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              leading: const Icon(Icons.language_rounded),
              title: const Text('மொழி'),
              trailing: DropdownButton<String>(
                value: settings.language,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'ta', child: Text('தமிழ்')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (v) => settingsProvider.setLanguage(v!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle(context, 'நிதி நிர்வாகம்'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.pie_chart_rounded),
                  title: const Text('Budget'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen())),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.autorenew_rounded),
                  title: const Text('மீண்டும் நிகழும் பரிவர்த்தனைகள்'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecurringScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle(context, 'பாதுகாப்பு'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_rounded),
              title: const Text('🔐 PIN Lock'),
              subtitle: Text(settings.pinEnabled ? 'இயக்கப்பட்டது' : 'முடக்கப்பட்டது'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PinLockScreen())),
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle(context, 'தரவு நிர்வாகம்'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup_rounded),
              title: const Text('Backup & Restore'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupRestoreScreen())),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('கணக்கு தாள் • Kanakku Thaal\nv1.0.0',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey)),
    );
  }
}
