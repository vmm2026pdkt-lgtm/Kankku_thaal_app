import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../transactions/transactions_screen.dart';

/// MonthlyScreen — yearly bar chart of income vs expense per month, with a
/// year selector and tap-through to that month's transactions.
class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    final txnProvider = context.watch<TransactionProvider>();
    final years = txnProvider.availableYears;
    if (!years.contains(_year)) _year = years.first;

    double maxVal = 1;
    final monthlyData = List.generate(12, (i) {
      final month = DateTime(_year, i + 1);
      final income = txnProvider.monthlyIncome(month);
      final expense = txnProvider.monthlyExpense(month);
      if (income > maxVal) maxVal = income;
      if (expense > maxVal) maxVal = expense;
      return (income, expense);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('மாதாந்திர அறிக்கை'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _year,
              items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
              onChanged: (v) => setState(() => _year = v!),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              height: 240,
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: BarChart(
                BarChartData(
                  maxY: maxVal * 1.2,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx > 11) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(AppConstants.months[idx].substring(0, 3), style: const TextStyle(fontSize: 9)),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(12, (i) {
                    final (income, expense) = monthlyData[i];
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(toY: income, color: AppTheme.incomeColor, width: 6, borderRadius: BorderRadius.circular(3)),
                      BarChartRodData(toY: expense, color: AppTheme.expenseColor, width: 6, borderRadius: BorderRadius.circular(3)),
                    ], barsSpace: 3);
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(12, (i) {
              final month = DateTime(_year, i + 1);
              final (income, expense) = monthlyData[i];
              if (income == 0 && expense == 0) return const SizedBox.shrink();
              final count = txnProvider.all.where((t) => t.date.year == _year && t.date.month == i + 1).length;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  context.read<TransactionProvider>().setSelectedMonth(month);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen()));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppConstants.months[i], style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('$count பரிவர்த்தனைகள்', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('+${AppHelpers.formatCurrency(income)}',
                              style: const TextStyle(color: AppTheme.incomeColor, fontWeight: FontWeight.w600, fontSize: 12)),
                          Text('-${AppHelpers.formatCurrency(expense)}',
                              style: const TextStyle(color: AppTheme.expenseColor, fontWeight: FontWeight.w600, fontSize: 12)),
                          Text(AppHelpers.formatCurrency(income - expense),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
