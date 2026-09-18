import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/// Тема InputDecoration / TextFormField (Figma E-Chat).
class TTextFormFieldTheme {
  TTextFormFieldTheme._();

  static InputDecorationTheme get lightInputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: TColors.white,
      hintStyle: const TextStyle(color: TColors.neutral300),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.neutral100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.neutral100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.lightBlue500, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.error500),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.error500, width: 2),
      ),
    );
  }

  static InputDecorationTheme get darkInputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: TColors.neutral800,
      hintStyle: const TextStyle(color: TColors.neutral400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.neutral700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.neutral700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.lightBlue500, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.error400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        borderSide: const BorderSide(color: TColors.error400, width: 2),
      ),
    );
  }
}
