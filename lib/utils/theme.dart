import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium finance-app theming — Material 3, light & dark variants.
/// Design language: soft elevated surfaces, generous rounding, refined
/// typography hierarchy, and iOS-style page transitions for a polished,
/// "world-class" feel across platforms.
class AppTheme {
  AppTheme._();

  // Brand palette — refined, slightly desaturated for a premium finish.
  static const Color primaryLight = Color(0xFF0E7C4A); // emerald
  static const Color primaryDark = Color(0xFF34D399); // mint
  static const Color incomeColor = Color(0xFF16A34A);
  static const Color expenseColor = Color(0xFFEF4444);
  static const Color incomeColorSoft = Color(0xFF22C55E);
  static const Color expenseColorSoft = Color(0xFFF87171);

  static const Color surfaceLight = Color(0xFFF6F7F9);
  static const Color surfaceDark = Color(0xFF0E0F11);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1B1C1F); // elevated dark surface, not pure black

  static const double radiusLg = 24;
  static const double radiusMd = 18;
  static const double radiusSm = 12;

  static const List<Color> incomeGradient = [Color(0xFF22C55E), Color(0xFF15803D)];
  static const List<Color> expenseGradient = [Color(0xFFF87171), Color(0xFFDC2626)];
  static const List<Color> primaryGradient = [Color(0xFF34D399), Color(0xFF0E7C4A)];

  static List<BoxShadow> softShadow({bool dark = false}) => [
        BoxShadow(
          color: dark ? Colors.black.withOpacity(0.35) : Colors.black.withOpacity(0.06),
          blurRadius: 24,
          offset: const Offset(0, 10),
          spreadRadius: -6,
        ),
      ];

  static TextTheme _tamilTextTheme(TextTheme base, Color color) {
    final t = GoogleFonts.notoSansTamilTextTheme(base).apply(
      bodyColor: color,
      displayColor: color,
    );
    return t.copyWith(
      headlineSmall: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
      titleLarge: t.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2),
      bodyLarge: t.bodyLarge?.copyWith(letterSpacing: -0.1),
      bodyMedium: t.bodyMedium?.copyWith(letterSpacing: -0.1),
      bodySmall: t.bodySmall?.copyWith(letterSpacing: 0),
      labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  static const PageTransitionsTheme _iosLikeTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
    },
  );

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryLight,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme.copyWith(primary: primaryLight, secondary: primaryLight),
      scaffoldBackgroundColor: surfaceLight,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: _iosLikeTransitions,
      textTheme: _tamilTextTheme(ThemeData.light().textTheme, const Color(0xFF16181C)),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(color: Colors.black.withOpacity(0.06), thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceLight,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF16181C),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.notoSansTamil(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          color: const Color(0xFF16181C),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: primaryLight.withOpacity(0.14),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.notoSansTamil(fontSize: 10.5, fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.notoSansTamil(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.black.withOpacity(0.12)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.notoSansTamil(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.black.withOpacity(0.04),
        selectedColor: primaryLight,
        labelStyle: GoogleFonts.notoSansTamil(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withOpacity(0.035),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryLight, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryDark,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme.copyWith(primary: primaryDark, secondary: primaryDark),
      scaffoldBackgroundColor: surfaceDark,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: _iosLikeTransitions,
      textTheme: _tamilTextTheme(ThemeData.dark().textTheme, const Color(0xFFF2F3F5)),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(color: Colors.white.withOpacity(0.08), thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFFF2F3F5),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.notoSansTamil(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          color: const Color(0xFFF2F3F5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: primaryDark.withOpacity(0.18),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.notoSansTamil(fontSize: 10.5, fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryDark,
          foregroundColor: const Color(0xFF07130D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.notoSansTamil(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withOpacity(0.14)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.notoSansTamil(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.06),
        selectedColor: primaryDark,
        labelStyle: GoogleFonts.notoSansTamil(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryDark, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
