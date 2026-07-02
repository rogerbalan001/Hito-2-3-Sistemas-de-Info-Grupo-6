import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Mejora 2 — Modo oscuro.
/// Colores secundarios de EcoSpot adaptados para fondo oscuro.
class DarkColors {
  DarkColors._();
  static const background  = Color(0xFF0F1A14);
  static const surface     = Color(0xFF1A2820);
  static const surfaceAlt  = Color(0xFF223020);
  static const border      = Color(0x28FFFFFF);
  static const foreground  = Color(0xFFF0F7F4);
  static const muted       = Color(0xFF8FA89B);
  static const inputBg     = Color(0xFF1E2E24);
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.emerald500,
      primary: AppColors.emerald400,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: DarkColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: DarkColors.surface,
      foregroundColor: DarkColors.foreground,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: DarkColors.foreground,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: AppColors.emerald400),
    ),
    cardColor: DarkColors.surface,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DarkColors.inputBg,
      hintStyle: const TextStyle(color: DarkColors.muted),
      labelStyle: const TextStyle(color: DarkColors.muted),
      prefixIconColor: DarkColors.muted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DarkColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DarkColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.emerald500, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.emerald600,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle:
            const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          foregroundColor: AppColors.emerald400),
    ),
    dividerTheme: const DividerThemeData(
        color: DarkColors.border, thickness: 1),
  );
}
