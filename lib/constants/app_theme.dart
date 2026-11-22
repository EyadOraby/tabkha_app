import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabkha_app/constants/app_colors.dart';

/// Tabkha's warm home-kitchen look: herb green and tomato on cream, Young
/// Serif for headings and Nunito for text, with Lalezar and Baloo Bhaijaan 2
/// for Arabic.
const tabkhaDisplay = 'YoungSerif';
const tabkhaDisplayFallback = ['Lalezar'];
const tabkhaText = 'Nunito';
const tabkhaTextFallback = ['BalooBhaijaan2'];

const _cream = Color(0xFFFFF8EC);
const _card = Color(0xFFFFFDF8);
const _ink = Color(0xFF2B2118);
const _line = Color(0xFFEADCC4);

ThemeData tabkhaTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primaryColor).copyWith(
    primary: AppColors.primaryColor,
    onPrimary: Colors.white,
    secondary: AppColors.secondaryColor,
    onSecondary: Colors.white,
    tertiary: const Color(0xFFE3A33A),
    surface: _cream,
    onSurface: _ink,
    onSurfaceVariant: const Color(0xFF7A6A5A),
    outlineVariant: _line,
    primaryContainer: const Color(0xFFDDE8D3),
    onPrimaryContainer: const Color(0xFF1F3A1C),
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  final text = base.textTheme.apply(
    fontFamily: tabkhaText,
    fontFamilyFallback: tabkhaTextFallback,
    bodyColor: _ink,
    displayColor: _ink,
  );
  TextStyle? display(TextStyle? s) => s?.copyWith(
        fontFamily: tabkhaDisplay,
        fontFamilyFallback: tabkhaDisplayFallback,
        fontWeight: FontWeight.w400,
      );

  return base.copyWith(
    scaffoldBackgroundColor: _cream,
    primaryColor: AppColors.primaryColor,
    textTheme: text.copyWith(
      displayLarge: display(text.displayLarge),
      displayMedium: display(text.displayMedium),
      displaySmall: display(text.displaySmall),
      headlineLarge: display(text.headlineLarge),
      headlineMedium: display(text.headlineMedium),
      headlineSmall: display(text.headlineSmall),
      titleLarge: display(text.titleLarge),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _cream,
      foregroundColor: _ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: tabkhaDisplay,
        fontFamilyFallback: tabkhaDisplayFallback,
        fontSize: 22,
        color: _ink,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    ),
    cardTheme: CardThemeData(
      color: _card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: _line)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        minimumSize: const Size(64, 52),
        textStyle: const TextStyle(fontFamily: tabkhaText, fontFamilyFallback: tabkhaTextFallback, fontWeight: FontWeight.w800, fontSize: 16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontFamily: tabkhaText, fontFamilyFallback: tabkhaTextFallback, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(shape: const StadiumBorder(), side: const BorderSide(color: _line)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _line)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.6)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _card,
      selectedColor: AppColors.primaryColor,
      side: const BorderSide(color: _line),
      shape: const StadiumBorder(),
      labelStyle: const TextStyle(fontFamily: tabkhaText, fontFamilyFallback: tabkhaTextFallback, fontWeight: FontWeight.w700, color: _ink),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _card,
      indicatorColor: const Color(0xFFDDE8D3),
      labelTextStyle: WidgetStateProperty.all(const TextStyle(fontFamily: tabkhaText, fontFamilyFallback: tabkhaTextFallback, fontSize: 12, fontWeight: FontWeight.w700)),
    ),
    navigationRailTheme: const NavigationRailThemeData(backgroundColor: _card, indicatorColor: Color(0xFFDDE8D3)),
    dividerTheme: const DividerThemeData(color: _line),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
