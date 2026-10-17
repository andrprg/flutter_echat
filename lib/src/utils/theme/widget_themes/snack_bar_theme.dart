import 'package:flutter/material.dart';

import '../../constants/colors.dart';

/// Тема SnackBar / toast ошибки (макет design_kimi `.toast`).
///
/// Light: фон `#FFFFFF`, текст `neutral900`.
/// Dark: фон `neutral800` (`--surface-2`), текст `#FFFFFF`.
/// Типографика: 14 / SemiBold / line-height 1.35.
class TSnackBarTheme {
  TSnackBarTheme._();

  static const SnackBarThemeData lightSnackBarTheme = SnackBarThemeData(
    backgroundColor: TColors.white,
    contentTextStyle: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: TColors.neutral900,
    ),
    closeIconColor: TColors.neutral400,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
  );

  static const SnackBarThemeData darkSnackBarTheme = SnackBarThemeData(
    backgroundColor: TColors.neutral800,
    contentTextStyle: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: TColors.white,
    ),
    closeIconColor: TColors.neutral300,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
  );
}
