import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../utils/helpers.dart';

/// ExportService — exports transactions to an .xlsx file.
class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  Future<String> exportTransactionsToExcel({
    required List<TransactionModel> transactions,
    required Map<String, CategoryModel> categoryLookup,
    required String fileNameSuffix,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Transactions'];
      excel.setDefaultSheet('Transactions');

      final headers = ['Date', 'Type', 'Category', 'Description', 'Amount', 'Notes'];
      sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

      final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));

      for (final t in sorted) {
        sheet.appendRow([
          TextCellValue(AppHelpers.formatDateShort(t.date)),
          TextCellValue(t.isIncome ? 'Income' : 'Expense'),
          TextCellValue(categoryLookup[t.categoryId]?.name ?? '-'),
          TextCellValue(t.description),
          DoubleCellValue(t.amount),
          TextCellValue(t.notes),
        ]);
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'kanakku_thaal_$fileNameSuffix.xlsx';
      final file = File('${dir.path}/$fileName');
      final bytes = excel.encode();
      if (bytes == null) {
        throw ExportException('Excel encode தோல்வியடைந்தது');
      }
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'கணக்கு தாள் Export');
      return file.path;
    } catch (e) {
      throw ExportException('Excel export தோல்வியடைந்தது: $e');
    }
  }
}

class ExportException implements Exception {
  final String message;
  ExportException(this.message);
  @override
  String toString() => message;
}
