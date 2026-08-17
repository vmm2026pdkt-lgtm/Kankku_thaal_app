import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

/// BudgetScreen — set an overall monthly budget plus per-category budgets,
/// with progress bars and over-limit warnings.
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txnProvider = context.watch<TransactionProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final year = txnProvider.selectedMonth.year;
    final month = txnProvider.selectedMonth.month;
    final overall = budgetProvider.overallBudget(year, month);
    final totalExpense = txnProvider.monthlyExpense();
    final categoryTotals = txnProvider.categoryTotalsForSelectedMonth(expenseOnly: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('மாத Budget', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _BudgetCard(
            title: 'மொத்த மாத செலவு Budget',
            spent: totalExpense,
            limit: overall?.limit ?? 0,
            onEdit: () => _editBudgetDialog(
              context,
              title: 'மாத Budget',
              initial: overall?.limit ?? 0,
              onSave: (v) => budgetProvider.setOverallBudget(year, month, v),
            ),
          ),
          const SizedBox(height: 24),
          Text('வகை வாரியான Budget', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...categoryProvider.expenseCategories.map((c) {
            final budget = budgetProvider.categoryBudget(c.id, year, month);
            final spent = categoryTotals[c.id] ?? 0;
            if (budget == null && spent == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BudgetCard(
                title: c.name,
                icon: AppConstants.iconFor(c.icon),
                iconColor: AppHelpers.colorFromHex(c.color),
                spent: spent,
                limit: budget?.limit ?? 0,
                onEdit: () => _editBudgetDialog(
                  context,
                  title: '${c.name} Budget',
                  initial: budget?.limit ?? 0,
                  onSave: (v) => budgetProvider.setCategoryBudget(c.id, year, month, v),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _addCategoryBudgetDialog(context, categoryProvider, budgetProvider, year, month),
            icon: const Icon(Icons.add_rounded),
            label: const Text('வகை Budget சேர்க்க'),
          ),
        ],
      ),
    );
  }

  Future<void> _editBudgetDialog(
    BuildContext context, {
    required String title,
    required double initial,
    required Future<void> Function(double) onSave,
  }) async {
    final controller = TextEditingController(text: initial > 0 ? initial.toStringAsFixed(0) : '');
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '₹ ', hintText: '5,000'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ரத்து')),
          TextButton(
            onPressed: () {
              final v = AppHelpers.parseAmount(controller.text);
              Navigator.pop(ctx, v);
            },
            child: const Text('சேமிக்கவும்'),
          ),
        ],
      ),
    );
    if (result != null && result > 0) await onSave(result);
  }

  Future<void> _addCategoryBudgetDialog(
    BuildContext context,
    CategoryProvider categoryProvider,
    BudgetProvider budgetProvider,
    int year,
    int month,
  ) async {
    final category = await showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('வகையை தேர்ந்தெடுக்கவும்'),
        children: categoryProvider.expenseCategories
            .map((c) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, c),
                  child: Row(children: [
                    Icon(AppConstants.iconFor(c.icon), color: AppHelpers.colorFromHex(c.color), size: 18),
                    const SizedBox(width: 10),
                    Text(c.name),
                  ]),
                ))
            .toList(),
      ),
    );
    if (category != null && context.mounted) {
      await _editBudgetDialog(
        context,
        title: '${category.name} Budget',
        initial: 0,
        onSave: (v) => budgetProvider.setCategoryBudget(category.id, year, month, v),
      );
    }
  }
}

class _BudgetCard extends StatelessWidget {
  final String title;
  final double spent;
  final double limit;
  final VoidCallback onEdit;
  final IconData? icon;
  final Color? iconColor;

  const _BudgetCard({
    required this.title,
    required this.spent,
    required this.limit,
    required this.onEdit,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final exceeded = limit > 0 && spent > limit;
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: exceeded ? Border.all(color: AppTheme.expenseColor.withOpacity(0.5)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 8),
              ],
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 18),
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: limit > 0 ? progress : 0,
              minHeight: 8,
              backgroundColor: Colors.black.withOpacity(0.06),
              color: exceeded ? AppTheme.expenseColor : Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            limit > 0
                ? '${AppHelpers.formatCurrency(spent)} / ${AppHelpers.formatCurrency(limit)}'
                : '${AppHelpers.formatCurrency(spent)} — Budget அமைக்கப்படவில்லை',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (exceeded) ...[
            const SizedBox(height: 6),
            Row(
              children: const [
                Icon(Icons.warning_amber_rounded, size: 16, color: AppTheme.expenseColor),
                SizedBox(width: 6),
                Text('Budget வரம்பை கடந்துவிட்டது', style: TextStyle(color: AppTheme.expenseColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
