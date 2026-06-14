import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Styles typographiques TERANGA CIVIL (design « lassfrontend »).
/// Grands titres en **Playfair Display** (serif), corps en **IBM Plex Sans**.
abstract class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.playfairDisplay(
        fontSize: 32, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, height: 1.2);

  static TextStyle get displayMedium => GoogleFonts.playfairDisplay(
        fontSize: 28, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, height: 1.25);

  static TextStyle get headlineLarge => GoogleFonts.playfairDisplay(
        fontSize: 24, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, height: 1.3);

  static TextStyle get headlineMedium => GoogleFonts.ibmPlexSans(
        fontSize: 20, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, height: 1.35);

  static TextStyle get headlineSmall => GoogleFonts.ibmPlexSans(
        fontSize: 18, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, height: 1.4);

  static TextStyle get appBarTitle => GoogleFonts.ibmPlexSans(
        fontSize: 18, fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary, height: 1.4);

  static TextStyle get bodyLarge => GoogleFonts.ibmPlexSans(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: AppColors.textPrimary, height: 1.5);

  static TextStyle get bodyMedium => GoogleFonts.ibmPlexSans(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: AppColors.textPrimary, height: 1.5);

  static TextStyle get bodySmall => GoogleFonts.ibmPlexSans(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: AppColors.textSecondary, height: 1.5);

  static TextStyle get labelLarge => GoogleFonts.ibmPlexSans(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, height: 1.4);

  static TextStyle get labelMedium => GoogleFonts.ibmPlexSans(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: AppColors.textSecondary, height: 1.4);

  static TextStyle get labelSmall => GoogleFonts.ibmPlexSans(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: AppColors.textSecondary, height: 1.4);

  static TextStyle get buttonPrimary => GoogleFonts.ibmPlexSans(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary, height: 1.4, letterSpacing: 0.3);

  static TextStyle get buttonDisabled => GoogleFonts.ibmPlexSans(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: AppColors.buttonDisabledText, height: 1.4, letterSpacing: 0.3);

  static TextStyle get inputText => GoogleFonts.ibmPlexSans(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: AppColors.textPrimary, height: 1.5);

  static TextStyle get inputLabel => GoogleFonts.ibmPlexSans(
        fontSize: 13, fontWeight: FontWeight.w500,
        color: AppColors.textSecondary, height: 1.4);

  static TextStyle get inputHint => GoogleFonts.ibmPlexSans(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: AppColors.textHint, height: 1.5);

  static TextStyle get inputError => GoogleFonts.ibmPlexSans(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: AppColors.error, height: 1.4);

  static TextStyle get link => GoogleFonts.ibmPlexSans(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: AppColors.secondary, height: 1.5,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.secondary);

  static TextStyle get linkPrimary => GoogleFonts.ibmPlexSans(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: AppColors.primary, height: 1.5,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.primary);

  static TextStyle get badgeText => GoogleFonts.ibmPlexSans(
        fontSize: 11, fontWeight: FontWeight.w600,
        height: 1.2, letterSpacing: 0.3);

  static TextStyle get caption => GoogleFonts.ibmPlexSans(
        fontSize: 11, fontWeight: FontWeight.w400,
        color: AppColors.textSecondary, height: 1.5);

  static TextStyle get tagline => GoogleFonts.ibmPlexSans(
        fontSize: 13, fontWeight: FontWeight.w400,
        color: AppColors.secondary, height: 1.5, letterSpacing: 0.5);

  static TextStyle get navLabel => GoogleFonts.ibmPlexSans(
        fontSize: 10, fontWeight: FontWeight.w500, height: 1.2);

  static TextStyle get otpDigit => GoogleFonts.ibmPlexSans(
        fontSize: 22, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, height: 1.2);

  static TextStyle get amount => GoogleFonts.ibmPlexSans(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: AppColors.primary, height: 1.2);

  static TextStyle get appNameBold => GoogleFonts.playfairDisplay(
        fontSize: 22, fontWeight: FontWeight.w700,
        color: AppColors.primary, height: 1.2, letterSpacing: 1);

  static TextStyle get appNameRegular => GoogleFonts.playfairDisplay(
        fontSize: 22, fontWeight: FontWeight.w400,
        color: AppColors.primary, height: 1.2, letterSpacing: 1);

  static TextStyle withColor(TextStyle base, Color color) =>
      base.copyWith(color: color);
}
