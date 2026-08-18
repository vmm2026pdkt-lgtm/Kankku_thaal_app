import 'package:flutter/material.dart';

/// App-wide constants — default categories, colors, strings.
class AppConstants {
  AppConstants._();

  static const String appNameTamil = 'கணக்கு தாள்';
  static const String appNameEnglish = 'Kanakku Thaal';

  // Hive box names
  static const String transactionBox = 'transactions';
  static const String categoryBox = 'categories';
  static const String budgetBox = 'budgets';
  static const String recurringBox = 'recurring';
  static const String settingsBox = 'settings';
  static const String settingsKey = 'app_settings';

  static const List<String> months = [
    'ஜனவரி', 'பிப்ரவரி', 'மார்ச்', 'ஏப்ரல்', 'மே', 'ஜூன்',
    'ஜூலை', 'ஆகஸ்ட்', 'செப்டம்பர்', 'அக்டோபர்', 'நவம்பர்', 'டிசம்பர்'
  ];

  static const List<String> monthsEnglish = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  /// Default income categories: name -> (iconKey, colorHex)
  static const List<Map<String, String>> defaultIncomeCategories = [
    {'name': 'சம்பளம்', 'icon': 'work', 'color': '#4CAF50'},
    {'name': 'வியாபாரம்', 'icon': 'store', 'color': '#2196F3'},
    {'name': 'ஃப்ரீலான்ஸ்', 'icon': 'laptop', 'color': '#9C27B0'},
    {'name': 'வாடகை வருமானம்', 'icon': 'home', 'color': '#FF9800'},
    {'name': 'வட்டி', 'icon': 'percent', 'color': '#00BCD4'},
    {'name': 'மற்ற வருமானம்', 'icon': 'more_horiz', 'color': '#607D8B'},
  ];

  /// Default expense categories: name -> (iconKey, colorHex)
  static const List<Map<String, String>> defaultExpenseCategories = [
    {'name': 'உணவு', 'icon': 'restaurant', 'color': '#F44336'},
    {'name': 'மளிகை', 'icon': 'shopping_cart', 'color': '#FF5722'},
    {'name': 'பெட்ரோல்', 'icon': 'local_gas_station', 'color': '#795548'},
    {'name': 'போக்குவரத்து', 'icon': 'directions_bus', 'color': '#3F51B5'},
    {'name': 'வாகன பராமரிப்பு', 'icon': 'build', 'color': '#607D8B'},
    {'name': 'மருத்துவம்', 'icon': 'local_hospital', 'color': '#E91E63'},
    {'name': 'கல்வி', 'icon': 'school', 'color': '#3F51B5'},
    {'name': 'மின்சாரம்', 'icon': 'bolt', 'color': '#F59E0B'},
    {'name': 'வாடகை', 'icon': 'apartment', 'color': '#009688'},
    {'name': 'ஆடை', 'icon': 'checkroom', 'color': '#9C27B0'},
    {'name': 'தொலைபேசி', 'icon': 'phone_android', 'color': '#00BCD4'},
    {'name': 'மற்றவை', 'icon': 'more_horiz', 'color': '#757575'},
  ];

  /// Maps icon key strings (stored in Hive) to actual Material icons.
  static const Map<String, IconData> iconMap = {
    'work': Icons.work_rounded,
    'store': Icons.storefront_rounded,
    'laptop': Icons.laptop_mac_rounded,
    'home': Icons.home_rounded,
    'percent': Icons.percent_rounded,
    'more_horiz': Icons.more_horiz_rounded,
    'restaurant': Icons.restaurant_rounded,
    'shopping_cart': Icons.shopping_cart_rounded,
    'local_gas_station': Icons.local_gas_station_rounded,
    'directions_bus': Icons.directions_bus_rounded,
    'build': Icons.build_rounded,
    'local_hospital': Icons.local_hospital_rounded,
    'school': Icons.school_rounded,
    'bolt': Icons.bolt_rounded,
    'apartment': Icons.apartment_rounded,
    'checkroom': Icons.checkroom_rounded,
    'phone_android': Icons.phone_android_rounded,
    'category': Icons.category_rounded,
    'pets': Icons.pets_rounded,
    'flight': Icons.flight_rounded,
    'sports_esports': Icons.sports_esports_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'card_giftcard': Icons.card_giftcard_rounded,
  };

  static IconData iconFor(String key) => iconMap[key] ?? Icons.category_rounded;

  /// Selectable icon keys for custom category creation.
  static const List<String> selectableIcons = [
    'work', 'store', 'laptop', 'home', 'percent', 'restaurant',
    'shopping_cart', 'local_gas_station', 'directions_bus', 'build',
    'local_hospital', 'school', 'bolt', 'apartment', 'checkroom',
    'phone_android', 'category', 'pets', 'flight', 'sports_esports',
    'fitness_center', 'card_giftcard', 'more_horiz',
  ];

  static const List<String> selectableColors = [
    '#F44336', '#E91E63', '#9C27B0', '#673AB7', '#3F51B5',
    '#2196F3', '#03A9F4', '#00BCD4', '#009688', '#4CAF50',
    '#8BC34A', '#CDDC39', '#FFC107', '#FF9800', '#FF5722',
    '#795548', '#607D8B',
  ];
}
