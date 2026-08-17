import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

/// Shared formatting and validation helpers.
class AppHelpers {
  AppHelpers._();

  static final NumberFormat _rupeeFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _rupeeFormatDecimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String formatCurrency(double amount, {bool decimals = false}) {
    return decimals ? _rupeeFormatDecimal.format(amount) : _rupeeFormat.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatMonthYear(int year, int month) {
    return DateFormat('MMMM yyyy').format(DateTime(year, month));
  }

  static Color colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Validates a transaction amount string. Returns error message or null.
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'தொகையை உள்ளிடவும்';
    }
    final cleaned = value.replaceAll(',', '').replaceAll('₹', '').trim();
    final amount = double.tryParse(cleaned);
    if (amount == null) {
      return 'சரியான தொகையை உள்ளிடவும்';
    }
    if (amount <= 0) {
      return 'தொகை பூஜ்ஜியத்தை விட அதிகமாக இருக்க வேண்டும்';
    }
    return null;
  }

  static double? parseAmount(String value) {
    final cleaned = value.replaceAll(',', '').replaceAll('₹', '').trim();
    return double.tryParse(cleaned);
  }
}
