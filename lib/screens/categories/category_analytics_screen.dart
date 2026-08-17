import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/month_selector.dart';

/// CategoryAnalyticsScreen — pie/donut chart of expenses by category for
/// the selected month, plus a ranked breakdown list.
class CategoryAnalyticsScreen extends StatelessWidget {
  const CategoryAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txnProvider = context.watch<TransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final lookup = categoryProvider.lookup;

    final totals = txnProvider.categoryTotalsForSelectedMonth(expenseOnly: true);
    final totalExpense = totals.values.fold(0.0, (s, v) => s + v);
    final entries = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('வகை பகுப்பாய்வு')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: MonthSelector(
                month: txnProvider.selectedMonth,
                onPrevious: txnProvider.previousMonth,
                onNext: txnProvider.nextMonth,
              ),
            ),
            const SizedBox(height: 16),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: Text('இந்த மாதத்தில் செலவு பதிவுகள் இல்லை')),
              )
            else ...[
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: entries.map((e) {
                      final cat = lookup[e.key];
                      final pct = totalExpense > 0 ? (e.value / totalExpense * 100) : 0;
                      return PieChartSectionData(
                        value: e.value,
                        title: '${pct.toStringAsFixed(0)}%',
                        color: cat != null ? AppHelpers.colorFromHex(cat.color) : Colors.grey,
                        radius: 60,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up_rounded),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'இந்த மாதத்தில் அதிகம் செலவான வகை: ${lookup[entries.first.key]?.name ?? '-'}',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...entries.map((e) {
                final cat = lookup[e.key];
                final pct = totalExpense > 0 ? (e.value / totalExpense * 100) : 0;
                final txnCount = txnProvider.forSelectedMonth
                    .where((t) => t.isExpense && t.categoryId == e.key)
                    .length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: cat != null ? AppHelpers.colorFromHex(cat.color) : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(cat?.name ?? 'மற்றவை', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        Text('$txnCount பரிவர்த்தனை', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(width: 10),
                        Text('${AppHelpers.formatCurrency(e.value)} — ${pct.toStringAsFixed(0)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
