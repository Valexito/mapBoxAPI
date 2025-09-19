import 'package:flutter/material.dart';

class AppTheme {
  // Paleta centralizada
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);
  static const pageBg = Color(0xFFF2F4F7);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);

  static ThemeData build() {
    final base = ThemeData.light(useMaterial3: false);

    return base.copyWith(
      scaffoldBackgroundColor: pageBg,
      primaryColor: navyBottom,
      colorScheme: base.colorScheme.copyWith(
        primary: navyBottom,
        secondary: navyTop,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: navyTop,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      iconTheme: const IconThemeData(color: navyBottom),
      dividerColor: const Color(0xFFE9EEFF),
      // Tipografía consistente con tus widgets MyText
      textTheme: base.textTheme.copyWith(
        titleLarge: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xFF1976D2), // coherente con MyText.title
          letterSpacing: 1.2,
        ),
        bodyMedium: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: textPrimary,
        ),
        bodySmall: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 13,
          color: textSecondary,
        ),
      ),
      // Botones (por si no usas MyButton en algún lado)
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
        thumbColor: WidgetStateProperty.all(navyBottom),
        trackColor: WidgetStateProperty.all(navyBottom.withOpacity(0.25)),
      ),
    );
  }
}
