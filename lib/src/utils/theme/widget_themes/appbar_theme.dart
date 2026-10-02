import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/colors.dart';

/// Тема AppBar (Figma E-Chat).
class TAppBarTheme {
  TAppBarTheme._();

  static const AppBarTheme lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: TColors.colorFFFFFFFF,
    foregroundColor: TColors.colorFF2C2D3A,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  );

  static const AppBarTheme darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: TColors.colorFF0D1217,
    foregroundColor: TColors.colorFFFFFFFF,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  );
}
