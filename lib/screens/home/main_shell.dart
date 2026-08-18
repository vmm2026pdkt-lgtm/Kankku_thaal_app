import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../transactions/transactions_screen.dart';
import '../categories/categories_screen.dart';
import '../monthly/monthly_screen.dart';
import '../settings/settings_screen.dart';
import 'home_screen.dart';

/// MainShell — owns the 5-tab bottom navigation:
/// முகப்பு, பரிவர்த்தனைகள், வகைகள், மாதாந்திரம், அமைப்புகள்.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _screens = const [
    HomeTab(),
    TransactionsScreen(),
    CategoriesScreen(),
    MonthlyScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          HapticFeedback.selectionClick();
          setState(() => _index = i);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'முகப்பு'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded), label: 'பட்டியல்'),
          NavigationDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category_rounded), label: 'வகைகள்'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'மாதம்'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'அமைப்பு'),
        ],
      ),
    );
  }
}
