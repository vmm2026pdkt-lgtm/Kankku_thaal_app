import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/summary_card.dart';
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
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    label: 'வருமானம்',
                    amount: income,
                    icon: Icons.arrow_downward_rounded,
                    color: AppTheme.incomeColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    label: 'செலவு',
                    amount: expense,
                    icon: Icons.arrow_upward_rounded,
                    color: AppTheme.expenseColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SummaryCard(
              label: 'இருப்பு',
              amount: balance,
              icon: Icons.account_balance_wallet_rounded,
              color: balance >= 0 ? AppTheme.incomeColor : AppTheme.expenseColor,
            ),
            const SizedBox(height: 24),
            if (income > 0 || expense > 0) ...[
              Text('வருமானம் Vs செலவு', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                height: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (income > expense ? income : expense) * 1.2 + 1,
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
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(label, style: const TextStyle(fontSize: 12)),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(toY: income, color: AppTheme.incomeColor, width: 40, borderRadius: BorderRadius.circular(8)),
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(toY: expense, color: AppTheme.expenseColor, width: 40, borderRadius: BorderRadius.circular(8)),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('சமீபத்திய பரிவர்த்தனைகள்', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen())),
                  child: const Text('அனைத்தையும் பார்க்க'),
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
