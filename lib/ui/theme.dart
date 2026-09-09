import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solvoca/ui/tokens.dart';

ThemeData buildSolvocaTheme() {
  const text = TextTheme(
    headlineMedium: TextStyle(
      fontFamily: SolvocaTokens.fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: SolvocaTokens.textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: SolvocaTokens.fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: SolvocaTokens.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: SolvocaTokens.fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: SolvocaTokens.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: SolvocaTokens.fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: SolvocaTokens.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: SolvocaTokens.fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: SolvocaTokens.textSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: SolvocaTokens.fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: SolvocaTokens.textSecondary,
    ),
  );

  const scheme = ColorScheme.light(
    primary: SolvocaTokens.accent,
    onPrimary: SolvocaTokens.onAccent,
    secondary: SolvocaTokens.accentSoft,
    onSecondary: SolvocaTokens.textPrimary,
    surface: SolvocaTokens.surface,
    onSurface: SolvocaTokens.textPrimary,
    error: Color(0xFFB54A3C),
    onError: SolvocaTokens.onAccent,
    outline: SolvocaTokens.border,
    outlineVariant: SolvocaTokens.accentSoft,
    surfaceContainerLowest: SolvocaTokens.background,
    surfaceContainerLow: SolvocaTokens.surface,
    surfaceContainer: SolvocaTokens.surface,
    surfaceContainerHigh: SolvocaTokens.surface,
    surfaceContainerHighest: SolvocaTokens.surface,
  );

  final radius14 = BorderRadius.circular(SolvocaTokens.radiusButton);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: SolvocaTokens.fontFamily,
    colorScheme: scheme,
    scaffoldBackgroundColor: SolvocaTokens.background,
    canvasColor: SolvocaTokens.background,
    textTheme: text,
    iconTheme: const IconThemeData(color: SolvocaTokens.textPrimary),
    appBarTheme: const AppBarTheme(
      backgroundColor: SolvocaTokens.background,
      foregroundColor: SolvocaTokens.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: SolvocaTokens.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: SolvocaTokens.textPrimary,
      ),
      iconTheme: IconThemeData(color: SolvocaTokens.textPrimary),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: SolvocaTokens.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SolvocaTokens.radiusDialog),
      ),
      titleTextStyle: text.titleLarge,
      contentTextStyle: text.bodyLarge,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: SolvocaTokens.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SolvocaTokens.radiusSheet),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: SolvocaTokens.textPrimary,
      contentTextStyle: text.bodyMedium?.copyWith(
        color: SolvocaTokens.onAccent,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: radius14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SolvocaTokens.surface,
      labelStyle: text.bodyMedium,
      enabledBorder: OutlineInputBorder(
        borderRadius: radius14,
        borderSide: const BorderSide(color: SolvocaTokens.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius14,
        borderSide: const BorderSide(color: SolvocaTokens.accent, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: radius14,
        borderSide: const BorderSide(color: SolvocaTokens.border),
      ),
    ),
    dividerColor: SolvocaTokens.border,
    splashColor: SolvocaTokens.accent.withValues(alpha: 0.08),
    highlightColor: SolvocaTokens.accent.withValues(alpha: 0.04),
  );
}
