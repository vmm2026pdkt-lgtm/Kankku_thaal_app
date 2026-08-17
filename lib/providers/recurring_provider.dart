import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/recurring_model.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';

/// RecurringProvider — manages recurring transaction templates and
/// generates due transactions automatically (e.g. on app launch).
class RecurringProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  static const _uuid = Uuid();

  List<RecurringTransaction> get all => _db.recurring.values.toList();

  List<RecurringTransaction> get active => all.where((r) => r.enabled).toList();

  Future<RecurringTransaction> addRecurring({
    required String type,
    required double amount,
    required String categoryId,
    required String description,
    required String frequency,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final r = RecurringTransaction(
      id: _uuid.v4(),
      type: type,
      amount: amount,
      categoryId: categoryId,
      description: description,
      frequency: frequency,
      startDate: startDate,
      endDate: endDate,
    );
    await _db.recurring.put(r.id, r);
    notifyListeners();
    return r;
  }

  Future<void> updateRecurring(RecurringTransaction r, {
    double? amount,
    String? description,
    String? frequency,
    DateTime? endDate,
    bool? enabled,
  }) async {
    if (amount != null) r.amount = amount;
    if (description != null) r.description = description;
    if (frequency != null) r.frequency = frequency;
    if (endDate != null) r.endDate = endDate;
    if (enabled != null) r.enabled = enabled;
    await r.save();
    notifyListeners();
  }

  Future<void> deleteRecurring(String id) async {
    await _db.recurring.delete(id);
    notifyListeners();
  }

  DateTime _nextDate(DateTime from, String frequency) {
    switch (frequency) {
      case 'daily':
        return from.add(const Duration(days: 1));
      case 'weekly':
        return from.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(from.year, from.month + 1, from.day);
      case 'yearly':
        return DateTime(from.year + 1, from.month, from.day);
      default:
        return from.add(const Duration(days: 30));
    }
  }

  /// Generates any transactions that are due for all active recurring
  /// templates, up to today. Call once on app start.
  /// Returns the count of transactions generated.
  Future<int> generateDueTransactions() async {
    int generated = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final r in active) {
      if (r.endDate != null && r.endDate!.isBefore(today)) continue;

      DateTime cursor = r.lastGeneratedDate ?? r.startDate;
      // If never generated, first occurrence is the start date itself.
      bool isFirst = r.lastGeneratedDate == null;

      while (true) {
        final occurrence = isFirst ? cursor : _nextDate(cursor, r.frequency);
        if (occurrence.isAfter(today)) break;
        if (r.endDate != null && occurrence.isAfter(r.endDate!)) break;

        final txn = TransactionModel(
          id: _uuid.v4(),
          type: r.type,
          amount: r.amount,
          categoryId: r.categoryId,
          description: r.description,
          notes: 'தானியங்கி பரிவர்த்தனை',
          date: occurrence,
          createdAt: DateTime.now(),
        );
        await _db.transactions.put(txn.id, txn);
        generated++;

        r.lastGeneratedDate = occurrence;
        cursor = occurrence;
        isFirst = false;
      }
      await r.save();
    }
    if (generated > 0) notifyListeners();
    return generated;
  }
}
