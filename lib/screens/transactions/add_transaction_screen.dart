import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

/// AddTransactionScreen — full-screen form for creating/editing a
/// transaction, with income/expense toggle, category picker, and validation.
class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? existing;
  final String? initialType;

  const AddTransactionScreen({super.key, this.existing, this.initialType});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late String _type;
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  String? _categoryId;

  String? _amountError;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? widget.initialType ?? 'expense';
    if (e != null) {
      _amountController.text = e.amount.toStringAsFixed(0);
      _descController.text = e.description;
      _notesController.text = e.notes;
      _date = e.date;
      _categoryId = e.categoryId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final amountErr = AppHelpers.validateAmount(_amountController.text);
    setState(() {
      _amountError = amountErr;
      _categoryError = _categoryId == null ? 'வகையை தேர்ந்தெடுக்கவும்' : null;
    });
    if (amountErr != null || _categoryId == null) {
      HapticFeedback.mediumImpact();
      return;
    }

    HapticFeedback.lightImpact();
    final amount = AppHelpers.parseAmount(_amountController.text)!;
    final txnProvider = context.read<TransactionProvider>();

    if (widget.existing != null) {
      await txnProvider.updateTransaction(
        widget.existing!,
        type: _type,
        amount: amount,
        categoryId: _categoryId,
        description: _descController.text.trim(),
        notes: _notesController.text.trim(),
        date: _date,
      );
    } else {
      await txnProvider.addTransaction(
        type: _type,
        amount: amount,
        categoryId: _categoryId!,
        description: _descController.text.trim(),
        notes: _notesController.text.trim(),
        date: _date,
      );
    }

    Fluttertoast.showToast(
      msg: widget.existing != null ? 'புதுப்பிக்கப்பட்டது' : 'சேமிக்கப்பட்டது ✓',
      toastLength: Toast.LENGTH_SHORT,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = _type == 'income' ? categoryProvider.incomeCategories : categoryProvider.expenseCategories;

    if (_categoryId != null && !categories.any((c) => c.id == _categoryId)) {
      _categoryId = null;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('புதிய பரிவர்த்தனை')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income / Expense segmented toggle
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(child: _segmentButton('வருமானம்', 'income', AppTheme.incomeColor)),
                  Expanded(child: _segmentButton('செலவு', 'expense', AppTheme.expenseColor)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('தொகை', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(prefixText: '₹ ', hintText: '1,500', errorText: _amountError),
            ),
            const SizedBox(height: 20),
            Text('தேதி', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18),
                    const SizedBox(width: 10),
                    Text(AppHelpers.formatDate(_date)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('விவரம்', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(hintText: 'எ.கா. மதிய உணவு'),
            ),
            const SizedBox(height: 20),
            Text('வகை', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories.map((c) {
                final selected = c.id == _categoryId;
                final color = AppHelpers.colorFromHex(c.color);
                return ChoiceChip(
                  selected: selected,
                  onSelected: (_) => setState(() => _categoryId = c.id),
                  avatar: Icon(AppConstants.iconFor(c.icon), size: 16, color: selected ? Colors.white : color),
                  label: Text(c.name),
                  selectedColor: color,
                  labelStyle: TextStyle(color: selected ? Colors.white : null),
                );
              }).toList(),
            ),
            if (_categoryError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_categoryError!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
              ),
            const SizedBox(height: 20),
            Text('Notes (விருப்பம்)', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'கூடுதல் குறிப்புகள்...'),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('ரத்து'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('சேமிக்கவும்'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _segmentButton(String label, String value, Color color) {
    final selected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : null,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
