import 'package:hive/hive.dart';

part 'settings_model.g.dart';

/// AppSettings — app-wide அமைப்புகள்.
@HiveType(typeId: 4)
class AppSettings extends HiveObject {
  @HiveField(0)
  String userName;

  @HiveField(1)
  String accountName;

  @HiveField(2)
  double openingBalance;

  @HiveField(3)
  bool pinEnabled;

  @HiveField(4)
  bool biometricEnabled;

  @HiveField(5)
  String language; // 'ta' or 'en'

  @HiveField(6)
  bool darkMode;

  @HiveField(7)
  bool setupComplete;

  @HiveField(8)
  String? pinHash;

  AppSettings({
    this.userName = '',
    this.accountName = '',
    this.openingBalance = 0.0,
    this.pinEnabled = false,
    this.biometricEnabled = false,
    this.language = 'ta',
    this.darkMode = false,
    this.setupComplete = false,
    this.pinHash,
  });
}
