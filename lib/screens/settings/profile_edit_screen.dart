import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/settings_provider.dart';
import '../../utils/helpers.dart';

/// ProfileEditScreen — lets the user edit name, account name, and opening
/// balance set during the setup wizard.
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _accountController;
  late TextEditingController _balanceController;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>().settings;
    _nameController = TextEditingController(text: s.userName);
    _accountController = TextEditingController(text: s.accountName);
    _balanceController = TextEditingController(text: s.openingBalance.toStringAsFixed(0));
  }

  Future<void> _save() async {
    await context.read<SettingsProvider>().updateProfile(
          userName: _nameController.text.trim(),
          accountName: _accountController.text.trim(),
          openingBalance: AppHelpers.parseAmount(_balanceController.text) ?? 0,
        );
    Fluttertoast.showToast(msg: 'புதுப்பிக்கப்பட்டது ✓');
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('சுயவிவரம்')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'பெயர்')),
          const SizedBox(height: 16),
          TextField(controller: _accountController, decoration: const InputDecoration(labelText: 'கணக்கு பெயர்')),
          const SizedBox(height: 16),
          TextField(
            controller: _balanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'தொடக்க இருப்பு', prefixText: '₹ '),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _save, child: const Text('சேமிக்கவும்')),
        ],
      ),
    );
  }
}
