import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Style 2 — Colorful Custom (팬덤 감성)
/// 크림/피치 배경 + 코랄 · 옐로우 · 민트 · 스카이 블루 포인트
class AppColors {
  static const cream = Color(0xFFFFF7F0);
  static const creamDeep = Color(0xFFFFEFE3);
  static const peach = Color(0xFFFFE3D3);
  static const coral = Color(0xFFFF6F61);
  static const coralDeep = Color(0xFFE8503C);
  static const yellow = Color(0xFFFFC845);
  static const yellowSoft = Color(0xFFFFF0C9);
  static const mint = Color(0xFF41CFAC);
  static const mintSoft = Color(0xFFDDF7EF);
  static const sky = Color(0xFF54B6F0);
  static const skySoft = Color(0xFFDDF0FD);
  static const lilac = Color(0xFFA98BF5);
  static const lilacSoft = Color(0xFFEDE5FF);
  static const ink = Color(0xFF3B2F2B);
  static const inkSoft = Color(0xFF6F5D55);
  static const muted = Color(0xFF9C8A81);
  static const line = Color(0xFFF1E3D7);
  static const white = Color(0xFFFFFFFF);

  static const categories = <String, Color>{
    '브이로그': coral,
    '게임': sky,
    'Q&A': lilac,
    '챌린지': yellow,
    '먹방': mint,
    '라이브': coralDeep,
    '음악': lilac,
    '일상': mint,
  };

  static Color categoryColor(String name) => categories[name] ?? coral;

  static Color categorySoft(String name) {
    switch (name) {
      case '브이로그':
        return const Color(0xFFFFE1DC);
      case '게임':
        return skySoft;
      case 'Q&A':
        return lilacSoft;
      case '챌린지':
        return yellowSoft;
      case '먹방':
      case '일상':
        return mintSoft;
      default:
        return const Color(0xFFFFE1DC);
    }
  }
}

class AppTheme {
  static ThemeData build() {
    final baseText = GoogleFonts.notoSansKrTextTheme();
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.coral,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.coral,
          secondary: AppColors.yellow,
          tertiary: AppColors.mint,
          surface: AppColors.white,
          onSurface: AppColors.ink,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: baseText.copyWith(
        displaySmall: baseText.displaySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.ink,
          letterSpacing: -1.2,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.ink,
          letterSpacing: -0.9,
        ),
        headlineSmall: baseText.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          letterSpacing: -0.6,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          letterSpacing: -0.4,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          color: AppColors.inkSoft,
          height: 1.5,
        ),
        bodySmall: baseText.bodySmall?.copyWith(
          color: AppColors.muted,
          height: 1.4,
        ),
        labelLarge: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.creamDeep,
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.coral, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.coral,
        side: const BorderSide(color: AppColors.line),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.inkSoft,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

class AppShadows {
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: AppColors.coral.withValues(alpha: 0.07),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> tinted(Color c) => [
    BoxShadow(
      color: c.withValues(alpha: 0.28),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
