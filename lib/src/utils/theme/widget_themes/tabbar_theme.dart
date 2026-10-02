import 'package:flutter/material.dart';

import '../../constants/colors.dart';

/// Тема TabBar.
class TTabBarTheme {
  TTabBarTheme._();

  static const TabBarThemeData lightTabBarTheme = TabBarThemeData(
    labelColor: TColors.colorFF1565C0,
    unselectedLabelColor: TColors.colorFF8688A1,
    indicatorColor: TColors.colorFF1565C0,
  );

  static const TabBarThemeData darkTabBarTheme = TabBarThemeData(
    labelColor: TColors.colorFF40C4FF,
    unselectedLabelColor: TColors.colorFF8688A1,
    indicatorColor: TColors.colorFF40C4FF,
  );
}
