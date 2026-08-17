import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// TransactionTile — a single row showing category icon, description,
/// date, and signed amount. Used in Home recent list and Transactions list.
class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel? category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.category,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = category != null
        ? AppHelpers.colorFromHex(category!.color)
        : (transaction.isIncome ? AppTheme.incomeColor : AppTheme.expenseColor);
    final icon = category != null ? AppConstants.iconFor(category!.icon) : Icons.category_rounded;
    final isIncome = transaction.isIncome;

    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description.isEmpty
                      ? (category?.name ?? 'மற்றவை')
                      : transaction.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${category?.name ?? ''} • ${AppHelpers.formatDate(transaction.date)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '${isIncome ? '+' : '-'} ${AppHelpers.formatCurrency(transaction.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (onEdit == null && onDelete == null) {
      return InkWell(borderRadius: BorderRadius.circular(14), onTap: onTap, child: content);
    }

    return Dismissible(
      key: ValueKey(transaction.id),
      background: _swipeBg(alignStart: true, icon: Icons.edit_rounded, color: Colors.blue),
      secondaryBackground: _swipeBg(alignStart: false, icon: Icons.delete_rounded, color: Colors.red),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
          return false;
        } else {
          return await _confirmDelete(context);
        }
      },
      onDismissed: (_) => onDelete?.call(),
      child: InkWell(borderRadius: BorderRadius.circular(14), onTap: onTap, child: content),
    );
  }

  Widget _swipeBg({required bool alignStart, required IconData icon, required Color color}) {
    return Container(
      alignment: alignStart ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, color: color),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('பரிவர்த்தனையை நீக்கவா?'),
        content: const Text('இந்த செயலை மீட்க முடியாது.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ரத்து')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('நீக்கு', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
