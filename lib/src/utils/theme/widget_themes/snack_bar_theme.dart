import 'package:flutter/material.dart';

import '../../constants/colors.dart';

/// Тема SnackBar (Figma E-Chat).
class TSnackBarTheme {
  TSnackBarTheme._();

  static const SnackBarThemeData lightSnackBarTheme = SnackBarThemeData(
    backgroundColor: TColors.colorFF2C2D3A,
    contentTextStyle: TextStyle(color: TColors.colorFFFFFFFF),
    behavior: SnackBarBehavior.floating,
  );

  static const SnackBarThemeData darkSnackBarTheme = SnackBarThemeData(
    backgroundColor: TColors.colorFF393A4C,
    contentTextStyle: TextStyle(color: TColors.colorFFFFFFFF),
    behavior: SnackBarBehavior.floating,
  );
}
