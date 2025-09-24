// app_styles.dart
import 'package:flutter/material.dart';

/// ===== TOKENS =====
class AppColors {
  static const primary = Color(0xFF1976D2);
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

  static const pageBg = Color(0xFFF2F4F7);

  // Texto
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);

  // UI
  static const cardDivider = Color(0xFFE9EEFF);
  static const iconCircle = Color(0xFFEFF2F6);

  // Fondo gris de los fields inactivos (estilo SmartNest)
  static const formFieldBg = Color(0xFFF3F5F8);
}

class AppDims {
  static const radiusLg = 26.0; // pill
  static const radiusMd = 14.0;
  static const padInputV = 14.0;
  static const padInputH = 16.0;
}

/// ===== THEME ÚNICO (Material 2) =====
class AppTheme {
  static ThemeData build() {
    final base = ThemeData.light(useMaterial3: false);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.pageBg,
      primaryColor: AppColors.primary,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.navyBottom,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navyTop,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      iconTheme: const IconThemeData(color: AppColors.navyBottom),
      dividerColor: AppColors.cardDivider,

      // Tipografías
      textTheme: base.textTheme.copyWith(
        titleLarge: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
        bodyMedium: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        bodySmall: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),

      // Botones que ya usas
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white54),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(AppColors.navyBottom),
        trackColor: MaterialStateProperty.all(
          AppColors.navyBottom.withOpacity(0.25),
        ),
      ),

      // === Inputs: pill gris, sin líneas, sin bordes visibles ===
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: AppColors.formFieldBg,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppDims.padInputV,
          horizontal: AppDims.padInputH,
        ),
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(AppDims.radiusLg),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(AppDims.radiusLg),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(AppDims.radiusLg),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(AppDims.radiusLg),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(AppDims.radiusLg),
        ),
      ),
    );
  }
}
