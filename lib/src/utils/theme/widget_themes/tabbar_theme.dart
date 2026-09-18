import 'package:flutter/material.dart';

import '../../constants/colors.dart';

/// Тема TabBar.
class TTabBarTheme {
  TTabBarTheme._();

  static const TabBarThemeData lightTabBarTheme = TabBarThemeData(
    labelColor: TColors.blue500,
    unselectedLabelColor: TColors.neutral400,
    indicatorColor: TColors.blue500,
  );

  static const TabBarThemeData darkTabBarTheme = TabBarThemeData(
    labelColor: TColors.lightBlue500,
    unselectedLabelColor: TColors.neutral400,
    indicatorColor: TColors.lightBlue500,
  );
}
