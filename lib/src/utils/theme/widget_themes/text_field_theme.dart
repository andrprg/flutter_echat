import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/// Тема InputDecoration / TextFormField (Figma E-Chat).
class TTextFormFieldTheme {
  TTextFormFieldTheme._();

  static InputDecorationTheme get lightInputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: TColors.colorFFFFFFFF,
      hintStyle: const TextStyle(color: TColors.colorFF9A9BB1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.colorFFD0D1DB),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.colorFFD0D1DB),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.colorFF40C4FF, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.colorFFF44336),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.colorFFF44336, width: 2),
      ),
    );
  }

  static InputDecorationTheme get darkInputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: TColors.colorFF393A4C,
      hintStyle: const TextStyle(color: TColors.colorFF8688A1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.colorFF4A4B62),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.colorFF4A4B62),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.colorFF40C4FF, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.colorFFF6695E),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.colorFFF6695E, width: 2),
      ),
    );
  }
}
