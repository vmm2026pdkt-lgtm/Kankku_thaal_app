import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/settings_provider.dart';
import '../../services/auth_service.dart';

/// PinLockScreen — enable/disable/change 4-digit PIN, and toggle biometric
/// unlock. PIN is never stored as plain text (SHA-256 hash via AuthService).
class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    AuthService.instance.isBiometricAvailable().then((v) => setState(() => _biometricAvailable = v));
  }

  Future<void> _enablePin() async {
    final pin = await _promptForPin(title: 'புதிய PIN உருவாக்கவும்');
    if (pin == null) return;
    final confirm = await _promptForPin(title: 'PIN ஐ உறுதிப்படுத்தவும்');
    if (confirm != pin) {
      Fluttertoast.showToast(msg: 'PIN பொருந்தவில்லை');
      return;
    }
    await AuthService.instance.setPin(pin);
    if (mounted) context.read<SettingsProvider>().refresh();
    Fluttertoast.showToast(msg: 'PIN இயக்கப்பட்டது ✓');
  }

  Future<void> _changePin() async {
    final pin = await _promptForPin(title: 'புதிய PIN');
    if (pin == null) return;
    final confirm = await _promptForPin(title: 'PIN ஐ உறுதிப்படுத்தவும்');
    if (confirm != pin) {
      Fluttertoast.showToast(msg: 'PIN பொருந்தவில்லை');
      return;
    }
    await AuthService.instance.setPin(pin);
    Fluttertoast.showToast(msg: 'PIN மாற்றப்பட்டது ✓');
  }

  Future<void> _disablePin() async {
    await AuthService.instance.disablePin();
    if (mounted) context.read<SettingsProvider>().refresh();
    Fluttertoast.showToast(msg: 'PIN முடக்கப்பட்டது');
  }

  Future<String?> _promptForPin({required String title}) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(counterText: ''),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ரத்து')),
          TextButton(
            onPressed: () {
              if (controller.text.length == 4) {
                Navigator.pop(ctx, controller.text);
              }
            },
            child: const Text('சரி'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('PIN Lock')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('PIN Lock இயக்கு'),
              subtitle: const Text('App ஐ திறக்க PIN தேவை'),
              value: settings.pinEnabled,
              onChanged: (v) => v ? _enablePin() : _disablePin(),
            ),
          ),
          if (settings.pinEnabled) ...[
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.password_rounded),
                title: const Text('PIN ஐ மாற்று'),
                onTap: _changePin,
              ),
            ),
            const SizedBox(height: 10),
            if (_biometricAvailable)
              Card(
                child: SwitchListTile(
                  title: const Text('Fingerprint / Face அங்கீகாரம்'),
                  secondary: const Icon(Icons.fingerprint_rounded),
                  value: settings.biometricEnabled,
                  onChanged: (v) => settingsProvider.setBiometricEnabled(v),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
