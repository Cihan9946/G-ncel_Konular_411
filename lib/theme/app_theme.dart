import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const deepOcean = Color(0xFF0A1628);
  static const oceanBlue = Color(0xFF1B4D7A);
  static const reefTeal = Color(0xFF2DD4BF);
  static const coral = Color(0xFFFF6B6B);
  static const sand = Color(0xFFFFE66D);
  static const bubble = Color(0xFFB8E6FF);
  static const panel = Color(0xE6122538);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.reefTeal,
      secondary: AppColors.sand,
      surface: AppColors.deepOcean,
      onPrimary: AppColors.deepOcean,
      onSurface: AppColors.bubble,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.deepOcean,
    textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
      bodyColor: AppColors.bubble,
      displayColor: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.reefTeal,
        foregroundColor: AppColors.deepOcean,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.panel,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}
