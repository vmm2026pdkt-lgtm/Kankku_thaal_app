import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/empty_state.dart';
import 'add_transaction_screen.dart';

/// TransactionsScreen — searchable, filterable, sortable list of all
/// transactions with swipe-to-edit / swipe-to-delete.
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txnProvider = context.watch<TransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final lookup = categoryProvider.lookup;
    final list = txnProvider.filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('பரிவர்த்தனைகள்'),
        actions: [
          PopupMenuButton<TransactionSort>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: txnProvider.setSort,
            itemBuilder: (_) => const [
              PopupMenuItem(value: TransactionSort.newest, child: Text('புதியது முதலில்')),
              PopupMenuItem(value: TransactionSort.oldest, child: Text('பழையது முதலில்')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: txnProvider.setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'தேடல் (விவரம், வகை, தொகை)...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip(context, 'அனைத்தும்', txnProvider.filterType == TransactionFilterType.all,
                    () => txnProvider.setFilterType(TransactionFilterType.all)),
                const SizedBox(width: 8),
                _filterChip(context, 'வருமானம்', txnProvider.filterType == TransactionFilterType.income,
                    () => txnProvider.setFilterType(TransactionFilterType.income)),
                const SizedBox(width: 8),
                _filterChip(context, 'செலவு', txnProvider.filterType == TransactionFilterType.expense,
                    () => txnProvider.setFilterType(TransactionFilterType.expense)),
                const SizedBox(width: 8),
                ...categoryProvider.all.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _filterChip(
                        context,
                        c.name,
                        txnProvider.filterCategoryId == c.id,
                        () => txnProvider.setFilterCategory(
                            txnProvider.filterCategoryId == c.id ? null : c.id),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: 'இன்னும் பரிவர்த்தனைகள் இல்லை',
                    subtitle: 'உங்கள் முதல் வரவு அல்லது செலவை பதிவு செய்யுங்கள்.',
                    actionLabel: '+ பரிவர்த்தனை சேர்க்க',
                    onAction: () => _openAdd(context),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final t = list[index];
                      return TransactionTile(
                        transaction: t,
                        category: lookup[t.categoryId],
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddTransactionScreen(existing: t)),
                        ),
                        onDelete: () => context.read<TransactionProvider>().deleteTransaction(t.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAdd(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _openAdd(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
  }

  Widget _filterChip(BuildContext context, String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
