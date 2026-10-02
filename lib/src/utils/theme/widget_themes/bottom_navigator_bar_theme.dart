import 'package:flutter/material.dart';

import '../../constants/colors.dart';

/// Тема BottomNavigationBar (Figma E-Chat).
class TBottomNavigatorBarTheme {
  TBottomNavigatorBarTheme._();

  static const BottomNavigationBarThemeData lightBottomNavigatorBarTheme =
      BottomNavigationBarThemeData(
    backgroundColor: TColors.colorFFFFFFFF,
    selectedItemColor: TColors.colorFF1565C0,
    unselectedItemColor: TColors.colorFF8688A1,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );

  static const BottomNavigationBarThemeData darkBottomNavigatorBarTheme =
      BottomNavigationBarThemeData(
    backgroundColor: TColors.colorFF0D1217,
    selectedItemColor: TColors.colorFF40C4FF,
    unselectedItemColor: TColors.colorFF8688A1,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );
}
