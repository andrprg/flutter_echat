import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/colors.dart';

/// Тема AppBar (Figma E-Chat).
class TAppBarTheme {
  TAppBarTheme._();

  static const AppBarTheme lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: TColors.white,
    foregroundColor: TColors.neutral900,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  );

  static const AppBarTheme darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: TColors.neutral900Dark,
    foregroundColor: TColors.white,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  );
}
