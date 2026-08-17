import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/database_service.dart';
import 'providers/settings_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/category_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/recurring_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the local database before anything else. If this fails
  // (corrupt Hive files, storage issues, etc.) show a recovery screen
  // instead of crashing.
  String? initError;
  try {
    await DatabaseService.instance.init();
  } catch (e) {
    initError = e.toString();
  }

  if (initError != null) {
    runApp(_DatabaseErrorApp(error: initError));
    return;
  }

  // Auto-generate any due recurring transactions (rent, salary, EMI, etc.)
  final recurringProvider = RecurringProvider();
  await recurringProvider.generateDueTransactions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider.value(value: recurringProvider),
      ],
      child: const KanakkuThaalApp(),
    ),
  );
}

/// Shown only if Hive database initialization fails outright — lets the
/// user retry instead of a blank crash screen.
class _DatabaseErrorApp extends StatelessWidget {
  final String error;
  const _DatabaseErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 56, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'தரவுத்தளத்தை தொடங்க முடியவில்லை',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(error, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => main(),
                    child: const Text('மீண்டும் முயற்சிக்கவும்'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
