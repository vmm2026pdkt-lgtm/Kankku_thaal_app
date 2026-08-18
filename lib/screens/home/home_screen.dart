import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/animated_amount.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/empty_state.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transactions_screen.dart';
import 'main_shell.dart';

/// HomeScreen — the primary dashboard: greeting, month selector, summary
/// cards, income/expense chart, and recent transactions.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // If reached directly (e.g. after setup), route into the main shell
    // which owns bottom navigation.
    return const MainShell();
  }
}

/// HomeTab — the actual dashboard content shown inside MainShell's first tab.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final txnProvider = context.watch<TransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final lookup = categoryProvider.lookup;

    final income = txnProvider.monthlyIncome();
    final expense = txnProvider.monthlyExpense();
    final balance = income - expense;
    final recent = txnProvider.recentTransactions;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'வணக்கம், ${settingsProvider.settings.userName.isEmpty ? 'நண்பரே' : settingsProvider.settings.userName} 👋',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              settingsProvider.settings.accountName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 16),
            Center(
              child: MonthSelector(
                month: txnProvider.selectedMonth,
                onPrevious: txnProvider.previousMonth,
                onNext: txnProvider.nextMonth,
              ),
            ),
            const SizedBox(height: 16),
            _BalanceHeroCard(balance: balance, income: income, expense: expense),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    label: 'வருமானம்',
                    amount: income,
                    icon: Icons.arrow_downward_rounded,
                    color: AppTheme.incomeColor,
                    gradient: AppTheme.incomeGradient,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    label: 'செலவு',
                    amount: expense,
                    icon: Icons.arrow_upward_rounded,
                    color: AppTheme.expenseColor,
                    gradient: AppTheme.expenseGradient,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (income > 0 || expense > 0) ...[
              Text('வருமானம் Vs செலவு', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Container(
                height: 190,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: AppTheme.softShadow(dark: Theme.of(context).brightness == Brightness.dark),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (income > expense ? income : expense) * 1.25 + 1,
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final label = value == 0 ? 'வருமானம்' : 'செலவு';
                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
                      ),
                    ),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(
                          toY: income,
                          width: 44,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                          gradient: const LinearGradient(
                            colors: AppTheme.incomeGradient,
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(
                          toY: expense,
                          width: 44,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                          gradient: const LinearGradient(
                            colors: AppTheme.expenseGradient,
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ]),
                    ],
                  ),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                ),
              ),
              const SizedBox(height: 24),
            ],
            Row(
              children: [
                Expanded(
                  child: Text(
                    'சமீபத்திய பரிவர்த்தனைகள்',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen())),
                  child: const Text('அனைத்தும்', maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            if (recent.isEmpty)
              EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'இன்னும் பரிவர்த்தனைகள் இல்லை',
                subtitle: 'உங்கள் முதல் வரவு அல்லது செலவை பதிவு செய்யுங்கள்.',
                actionLabel: '+ பரிவர்த்தனை சேர்க்க',
                onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
              )
            else
              ...recent.map((t) => TransactionTile(transaction: t, category: lookup[t.categoryId])),
          ],
        ),
      ),
    );
  }
}

/// _BalanceHeroCard — an Apple-Wallet-style gradient hero card that shows
/// the current month's balance prominently, with income/expense mini-stats.
class _BalanceHeroCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;

  const _BalanceHeroCard({required this.balance, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final positive = balance >= 0;
    final gradient = positive ? AppTheme.primaryGradient : AppTheme.expenseGradient;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(color: gradient.last.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 12), spreadRadius: -6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded, color: Colors.white.withOpacity(0.85), size: 18),
              const SizedBox(width: 6),
              Text(
                'இந்த மாத இருப்பு',
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedAmount(
              amount: balance,
              style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.8),
            ),
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white.withOpacity(0.18)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _heroStat(context, Icons.arrow_downward_rounded, 'வருமானம்', income)),
              Container(width: 1, height: 30, color: Colors.white.withOpacity(0.18)),
              Expanded(child: _heroStat(context, Icons.arrow_upward_rounded, 'செலவு', expense)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(BuildContext context, IconData icon, String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.85), size: 15),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppHelpers.formatCurrency(value),
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
