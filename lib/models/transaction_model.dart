import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

/// TransactionModel — ஒரு வரவு அல்லது செலவு பதிவை குறிக்கிறது.
@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // 'income' or 'expense'

  @HiveField(2)
  double amount;

  @HiveField(3)
  String categoryId;

  @HiveField(4)
  String description;

  @HiveField(5)
  String notes;

  @HiveField(6)
  DateTime date;

  @HiveField(7)
  DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.description,
    this.notes = '',
    required this.date,
    required this.createdAt,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'categoryId': categoryId,
        'description': description,
        'notes': notes,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      description: json['description'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  TransactionModel copyWith({
    String? type,
    double? amount,
    String? categoryId,
    String? description,
    String? notes,
    DateTime? date,
  }) {
    return TransactionModel(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      createdAt: createdAt,
    );
  }
}
