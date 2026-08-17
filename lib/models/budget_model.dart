import 'package:hive/hive.dart';

part 'budget_model.g.dart';

/// BudgetModel — மாதாந்திர வகை வாரியான பட்ஜெட்.
@HiveType(typeId: 2)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId; // empty string '' means overall monthly budget

  @HiveField(2)
  int year;

  @HiveField(3)
  int month;

  @HiveField(4)
  double limit;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.year,
    required this.month,
    required this.limit,
  });

  bool get isOverallBudget => categoryId.isEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'year': year,
        'month': month,
        'limit': limit,
      };

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String? ?? '',
      year: json['year'] as int,
      month: json['month'] as int,
      limit: (json['limit'] as num).toDouble(),
    );
  }
}
