import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import '../models/recurring_model.dart';
import '../models/settings_model.dart';
import '../utils/constants.dart';

/// DatabaseService — Hive-based local database wrapper.
/// Handles initialization, box access, and default category seeding.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  late Box<TransactionModel> _transactionBox;
  late Box<CategoryModel> _categoryBox;
  late Box<BudgetModel> _budgetBox;
  late Box<RecurringTransaction> _recurringBox;
  late Box<AppSettings> _settingsBox;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Box<TransactionModel> get transactions => _transactionBox;
  Box<CategoryModel> get categories => _categoryBox;
  Box<BudgetModel> get budgets => _budgetBox;
  Box<RecurringTransaction> get recurring => _recurringBox;
  Box<AppSettings> get settings => _settingsBox;

  /// Initializes Hive, registers adapters, opens boxes.
  /// Throws a descriptive error if initialization fails so the UI can
  /// show a recovery screen instead of crashing.
  Future<void> init() async {
    if (_initialized) return;
    try {
      await Hive.initFlutter();

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TransactionModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CategoryModelAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(BudgetModelAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(RecurringTransactionAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(AppSettingsAdapter());
      }

      _transactionBox = await Hive.openBox<TransactionModel>(AppConstants.transactionBox);
      _categoryBox = await Hive.openBox<CategoryModel>(AppConstants.categoryBox);
      _budgetBox = await Hive.openBox<BudgetModel>(AppConstants.budgetBox);
      _recurringBox = await Hive.openBox<RecurringTransaction>(AppConstants.recurringBox);
      _settingsBox = await Hive.openBox<AppSettings>(AppConstants.settingsBox);

      await _seedDefaultCategoriesIfEmpty();
      _initialized = true;
    } catch (e) {
      throw DatabaseInitException('தரவுத்தளத்தை தொடங்க முடியவில்லை: $e');
    }
  }

  Future<void> _seedDefaultCategoriesIfEmpty() async {
    if (_categoryBox.isNotEmpty) return;
    const uuid = Uuid();
    for (final cat in AppConstants.defaultIncomeCategories) {
      final model = CategoryModel(
        id: uuid.v4(),
        name: cat['name']!,
        type: 'income',
        icon: cat['icon']!,
        color: cat['color']!,
        isDefault: true,
      );
      await _categoryBox.put(model.id, model);
    }
    for (final cat in AppConstants.defaultExpenseCategories) {
      final model = CategoryModel(
        id: uuid.v4(),
        name: cat['name']!,
        type: 'expense',
        icon: cat['icon']!,
        color: cat['color']!,
        isDefault: true,
      );
      await _categoryBox.put(model.id, model);
    }
  }

  /// Checks whether a category is referenced by any transaction.
  bool isCategoryInUse(String categoryId) {
    return _transactionBox.values.any((t) => t.categoryId == categoryId);
  }

  /// Wipes all app data. Used by "அனைத்தையும் அழிக்க" with double confirmation
  /// already handled at the UI layer.
  Future<void> clearAllData() async {
    await _transactionBox.clear();
    await _categoryBox.clear();
    await _budgetBox.clear();
    await _recurringBox.clear();
    await _settingsBox.clear();
    await _seedDefaultCategoriesIfEmpty();
  }
}

class DatabaseInitException implements Exception {
  final String message;
  DatabaseInitException(this.message);
  @override
  String toString() => message;
}
