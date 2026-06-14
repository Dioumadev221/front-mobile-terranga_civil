import 'package:flutter/material.dart';

/// Palette de couleurs officielle TERANGA CIVIL.
///
/// Refonte « lassfrontend » (mode clair) : base **navy** structurelle
/// (`#0D1F3C → #162847`), accent **ambre** (`#E8A838`), surfaces claires en
/// couches (`layer-0 #F4F6F9` / blanc), sémantique success/warning/error/info.
/// À utiliser PARTOUT — jamais de couleur codée en dur ailleurs.
abstract class AppColors {
  AppColors._();

  // ── Couleurs principales (navy structurel) ───────────────────────────────
  static const Color primary      = Color(0xFF0D1F3C); // Navy (sidebar/headers)
  static const Color primaryLight = Color(0xFF162847); // Navy clair (dégradés)
  static const Color primaryDark  = Color(0xFF0A1730); // Navy profond
  // L'accent du design est l'ambre — `secondary` porte cet accent.
  static const Color secondary    = Color(0xFFE8A838); // Ambre (accent / CTA)
  static const Color secondaryDark = Color(0xFFCE9220); // Ambre foncé

  // ── Or / ambre (baobab) ──────────────────────────────────────────────────
  static const Color gold      = Color(0xFFE8A838);
  static const Color goldLight = Color(0xFFFBF1DC); // ambre-dim clair

  // ── Fond & surfaces (couches claires) ────────────────────────────────────
  static const Color background = Color(0xFFF4F6F9); // layer-0
  static const Color surface    = Color(0xFFFFFFFF); // layer-1
  static const Color surfaceElevated = Color(0xFFE8ECF4); // layer-2

  // ── Textes ───────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0D1F3C); // text-100
  static const Color textSecondary = Color(0xFF526080); // text-300
  static const Color textHint      = Color(0xFF8B9FC2); // text-400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Statuts dossiers ─────────────────────────────────────────────────────
  static const Color statusAmber = Color(0xFFE88C38); // warning
  static const Color statusRed   = Color(0xFFC0392B); // error
  static const Color statusGreen = Color(0xFF2D9E6B); // success
  static const Color statusBlue  = Color(0xFF3B82F6); // info

  // ── Backgrounds statuts (versions « dim » claires) ───────────────────────
  static const Color statusAmberLight = Color(0xFFFBE9D6);
  static const Color statusRedLight   = Color(0xFFF6E3E1);
  static const Color statusGreenLight = Color(0xFFE2F3EB);
  static const Color statusBlueLight  = Color(0xFFE6EFFD);

  // ── Bordures & séparateurs ───────────────────────────────────────────────
  static const Color border      = Color(0xFFE0E7F0); // border-subtle
  static const Color borderFocus = Color(0xFFE8A838); // ring ambre
  static const Color divider     = Color(0xFFE8ECF4);

  // ── États boutons ────────────────────────────────────────────────────────
  static const Color buttonDisabledBg   = Color(0xFFD8E0EF); // layer-3
  static const Color buttonDisabledText = Color(0xFF8B9FC2);

  // ── Erreur / validation inline ───────────────────────────────────────────
  static const Color error      = Color(0xFFC0392B);
  static const Color errorLight = Color(0xFFF6E3E1);

  // ── Succès ───────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF2D9E6B);
  static const Color successLight = Color(0xFFE2F3EB);

  // ── Overlay & ombres (teinte navy) ───────────────────────────────────────
  static const Color overlay = Color(0x800D1F3C);
  static const Color shadow  = Color(0x140D1F3C);
  static const Color shadowStrong = Color(0x240D1F3C);

  // ── Transparent ──────────────────────────────────────────────────────────
  static const Color transparent = Colors.transparent;

  // ── Dégradés ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D1F3C), Color(0xFF162847)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [Color(0xFF0D1F3C), Color(0xFF142544)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFE8A838), Color(0xFFCE9220)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE8A838), Color(0xFFF0BC5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF0D1F3C), Color(0xFF142544), Color(0xFF162847)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );
}
