import 'package:flutter/material.dart';

import '../../constants/colors.dart';

/// Тема Switch — акцент Light Blue `#40C4FF`.
class TSwitchTheme {
  TSwitchTheme._();

  static SwitchThemeData get lightSwitchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TColors.white;
          }
          return TColors.neutral100;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TColors.lightBlue500;
          }
          return TColors.neutral300;
        }),
      );

  static SwitchThemeData get darkSwitchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TColors.white;
          }
          return TColors.neutral400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TColors.lightBlue500;
          }
          return TColors.neutral700;
        }),
      );
}
