import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../utils/helpers.dart';

/// PdfService — generates a printable monthly financial report.
class PdfService {
  PdfService._();
  static final PdfService instance = PdfService._();

  Future<String> generateMonthlyReport({
    required String userName,
    required String accountName,
    required int year,
    required int month,
    required String monthLabel,
    required List<TransactionModel> transactions,
    required Map<String, CategoryModel> categoryLookup,
  }) async {
    try {
      final doc = pw.Document();

      final income = transactions.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
      final expense = transactions.where((t) => t.isExpense).fold<double>(0, (s, t) => s + t.amount);
      final balance = income - expense;

      // Category breakdown (expenses only)
      final Map<String, double> categoryTotals = {};
      for (final t in transactions.where((t) => t.isExpense)) {
        final catName = categoryLookup[t.categoryId]?.name ?? 'மற்றவை';
        categoryTotals[catName] = (categoryTotals[catName] ?? 0) + t.amount;
      }
      final sortedCategories = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final sortedTxns = [...transactions]..sort((a, b) => b.date.compareTo(a.date));

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Kanakku Thaal',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Monthly Financial Report — $monthLabel',
                      style: const pw.TextStyle(fontSize: 14)),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Account: $accountName'),
            pw.Text('User: $userName'),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(children: [
                  _cell('Income', bold: true),
                  _cell(AppHelpers.formatCurrency(income)),
                ]),
                pw.TableRow(children: [
                  _cell('Expense', bold: true),
                  _cell(AppHelpers.formatCurrency(expense)),
                ]),
                pw.TableRow(children: [
                  _cell('Balance', bold: true),
                  _cell(AppHelpers.formatCurrency(balance)),
                ]),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Category Breakdown',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(children: [
                  _cell('Category', bold: true),
                  _cell('Amount', bold: true),
                  _cell('% of Expense', bold: true),
                ]),
                ...sortedCategories.map((e) {
                  final pct = expense > 0 ? (e.value / expense * 100) : 0;
                  return pw.TableRow(children: [
                    _cell(e.key),
                    _cell(AppHelpers.formatCurrency(e.value)),
                    _cell('${pct.toStringAsFixed(1)}%'),
                  ]);
                }),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Transactions',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(children: [
                  _cell('Date', bold: true),
                  _cell('Type', bold: true),
                  _cell('Description', bold: true),
                  _cell('Amount', bold: true),
                ]),
                ...sortedTxns.map((t) => pw.TableRow(children: [
                      _cell(AppHelpers.formatDateShort(t.date)),
                      _cell(t.isIncome ? 'Income' : 'Expense'),
                      _cell(t.description.isEmpty
                          ? (categoryLookup[t.categoryId]?.name ?? '-')
                          : t.description),
                      _cell(AppHelpers.formatCurrency(t.amount)),
                    ])),
              ],
            ),
          ],
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'kanakku_thaal_report_${year}_$month.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await doc.save());
      return file.path;
    } catch (e) {
      throw PdfGenerationException('PDF உருவாக்கம் தோல்வியடைந்தது: $e');
    }
  }

  Future<void> printOrShare(String filePath) async {
    final file = File(filePath);
    await Printing.sharePdf(bytes: await file.readAsBytes(), filename: file.path.split('/').last);
  }

  pw.Widget _cell(String text, {bool bold = false}) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text,
            style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: 10)),
      );
}

class PdfGenerationException implements Exception {
  final String message;
  PdfGenerationException(this.message);
  @override
  String toString() => message;
}
