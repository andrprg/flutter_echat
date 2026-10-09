import 'package:flutter/material.dart';

import '../../constants/colors.dart';

/// Тема BottomNavigationBar (Figma E-Chat).
class TBottomNavigatorBarTheme {
  TBottomNavigatorBarTheme._();

  static const BottomNavigationBarThemeData lightBottomNavigatorBarTheme =
      BottomNavigationBarThemeData(
    backgroundColor: TColors.white,
    selectedItemColor: TColors.blue500,
    unselectedItemColor: TColors.neutral400,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );

  static const BottomNavigationBarThemeData darkBottomNavigatorBarTheme =
      BottomNavigationBarThemeData(
    backgroundColor: TColors.neutral900Dark,
    selectedItemColor: TColors.lightBlue500,
    unselectedItemColor: TColors.neutral400,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );
}
