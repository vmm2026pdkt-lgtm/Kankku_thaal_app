import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';

enum TransactionFilterType { all, income, expense }
enum TransactionSort { newest, oldest }

/// TransactionProvider — manages transaction CRUD, filtering, search, and
/// monthly aggregation used across Home, Transactions, and Monthly screens.
class TransactionProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  static const _uuid = Uuid();

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime get selectedMonth => _selectedMonth;

  String _searchQuery = '';
  TransactionFilterType _filterType = TransactionFilterType.all;
  String? _filterCategoryId;
  TransactionSort _sort = TransactionSort.newest;

  String get searchQuery => _searchQuery;
  TransactionFilterType get filterType => _filterType;
  String? get filterCategoryId => _filterCategoryId;
  TransactionSort get sort => _sort;

  List<TransactionModel> get all => _db.transactions.values.toList();

  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setFilterType(TransactionFilterType t) {
    _filterType = t;
    notifyListeners();
  }

  void setFilterCategory(String? categoryId) {
    _filterCategoryId = categoryId;
    notifyListeners();
  }

  void setSort(TransactionSort s) {
    _sort = s;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterType = TransactionFilterType.all;
    _filterCategoryId = null;
    _sort = TransactionSort.newest;
    notifyListeners();
  }

  List<TransactionModel> get forSelectedMonth {
    return all.where((t) => t.date.year == _selectedMonth.year && t.date.month == _selectedMonth.month).toList();
  }

  List<TransactionModel> get filtered {
    var list = all;

    if (_filterType == TransactionFilterType.income) {
      list = list.where((t) => t.isIncome).toList();
    } else if (_filterType == TransactionFilterType.expense) {
      list = list.where((t) => t.isExpense).toList();
    }

    if (_filterCategoryId != null) {
      list = list.where((t) => t.categoryId == _filterCategoryId).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((t) {
        return t.description.toLowerCase().contains(q) ||
            t.notes.toLowerCase().contains(q) ||
            t.amount.toString().contains(q);
      }).toList();
    }

    list = [...list];
    if (_sort == TransactionSort.newest) {
      list.sort((a, b) => b.date.compareTo(a.date));
    } else {
      list.sort((a, b) => a.date.compareTo(b.date));
    }
    return list;
  }

  double monthlyIncome([DateTime? month]) {
    final m = month ?? _selectedMonth;
    return all
        .where((t) => t.isIncome && t.date.year == m.year && t.date.month == m.month)
        .fold(0.0, (s, t) => s + t.amount);
  }

  double monthlyExpense([DateTime? month]) {
    final m = month ?? _selectedMonth;
    return all
        .where((t) => t.isExpense && t.date.year == m.year && t.date.month == m.month)
        .fold(0.0, (s, t) => s + t.amount);
  }

  double get totalBalance {
    final income = all.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final expense = all.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);
    return income - expense;
  }

  List<TransactionModel> get recentTransactions {
    final list = [...all]..sort((a, b) => b.date.compareTo(a.date));
    return list.take(5).toList();
  }

  Future<TransactionModel> addTransaction({
    required String type,
    required double amount,
    required String categoryId,
    required String description,
    String notes = '',
    required DateTime date,
  }) async {
    final txn = TransactionModel(
      id: _uuid.v4(),
      type: type,
      amount: amount,
      categoryId: categoryId,
      description: description,
      notes: notes,
      date: date,
      createdAt: DateTime.now(),
    );
    await _db.transactions.put(txn.id, txn);
    notifyListeners();
    return txn;
  }

  Future<void> updateTransaction(TransactionModel txn, {
    String? type,
    double? amount,
    String? categoryId,
    String? description,
    String? notes,
    DateTime? date,
  }) async {
    if (type != null) txn.type = type;
    if (amount != null) txn.amount = amount;
    if (categoryId != null) txn.categoryId = categoryId;
    if (description != null) txn.description = description;
    if (notes != null) txn.notes = notes;
    if (date != null) txn.date = date;
    await txn.save();
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _db.transactions.delete(id);
    notifyListeners();
  }

  /// Category-wise totals for expenses in the selected month.
  Map<String, double> categoryTotalsForSelectedMonth({bool expenseOnly = true}) {
    final Map<String, double> totals = {};
    for (final t in forSelectedMonth) {
      if (expenseOnly && !t.isExpense) continue;
      totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
    }
    return totals;
  }

  /// List of years that have at least one transaction (for Monthly screen year picker).
  List<int> get availableYears {
    final years = all.map((t) => t.date.year).toSet().toList()..sort((a, b) => b.compareTo(a));
    if (years.isEmpty) years.add(DateTime.now().year);
    return years;
  }
}
