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
      foregroundColor: TColors.white,
      backgroundColor: TColors.lightBlue500,
      disabledForegroundColor: TColors.neutral300,
      disabledBackgroundColor: TColors.neutral100,
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
      foregroundColor: TColors.neutral900Dark,
      backgroundColor: TColors.lightBlue500,
      disabledForegroundColor: TColors.neutral400,
      disabledBackgroundColor: TColors.neutral800,
      minimumSize: const Size(double.infinity, TSizes.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.buttonRadius),
      ),
    ),
  );
}
