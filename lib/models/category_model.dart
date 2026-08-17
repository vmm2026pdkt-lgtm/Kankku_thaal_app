import 'package:hive/hive.dart';

part 'category_model.g.dart';

/// CategoryModel — வருமானம் / செலவு வகைகளை குறிக்கிறது.
@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type; // 'income' or 'expense'

  @HiveField(3)
  String icon; // Material icon codepoint name (stored as string key)

  @HiveField(4)
  String color; // hex color string e.g. '#FF5722'

  @HiveField(5)
  bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'icon': icon,
        'color': color,
        'isDefault': isDefault,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
