import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../constants/colors.dart';

/// Тема кастомного [TBottomNavBar] (Figma Navbar `58:2793`).
///
/// Подключается через [ThemeData.extensions]; виджет читает токены
/// через [TBottomNavigatorBarTheme.of], а не через M3 [NavigationBarThemeData]
/// (градиентная плитка 76×70 туда не укладывается).
@immutable
class TBottomNavigatorBarTheme
    extends ThemeExtension<TBottomNavigatorBarTheme> {
  const TBottomNavigatorBarTheme({
    required this.backgroundColor,
    required this.inactiveColor,
    required this.selectedForegroundColor,
    required this.selectedGradient,
    required this.height,
    required this.borderRadius,
    required this.shadows,
    required this.tileWidth,
    required this.tileHeight,
    required this.tileBorderRadius,
    required this.labelStyle,
  });

  /// Фон бара.
  final Color backgroundColor;

  /// Цвет иконки и лейбла неактивной вкладки.
  final Color inactiveColor;

  /// Цвет иконки и лейбла на активной плитке.
  final Color selectedForegroundColor;

  /// Градиент активной плитки.
  final Gradient selectedGradient;

  /// Высота контента бара (без SafeArea).
  final double height;

  /// Радиус верхних углов бара.
  final double borderRadius;

  /// Тень бара (Figma: `0px -4px 20px rgba(13, 10, 44, 0.06)`).
  final List<BoxShadow> shadows;

  /// Ширина плитки пункта (active и hit-area).
  final double tileWidth;

  /// Высота плитки пункта.
  final double tileHeight;

  /// Радиус активной плитки.
  final double tileBorderRadius;

  /// Стиль лейбла вкладки (цвет задаётся виджетом).
  final TextStyle labelStyle;

  static const Color _navbarShadow = Color(0x0F0D0A2C);

  static const List<BoxShadow> _barShadows = [
    BoxShadow(
      color: _navbarShadow,
      offset: Offset(0, -4),
      blurRadius: 20,
    ),
  ];

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 14 / 12,
  );

  /// Светлая тема бара.
  static const TBottomNavigatorBarTheme light = TBottomNavigatorBarTheme(
    backgroundColor: TColors.white,
    inactiveColor: TColors.neutral300,
    selectedForegroundColor: TColors.white,
    selectedGradient: TColors.gradientLightBlue,
    height: 100,
    borderRadius: 12,
    shadows: _barShadows,
    tileWidth: 76,
    tileHeight: 70,
    tileBorderRadius: 12,
    labelStyle: _labelStyle,
  );

  /// Тёмная тема бара.
  static const TBottomNavigatorBarTheme dark = TBottomNavigatorBarTheme(
    backgroundColor: TColors.neutral800,
    inactiveColor: TColors.neutral300,
    selectedForegroundColor: TColors.white,
    selectedGradient: TColors.gradientLightBlue,
    height: 100,
    borderRadius: 12,
    shadows: _barShadows,
    tileWidth: 76,
    tileHeight: 70,
    tileBorderRadius: 12,
    labelStyle: _labelStyle,
  );

  /// Токены бара из текущего [Theme].
  static TBottomNavigatorBarTheme of(BuildContext context) {
    final theme = Theme.of(context).extension<TBottomNavigatorBarTheme>();
    assert(
      theme != null,
      'TBottomNavigatorBarTheme не зарегистрирован в ThemeData.extensions '
      '(см. TAppTheme).',
    );
    return theme!;
  }

  @override
  TBottomNavigatorBarTheme copyWith({
    Color? backgroundColor,
    Color? inactiveColor,
    Color? selectedForegroundColor,
    Gradient? selectedGradient,
    double? height,
    double? borderRadius,
    List<BoxShadow>? shadows,
    double? tileWidth,
    double? tileHeight,
    double? tileBorderRadius,
    TextStyle? labelStyle,
  }) {
    return TBottomNavigatorBarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      selectedForegroundColor:
          selectedForegroundColor ?? this.selectedForegroundColor,
      selectedGradient: selectedGradient ?? this.selectedGradient,
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
      shadows: shadows ?? this.shadows,
      tileWidth: tileWidth ?? this.tileWidth,
      tileHeight: tileHeight ?? this.tileHeight,
      tileBorderRadius: tileBorderRadius ?? this.tileBorderRadius,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }

  @override
  TBottomNavigatorBarTheme lerp(
    ThemeExtension<TBottomNavigatorBarTheme>? other,
    double t,
  ) {
    if (other is! TBottomNavigatorBarTheme) return this;
    return TBottomNavigatorBarTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      inactiveColor: Color.lerp(inactiveColor, other.inactiveColor, t)!,
      selectedForegroundColor: Color.lerp(
        selectedForegroundColor,
        other.selectedForegroundColor,
        t,
      )!,
      selectedGradient:
          Gradient.lerp(selectedGradient, other.selectedGradient, t)!,
      height: lerpDouble(height, other.height, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      shadows: BoxShadow.lerpList(shadows, other.shadows, t)!,
      tileWidth: lerpDouble(tileWidth, other.tileWidth, t)!,
      tileHeight: lerpDouble(tileHeight, other.tileHeight, t)!,
      tileBorderRadius:
          lerpDouble(tileBorderRadius, other.tileBorderRadius, t)!,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t)!,
    );
  }
}
