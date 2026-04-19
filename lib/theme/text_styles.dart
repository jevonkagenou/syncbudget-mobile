import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  // Headlines using Manrope
  static TextStyle headlineLarge = GoogleFonts.manrope(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral,
  );

  static TextStyle headlineMedium = GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral,
  );
  
  static TextStyle headlineSmall = GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral,
  );

  // Body & Labels using Inter
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.neutralLight,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.neutralLight,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.neutralLight,
  );

  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral,
  );
  
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral,
  );
  
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral,
  );
}
