import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recurring_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/recurring_model.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/empty_state.dart';

/// RecurringScreen — manage recurring transaction templates (rent, salary,
/// EMI, subscriptions) with frequency and start/end dates.
class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recurringProvider = context.watch<RecurringProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final lookup = categoryProvider.lookup;
    final items = recurringProvider.all;

    return Scaffold(
      appBar: AppBar(title: const Text('மீண்டும் நிகழும் பரிவர்த்தனைகள்')),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.autorenew_rounded,
              title: 'இன்னும் எதுவும் இல்லை',
              subtitle: 'வாடகை, சம்பளம், EMI போன்றவற்றை தானியங்கியாக பதிவு செய்ய சேர்க்கவும்.',
              actionLabel: '+ சேர்க்க',
              onAction: () => _openEditor(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final r = items[index];
                final cat = lookup[r.categoryId];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (cat != null ? AppHelpers.colorFromHex(cat.color) : Colors.grey).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(cat != null ? AppConstants.iconFor(cat.icon) : Icons.autorenew_rounded,
                            color: cat != null ? AppHelpers.colorFromHex(cat.color) : Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.description.isEmpty ? (cat?.name ?? '') : r.description,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(_frequencyLabel(r.frequency), style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 100),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${r.type == 'income' ? '+' : '-'} ${AppHelpers.formatCurrency(r.amount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: r.type == 'income' ? AppTheme.incomeColor : AppTheme.expenseColor,
                                ),
                              ),
                            ),
                          ),
                          Switch(
                            value: r.enabled,
                            onChanged: (v) => context.read<RecurringProvider>().updateRecurring(r, enabled: v),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  String _frequencyLabel(String f) {
    switch (f) {
      case 'daily':
        return 'தினசரி';
      case 'weekly':
        return 'வாராந்திரம்';
      case 'monthly':
        return 'மாதாந்திரம்';
      case 'yearly':
        return 'வருடாந்திரம்';
      default:
        return f;
    }
  }

  void _openEditor(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecurringScreen()));
  }
}

class AddRecurringScreen extends StatefulWidget {
  const AddRecurringScreen({super.key});

  @override
  State<AddRecurringScreen> createState() => _AddRecurringScreenState();
}

class _AddRecurringScreenState extends State<AddRecurringScreen> {
  String _type = 'expense';
  String _frequency = 'monthly';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String? _categoryId;
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  String? _amountError;
  String? _categoryError;

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = _type == 'income' ? categoryProvider.incomeCategories : categoryProvider.expenseCategories;
    if (_categoryId != null && !categories.any((c) => c.id == _categoryId)) _categoryId = null;

    return Scaffold(
      appBar: AppBar(title: const Text('புதிய மீண்டும் நிகழும் பரிவர்த்தனை')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'expense', label: Text('செலவு')),
              ButtonSegment(value: 'income', label: Text('வருமானம்')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'தொகை', prefixText: '₹ ', errorText: _amountError),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'விவரம் (எ.கா. வீட்டு வாடகை)'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: categories.map((c) {
              return ChoiceChip(
                label: Text(c.name),
                selected: c.id == _categoryId,
                onSelected: (_) => setState(() => _categoryId = c.id),
              );
            }).toList(),
          ),
          if (_categoryError != null)
            Text(_categoryError!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _frequency,
            decoration: const InputDecoration(labelText: 'அதிர்வெண்'),
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('தினசரி')),
              DropdownMenuItem(value: 'weekly', child: Text('வாராந்திரம்')),
              DropdownMenuItem(value: 'monthly', child: Text('மாதாந்திரம்')),
              DropdownMenuItem(value: 'yearly', child: Text('வருடாந்திரம்')),
            ],
            onChanged: (v) => setState(() => _frequency = v!),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('தொடக்க தேதி'),
            subtitle: Text(AppHelpers.formatDate(_startDate)),
            trailing: const Icon(Icons.calendar_today_rounded, size: 18),
            onTap: () async {
              final picked = await showDatePicker(
                  context: context, initialDate: _startDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
              if (picked != null) setState(() => _startDate = picked);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('முடிவு தேதி (விருப்பம்)'),
            subtitle: Text(_endDate != null ? AppHelpers.formatDate(_endDate!) : 'இல்லை'),
            trailing: const Icon(Icons.calendar_today_rounded, size: 18),
            onTap: () async {
              final picked = await showDatePicker(
                  context: context, initialDate: _startDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
              if (picked != null) setState(() => _endDate = picked);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _save, child: const Text('சேமிக்கவும்')),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final amountErr = AppHelpers.validateAmount(_amountController.text);
    setState(() {
      _amountError = amountErr;
      _categoryError = _categoryId == null ? 'வகையை தேர்ந்தெடுக்கவும்' : null;
    });
    if (amountErr != null || _categoryId == null) return;

    await context.read<RecurringProvider>().addRecurring(
          type: _type,
          amount: AppHelpers.parseAmount(_amountController.text)!,
          categoryId: _categoryId!,
          description: _descController.text.trim(),
          frequency: _frequency,
          startDate: _startDate,
          endDate: _endDate,
        );
    if (mounted) Navigator.pop(context);
  }
}
