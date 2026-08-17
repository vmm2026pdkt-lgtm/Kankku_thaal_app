import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import '../models/recurring_model.dart';
import 'database_service.dart';

/// BackupService — exports/imports all app data as a single JSON file.
class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  final DatabaseService _db = DatabaseService.instance;

  /// Builds a full JSON snapshot of the user's data.
  Map<String, dynamic> _buildBackupJson() {
    final settings = _db.settings.get('app_settings');
    return {
      'appName': 'கணக்கு தாள்',
      'backupVersion': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings != null
          ? {
              'userName': settings.userName,
              'accountName': settings.accountName,
              'openingBalance': settings.openingBalance,
              'language': settings.language,
              'darkMode': settings.darkMode,
            }
          : null,
      'categories': _db.categories.values.map((c) => c.toJson()).toList(),
      'transactions': _db.transactions.values.map((t) => t.toJson()).toList(),
      'budgets': _db.budgets.values.map((b) => b.toJson()).toList(),
      'recurring': _db.recurring.values.map((r) => r.toJson()).toList(),
    };
  }

  /// Exports data to a JSON file in app documents dir and opens the share sheet.
  /// Returns the file path on success. Throws [BackupException] on failure.
  Future<String> exportBackup() async {
    try {
      final data = _buildBackupJson();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'kanakku_thaal_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonStr);
      await Share.shareXFiles([XFile(file.path)], text: 'கணக்கு தாள் Backup');
      return file.path;
    } catch (e) {
      throw BackupException('Backup தோல்வியடைந்தது: $e');
    }
  }

  /// Restores data from a picked JSON file path.
  /// [merge]=false replaces all data, true merges with existing.
  Future<RestoreResult> restoreFromFile(String filePath, {bool merge = false}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw BackupException('Backup கோப்பு கிடைக்கவில்லை');
      }
      final content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);

      if (!data.containsKey('transactions') || !data.containsKey('categories')) {
        throw BackupException('இது சரியான Backup கோப்பு இல்லை');
      }

      if (!merge) {
        await _db.transactions.clear();
        await _db.categories.clear();
        await _db.budgets.clear();
        await _db.recurring.clear();
      }

      const uuid = Uuid();
      int categoriesRestored = 0;
      int transactionsRestored = 0;

      final categoryIdMap = <String, String>{};

      for (final catJson in (data['categories'] as List)) {
        final cat = CategoryModel.fromJson(Map<String, dynamic>.from(catJson));
        final newId = merge ? uuid.v4() : cat.id;
        categoryIdMap[cat.id] = newId;
        final newCat = CategoryModel(
          id: newId,
          name: cat.name,
          type: cat.type,
          icon: cat.icon,
          color: cat.color,
          isDefault: cat.isDefault,
        );
        await _db.categories.put(newId, newCat);
        categoriesRestored++;
      }

      for (final txnJson in (data['transactions'] as List)) {
        final txn = TransactionModel.fromJson(Map<String, dynamic>.from(txnJson));
        final newId = merge ? uuid.v4() : txn.id;
        final mappedCategoryId = categoryIdMap[txn.categoryId] ?? txn.categoryId;
        final newTxn = TransactionModel(
          id: newId,
          type: txn.type,
          amount: txn.amount,
          categoryId: mappedCategoryId,
          description: txn.description,
          notes: txn.notes,
          date: txn.date,
          createdAt: txn.createdAt,
        );
        await _db.transactions.put(newId, newTxn);
        transactionsRestored++;
      }

      if (data['budgets'] != null) {
        for (final bJson in (data['budgets'] as List)) {
          final b = BudgetModel.fromJson(Map<String, dynamic>.from(bJson));
          final newId = merge ? uuid.v4() : b.id;
          final mappedCategoryId =
              b.categoryId.isEmpty ? '' : (categoryIdMap[b.categoryId] ?? b.categoryId);
          await _db.budgets.put(
            newId,
            BudgetModel(
              id: newId,
              categoryId: mappedCategoryId,
              year: b.year,
              month: b.month,
              limit: b.limit,
            ),
          );
        }
      }

      if (data['recurring'] != null) {
        for (final rJson in (data['recurring'] as List)) {
          final r = RecurringTransaction.fromJson(Map<String, dynamic>.from(rJson));
          final newId = merge ? uuid.v4() : r.id;
          final mappedCategoryId = categoryIdMap[r.categoryId] ?? r.categoryId;
          await _db.recurring.put(
            newId,
            RecurringTransaction(
              id: newId,
              type: r.type,
              amount: r.amount,
              categoryId: mappedCategoryId,
              description: r.description,
              frequency: r.frequency,
              startDate: r.startDate,
              endDate: r.endDate,
              enabled: r.enabled,
              lastGeneratedDate: r.lastGeneratedDate,
            ),
          );
        }
      }

      return RestoreResult(
        categoriesRestored: categoriesRestored,
        transactionsRestored: transactionsRestored,
      );
    } on BackupException {
      rethrow;
    } catch (e) {
      throw BackupException('Restore தோல்வியடைந்தது: கோப்பு சிதைந்திருக்கலாம். ($e)');
    }
  }
}

class RestoreResult {
  final int categoriesRestored;
  final int transactionsRestored;
  RestoreResult({required this.categoriesRestored, required this.transactionsRestored});
}

class BackupException implements Exception {
  final String message;
  BackupException(this.message);
  @override
  String toString() => message;
}
