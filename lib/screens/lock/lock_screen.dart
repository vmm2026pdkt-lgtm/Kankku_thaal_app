import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home/main_shell.dart';

/// LockScreen — shown at app launch if PIN lock is enabled. Supports PIN
/// entry and, if available and enabled, biometric unlock.
class LockScreen extends StatefulWidget {
  final bool biometricEnabled;
  const LockScreen({super.key, required this.biometricEnabled});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _pinController = TextEditingController();
  String? _error;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    if (widget.biometricEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
    }
  }

  Future<void> _tryBiometric() async {
    final ok = await AuthService.instance.authenticateWithBiometrics();
    if (ok && mounted) _unlock();
  }

  Future<void> _verifyPin() async {
    setState(() => _checking = true);
    final ok = await AuthService.instance.verifyPin(_pinController.text);
    setState(() => _checking = false);
    if (ok) {
      _unlock();
    } else {
      setState(() => _error = 'தவறான PIN');
      _pinController.clear();
    }
  }

  void _unlock() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text('கணக்கு தாள்', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, letterSpacing: 12),
                  decoration: InputDecoration(counterText: '', errorText: _error, hintText: '----'),
                  onSubmitted: (_) => _verifyPin(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _checking ? null : _verifyPin,
                    child: _checking
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('திற'),
                  ),
                ),
                if (widget.biometricEnabled) ...[
                  const SizedBox(height: 16),
                  IconButton(
                    icon: const Icon(Icons.fingerprint_rounded, size: 36),
                    onPressed: _tryBiometric,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
