import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design tokens (de styles.css) ───────────────────────────────────────────
class EC {
  // Superficies
  static const bgCanvas    = Color(0xFFF2F0EC);
  static const ink         = Color(0xFF0E0E10);
  static const ink2        = Color(0xFF1B1B1F);
  static const ink3        = Color(0xFF2A2A2F);
  static const card        = Color(0xFFFFFFFF);
  static const cardWarm    = Color(0xFFF7F5F0);
  static const line        = Color(0xFFE5E1D9);
  static const lineSoft    = Color(0xFFEFEBE3);

  // Texto
  static const text        = Color(0xFF0E0E10);
  static const text2       = Color(0xFF4A4742);
  static const text3       = Color(0xFF8A867D);
  static const textOnDark  = Color(0xFFF6F4EE);
  static const textOnDark2 = Color(0xFFB7B3AB);

  // Acento — acid lime
  static const accent      = Color(0xFFD8EE3C);
  static const accentDeep  = Color(0xFFB5C922);

  // Semántico
  static const success     = Color(0xFF1E7A4F);
  static const successSoft = Color(0xFFE3F2EA);
  static const warn        = Color(0xFFB86F00);
  static const warnSoft    = Color(0xFFFAEED8);
  static const error       = Color(0xFFB83A2E);
  static const errorSoft   = Color(0xFFF7E2DE);
}

// ─── Radio helpers ────────────────────────────────────────────────────────────
class ER {
  static const sm   = 8.0;
  static const md   = 14.0;
  static const lg   = 22.0;
  static const xl   = 28.0;
  static const full = 999.0;
}

// ─── Helpers tipografía ───────────────────────────────────────────────────────
class ET {
  static TextStyle sans({
    double size = 15,
    FontWeight weight = FontWeight.w400,
    Color color = EC.text,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.bricolageGrotesque(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing ?? (size >= 26 ? size * -0.04 : size * -0.01),
        height: height,
      );

  static TextStyle mono({
    double size = 15,
    FontWeight weight = FontWeight.w500,
    Color color = EC.text,
    double? letterSpacing,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing ?? size * -0.02,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

// ─── Theme ────────────────────────────────────────────────────────────────────
class EntroTheme {
  static ThemeData build() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: EC.bgCanvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: EC.ink,
        brightness: Brightness.light,
        surface: EC.card,
        primary: EC.ink,
        secondary: EC.accent,
        error: EC.error,
      ),
      textTheme: TextTheme(
        displayLarge:   ET.sans(size: 96, weight: FontWeight.w500),
        headlineLarge:  ET.sans(size: 34, weight: FontWeight.w700),
        headlineMedium: ET.sans(size: 30, weight: FontWeight.w700),
        headlineSmall:  ET.sans(size: 26, weight: FontWeight.w700),
        titleLarge:     ET.sans(size: 22, weight: FontWeight.w700),
        titleMedium:    ET.sans(size: 17, weight: FontWeight.w600),
        titleSmall:     ET.sans(size: 15, weight: FontWeight.w600),
        bodyLarge:      ET.sans(size: 15),
        bodyMedium:     ET.sans(size: 13, color: EC.text2),
        bodySmall:      ET.sans(size: 12, weight: FontWeight.w500, color: EC.text3),
        labelLarge:     ET.sans(size: 11, weight: FontWeight.w600, color: EC.text3, letterSpacing: 0.7),
        labelSmall:     ET.sans(size: 10, weight: FontWeight.w600, color: EC.text3, letterSpacing: 0.8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EC.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ER.md),
          borderSide: const BorderSide(color: EC.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ER.md),
          borderSide: const BorderSide(color: EC.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ER.md),
          borderSide: const BorderSide(color: EC.ink, width: 1.5),
        ),
        hintStyle: ET.sans(size: 15, color: EC.text3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: EC.ink,
          foregroundColor: EC.textOnDark,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ER.lg),
          ),
          textStyle: ET.sans(size: 17, weight: FontWeight.w600, color: EC.textOnDark),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: EC.ink,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: EC.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ER.md),
          ),
          backgroundColor: EC.cardWarm,
          textStyle: ET.sans(size: 15, weight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: EC.bgCanvas,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: ET.sans(size: 15, weight: FontWeight.w600),
        iconTheme: const IconThemeData(color: EC.ink, size: 22),
      ),
    );
  }

  // Mantener compatibilidad con código que llame EntroTheme.light()
  static ThemeData light() => build();
}

// Alias de compatibilidad para código existente
class EntroColors {
  static const bg           = EC.bgCanvas;
  static const surface      = EC.card;
  static const surface2     = EC.cardWarm;
  static const border       = EC.line;
  static const borderStrong = EC.line;
  static const ink          = EC.ink;
  static const ink2         = EC.ink2;
  static const mute         = EC.text2;
  static const mute2        = EC.text3;
  static const success      = EC.success;
  static const successBg    = EC.successSoft;
  static const successInk   = EC.success;
  static const warning      = EC.warn;
  static const warningBg    = EC.warnSoft;
  static const warningInk   = EC.warn;
  static const danger       = EC.error;
  static const dangerBg     = EC.errorSoft;
  static const dangerInk    = EC.error;
  static const infoBg       = Color(0xFFEEF2FF);
  static const neutralPill  = EC.cardWarm;
  static const avatar       = EC.ink;
}
