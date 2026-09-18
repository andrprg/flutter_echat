import 'package:flutter/material.dart';
import 'package:flutter_echat/src/utils/theme/widget_themes/appbar_theme.dart';
import 'package:flutter_echat/src/utils/theme/widget_themes/bottom_navigator_bar_theme.dart';
import 'package:flutter_echat/src/utils/theme/widget_themes/elevated_button_theme.dart';
import 'package:flutter_echat/src/utils/theme/widget_themes/snack_bar_theme.dart';
import 'package:flutter_echat/src/utils/theme/widget_themes/switch_theme.dart';
import 'package:flutter_echat/src/utils/theme/widget_themes/tabbar_theme.dart';
import 'package:flutter_echat/src/utils/theme/widget_themes/text_field_theme.dart';
import 'package:flutter_echat/src/utils/theme/widget_themes/text_theme.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/colors.dart';

/// Центральная конфигурация светлой и тёмной темы (Figma E-Chat).
class TAppTheme {
  TAppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.roboto().fontFamily,
      brightness: Brightness.light,
      colorScheme: TColors.lightColorScheme,
      scaffoldBackgroundColor: TColors.white,
      bottomNavigationBarTheme:
          TBottomNavigatorBarTheme.lightBottomNavigatorBarTheme,
      inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
      elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
      textTheme: TTextTheme.lightTextTheme,
      appBarTheme: TAppBarTheme.lightAppBarTheme,
      switchTheme: TSwitchTheme.lightSwitchTheme,
      snackBarTheme: TSnackBarTheme.lightSnackBarTheme,
      tabBarTheme: TTabBarTheme.lightTabBarTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.roboto().fontFamily,
      brightness: Brightness.dark,
      colorScheme: TColors.darkColorScheme,
      scaffoldBackgroundColor: TColors.neutral900Dark,
      bottomNavigationBarTheme:
          TBottomNavigatorBarTheme.darkBottomNavigatorBarTheme,
      inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
      elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
      textTheme: TTextTheme.darkTextTheme,
      appBarTheme: TAppBarTheme.darkAppBarTheme,
      switchTheme: TSwitchTheme.darkSwitchTheme,
      snackBarTheme: TSnackBarTheme.darkSnackBarTheme,
      tabBarTheme: TTabBarTheme.darkTabBarTheme,
    );
  }
}
