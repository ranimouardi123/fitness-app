import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales — Coach Ayoub
  static const Color orange       = Color(0xFFE8410A);
  static const Color orangeLight  = Color(0xFFFF5722);
  static const Color orangeDark   = Color(0xFFC1340A);
  static const Color noir         = Color(0xFF1A1A1A);
  static const Color noirCard     = Color(0xFF242424);
  static const Color noirLight    = Color(0xFF2E2E2E);
  static const Color grisTexte    = Color(0xFF9E9E9E);
  static const Color grisClair    = Color(0xFFE8E8E8);
  static const Color blanc        = Color(0xFFFFFFFF);
  static const Color bgPage       = Color(0xFFF5F5F5);
  static const Color success      = Color(0xFF4CAF50);
  static const Color danger       = Color(0xFFE53935);
  static const Color info         = Color(0xFF2196F3);

  // Aliases pour compatibilité
  static const Color primary       = orange;
  static const Color primaryDark   = orangeDark;
  static const Color secondary     = success;
  static const Color accent        = Color(0xFFFFC107);
  static const Color bgLight       = bgPage;
  static const Color surface       = blanc;
  static const Color textPrimary   = noir;
  static const Color textSecondary = grisTexte;
  static const Color border        = Color(0xFFE0E0E0);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: orange, brightness: Brightness.light),
    scaffoldBackgroundColor: bgPage,
    appBarTheme: const AppBarTheme(
      backgroundColor: blanc,
      foregroundColor: noir,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: noir, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.3),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: orange, foregroundColor: blanc,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: orange, minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: orange, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: blanc,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: orange, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
    ),
    cardTheme: CardThemeData(
      color: blanc, elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
    ),
  );
}
