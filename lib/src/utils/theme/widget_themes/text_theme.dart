import 'package:flutter/material.dart';

import '../../constants/colors.dart';

/// Тема типографики Roboto (Figma E-Chat).
///
/// Начертания из макета: Regular (400), SemiBold (600), Bold (700).
/// Шрифт подключён локально через `pubspec.yaml` (`family: Roboto`).
class TTextTheme {
  TTextTheme._();

  static const String _fontFamily = 'Roboto';

  static const TextTheme lightTextTheme = TextTheme(
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: TColors.neutral900,
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: TColors.neutral900,
    ),
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: TColors.neutral900,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: TColors.neutral900,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: TColors.neutral500,
    ),
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: TColors.white,
    ),
  );

  static const TextTheme darkTextTheme = TextTheme(
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: TColors.white,
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: TColors.white,
    ),
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: TColors.white,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: TColors.white,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: TColors.neutral300,
    ),
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: TColors.neutral900Dark,
    ),
  );
}
