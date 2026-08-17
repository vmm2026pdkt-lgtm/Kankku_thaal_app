import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/budget_model.dart';
import '../services/database_service.dart';
import 'transaction_provider.dart';

/// BudgetProvider — manages overall + category-wise monthly budgets,
/// and computes spend-vs-limit progress.
class BudgetProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  static const _uuid = Uuid();

  List<BudgetModel> get all => _db.budgets.values.toList();

  List<BudgetModel> forMonth(int year, int month) {
    return all.where((b) => b.year == year && b.month == month).toList();
  }

  BudgetModel? overallBudget(int year, int month) {
    try {
      return forMonth(year, month).firstWhere((b) => b.isOverallBudget);
    } catch (_) {
      return null;
    }
  }

  BudgetModel? categoryBudget(String categoryId, int year, int month) {
    try {
      return forMonth(year, month).firstWhere((b) => b.categoryId == categoryId);
    } catch (_) {
      return null;
    }
  }

  Future<void> setOverallBudget(int year, int month, double limit) async {
    final existing = overallBudget(year, month);
    if (existing != null) {
      existing.limit = limit;
      await existing.save();
    } else {
      final budget = BudgetModel(id: _uuid.v4(), categoryId: '', year: year, month: month, limit: limit);
      await _db.budgets.put(budget.id, budget);
    }
    notifyListeners();
  }

  Future<void> setCategoryBudget(String categoryId, int year, int month, double limit) async {
    final existing = categoryBudget(categoryId, year, month);
    if (existing != null) {
      existing.limit = limit;
      await existing.save();
    } else {
      final budget = BudgetModel(
        id: _uuid.v4(),
        categoryId: categoryId,
        year: year,
        month: month,
        limit: limit,
      );
      await _db.budgets.put(budget.id, budget);
    }
    notifyListeners();
  }

  Future<void> deleteBudget(String id) async {
    await _db.budgets.delete(id);
    notifyListeners();
  }

  /// Returns spend progress (0.0 - 1.0+) for a category budget given a
  /// TransactionProvider's category totals for the month.
  double progressFor(double spent, double limit) {
    if (limit <= 0) return 0;
    return spent / limit;
  }

  bool isExceeded(double spent, double limit) => limit > 0 && spent > limit;
}
