import 'package:hive/hive.dart';

part 'recurring_model.g.dart';

/// RecurringTransaction — தானியங்கி மீண்டும் நிகழும் பரிவர்த்தனைகள்.
@HiveType(typeId: 3)
class RecurringTransaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // income / expense

  @HiveField(2)
  double amount;

  @HiveField(3)
  String categoryId;

  @HiveField(4)
  String description;

  @HiveField(5)
  String frequency; // daily / weekly / monthly / yearly

  @HiveField(6)
  DateTime startDate;

  @HiveField(7)
  DateTime? endDate;

  @HiveField(8)
  bool enabled;

  @HiveField(9)
  DateTime? lastGeneratedDate;

  RecurringTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.description,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.enabled = true,
    this.lastGeneratedDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'categoryId': categoryId,
        'description': description,
        'frequency': frequency,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'enabled': enabled,
        'lastGeneratedDate': lastGeneratedDate?.toIso8601String(),
      };

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      description: json['description'] as String? ?? '',
      frequency: json['frequency'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      enabled: json['enabled'] as bool? ?? true,
      lastGeneratedDate: json['lastGeneratedDate'] != null
          ? DateTime.parse(json['lastGeneratedDate'] as String)
          : null,
    );
  }
}
