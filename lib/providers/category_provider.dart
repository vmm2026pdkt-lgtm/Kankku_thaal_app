import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../services/database_service.dart';

/// CategoryProvider — manages income/expense categories (CRUD).
class CategoryProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  static const _uuid = Uuid();

  List<CategoryModel> get all => _db.categories.values.toList();

  List<CategoryModel> get incomeCategories =>
      all.where((c) => c.type == 'income').toList()..sort((a, b) => a.name.compareTo(b.name));

  List<CategoryModel> get expenseCategories =>
      all.where((c) => c.type == 'expense').toList()..sort((a, b) => a.name.compareTo(b.name));

  Map<String, CategoryModel> get lookup => {for (final c in all) c.id: c};

  CategoryModel? byId(String id) => _db.categories.get(id);

  Future<CategoryModel> addCategory({
    required String name,
    required String type,
    required String icon,
    required String color,
  }) async {
    final cat = CategoryModel(
      id: _uuid.v4(),
      name: name,
      type: type,
      icon: icon,
      color: color,
      isDefault: false,
    );
    await _db.categories.put(cat.id, cat);
    notifyListeners();
    return cat;
  }

  Future<void> updateCategory(CategoryModel category, {
    String? name,
    String? icon,
    String? color,
  }) async {
    if (name != null) category.name = name;
    if (icon != null) category.icon = icon;
    if (color != null) category.color = color;
    await category.save();
    notifyListeners();
  }

  /// Returns false if category is in use and cannot be safely deleted.
  bool canDelete(String categoryId) => !_db.isCategoryInUse(categoryId);

  Future<bool> deleteCategory(String categoryId) async {
    if (!canDelete(categoryId)) return false;
    await _db.categories.delete(categoryId);
    notifyListeners();
    return true;
  }

  /// Migrates all transactions from one category to another, then deletes the old one.
  Future<void> deleteAndMigrate(String fromCategoryId, String toCategoryId) async {
    final txns = _db.transactions.values.where((t) => t.categoryId == fromCategoryId).toList();
    for (final t in txns) {
      t.categoryId = toCategoryId;
      await t.save();
    }
    await _db.categories.delete(fromCategoryId);
    notifyListeners();
  }
}
