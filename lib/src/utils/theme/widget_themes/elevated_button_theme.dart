import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/// Тема ElevatedButton — primary CTA Light Blue `#40C4FF`.
class TElevatedButtonTheme {
  TElevatedButtonTheme._();

  static final ElevatedButtonThemeData lightElevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: TColors.colorFFFFFFFF,
      backgroundColor: TColors.colorFF40C4FF,
      disabledForegroundColor: TColors.colorFF9A9BB1,
      disabledBackgroundColor: TColors.colorFFD0D1DB,
      minimumSize: const Size(double.infinity, TSizes.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.buttonRadius),
      ),
    ),
  );

  static final ElevatedButtonThemeData darkElevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: TColors.colorFF0D1217,
      backgroundColor: TColors.colorFF40C4FF,
      disabledForegroundColor: TColors.colorFF8688A1,
      disabledBackgroundColor: TColors.colorFF393A4C,
      minimumSize: const Size(double.infinity, TSizes.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.buttonRadius),
      ),
    ),
  );
}
