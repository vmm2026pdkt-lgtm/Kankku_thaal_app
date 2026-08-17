import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'utils/theme.dart';
import 'services/database_service.dart';
import 'screens/setup/setup_wizard_screen.dart';
import 'screens/home/main_shell.dart';
import 'screens/lock/lock_screen.dart';

/// KanakkuThaalApp — root widget: theme, and routing between Setup Wizard,
/// Lock Screen, and the Main Shell based on stored settings.
class KanakkuThaalApp extends StatelessWidget {
  const KanakkuThaalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'கணக்கு தாள்',
      debugShowCheckedModeBanner: false,
      themeMode: settingsProvider.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: _resolveHome(settingsProvider),
    );
  }

  Widget _resolveHome(SettingsProvider settingsProvider) {
    if (!DatabaseService.instance.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!settingsProvider.isSetupComplete) {
      return const SetupWizardScreen();
    }
    final settings = settingsProvider.settings;
    if (settings.pinEnabled) {
      return LockScreen(biometricEnabled: settings.biometricEnabled);
    }
    return const MainShell();
  }
}
