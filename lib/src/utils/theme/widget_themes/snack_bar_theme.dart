import 'package:flutter/material.dart';

import '../../constants/colors.dart';

/// Тема SnackBar (Figma E-Chat).
class TSnackBarTheme {
  TSnackBarTheme._();

  static const SnackBarThemeData lightSnackBarTheme = SnackBarThemeData(
    backgroundColor: TColors.neutral900,
    contentTextStyle: TextStyle(color: TColors.white),
    behavior: SnackBarBehavior.floating,
  );

  static const SnackBarThemeData darkSnackBarTheme = SnackBarThemeData(
    backgroundColor: TColors.neutral800,
    contentTextStyle: TextStyle(color: TColors.white),
    behavior: SnackBarBehavior.floating,
  );
}
