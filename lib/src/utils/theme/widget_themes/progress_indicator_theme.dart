import 'package:flutter/material.dart';

import '../../constants/colors.dart';

/// Тема [CircularProgressIndicator] / [LinearProgressIndicator] (Figma E-Chat).
class TProgressIndicatorTheme {
  TProgressIndicatorTheme._();

  /// Толщина кольца на CTA ([TButton.isLoading]).
  static const double buttonStrokeWidth = 2.5;

  /// Светлая тема: индикатор на surface / нейтральном фоне.
  static final ProgressIndicatorThemeData light = const ProgressIndicatorThemeData(
    color: TColors.lightBlue500,
    circularTrackColor: TColors.neutral100,
  );

  /// Тёмная тема: индикатор на surface / нейтральном фоне.
  static final ProgressIndicatorThemeData dark = const ProgressIndicatorThemeData(
    color: TColors.lightBlue400,
    circularTrackColor: TColors.neutral800,
  );

  /// На цветном фоне CTA (градиент / danger): светлое кольцо.
  static final ProgressIndicatorThemeData onPrimary = ProgressIndicatorThemeData(
    color: TColors.white,
    circularTrackColor: TColors.white.withValues(alpha: 0.35),
  );
}
