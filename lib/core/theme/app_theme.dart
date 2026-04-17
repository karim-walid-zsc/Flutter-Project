// lib/core/theme/app_theme.dart
// ثيم التطبيق — اللون الأساسي أزرق مائي/سماوي احترافي

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ======== الألوان الأساسية ========
  static const Color primary = Color(0xFF00BCD4); // سماوي
  static const Color primaryDark = Color(0xFF0097A7); // سماوي داكن
  static const Color primaryLight = Color(0xFFE0F7FA); // سماوي فاتح جداً
  static const Color accent = Color(0xFF00ACC1); // تمييز
  static const Color background = Color(0xFFF5FAFB); // خلفية فاتحة
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFB8C00);
  static const Color textPrimary = Color(0xFF1A2B3C);
  static const Color textSecondary = Color(0xFF607D8B);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color cardShadow = Color(0x1A00BCD4);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: accent,
          background: background,
          surface: surface,
          error: error,
        ),
        scaffoldBackgroundColor: background,

        // ======== الخط العربي ========
        textTheme: GoogleFonts.cairoTextTheme().copyWith(
          displayLarge: GoogleFonts.cairo(
              fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary),
          displayMedium: GoogleFonts.cairo(
              fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
          headlineMedium: GoogleFonts.cairo(
              fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
          titleLarge: GoogleFonts.cairo(
              fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: GoogleFonts.cairo(
              fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
          bodyLarge: GoogleFonts.cairo(
              fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary),
          bodyMedium: GoogleFonts.cairo(
              fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
          labelLarge: GoogleFonts.cairo(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
        ),

        // ======== AppBar ========
        appBarTheme: AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.cairo(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),

        // ======== الأزرار ========
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
            textStyle:
                GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: primary, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle:
                GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),

        // ======== حقول الإدخال ========
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: error),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: GoogleFonts.cairo(color: textSecondary, fontSize: 14),
          hintStyle: GoogleFonts.cairo(color: textSecondary, fontSize: 14),
        ),

        // ======== الكروت ========
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFECF0F1)),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        ),

        // ======== SnackBar ========
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentTextStyle: GoogleFonts.cairo(fontSize: 14),
        ),
      );
}
