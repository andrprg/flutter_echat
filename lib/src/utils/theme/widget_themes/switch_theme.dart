import 'package:flutter/material.dart';

import '../../constants/colors.dart';

/// Тема Switch — акцент Light Blue `#40C4FF`.
class TSwitchTheme {
  TSwitchTheme._();

  static SwitchThemeData get lightSwitchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TColors.colorFFFFFFFF;
          }
          return TColors.colorFFD0D1DB;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TColors.colorFF40C4FF;
          }
          return TColors.colorFF9A9BB1;
        }),
      );

  static SwitchThemeData get darkSwitchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TColors.colorFFFFFFFF;
          }
          return TColors.colorFF8688A1;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TColors.colorFF40C4FF;
          }
          return TColors.colorFF4A4B62;
        }),
      );
}
