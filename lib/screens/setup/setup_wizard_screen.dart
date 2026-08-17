import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/helpers.dart';
import '../home/home_screen.dart';

/// SetupWizardScreen — 3-step first-launch onboarding.
class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  final PageController _pageController = PageController();
  int _step = 0;

  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');

  String? _nameError;
  String? _accountError;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _accountController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0) {
      if (_nameController.text.trim().isEmpty) {
        setState(() => _nameError = 'பெயரை உள்ளிடவும்');
        return;
      }
      setState(() => _nameError = null);
    }
    if (_step == 1) {
      if (_accountController.text.trim().isEmpty) {
        setState(() => _accountError = 'கணக்கு பெயரை உள்ளிடவும்');
        return;
      }
      setState(() => _accountError = null);
    }
    if (_step < 2) {
      setState(() => _step++);
      _pageController.animateToPage(_step, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.animateToPage(_step, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _finish() async {
    final balance = AppHelpers.parseAmount(_balanceController.text) ?? 0;
    final settingsProvider = context.read<SettingsProvider>();
    await settingsProvider.completeSetup(
      userName: _nameController.text.trim(),
      accountName: _accountController.text.trim(),
      openingBalance: balance,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text('🪙', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              'கணக்கு தாள்',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      decoration: BoxDecoration(
                        color: i <= _step
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StepContent(
                    title: 'உங்களை எப்படி அழைக்க வேண்டும்?',
                    child: TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(hintText: 'உங்கள் பெயர்', errorText: _nameError),
                    ),
                  ),
                  _StepContent(
                    title: 'உங்கள் கணக்கு பெயர்',
                    child: TextField(
                      controller: _accountController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(hintText: 'எ.கா. என் குடும்ப கணக்கு', errorText: _accountError),
                    ),
                  ),
                  _StepContent(
                    title: 'தொடக்க இருப்பு',
                    child: TextField(
                      controller: _balanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(prefixText: '₹ ', hintText: '10,000'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_step > 0)
                    TextButton(onPressed: _back, child: const Text('பின்செல்')),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _next,
                    child: Text(_step == 2 ? 'கணக்கை தொடங்குங்கள்' : 'தொடரவும்'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  final String title;
  final Widget child;
  const _StepContent({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
