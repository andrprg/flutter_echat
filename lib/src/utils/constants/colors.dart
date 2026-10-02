import 'package:flutter/material.dart';

/// Палитра E-Chat из Figma Design Tokens.
///
/// Источник: [Chatting App UI Kit | E-Chat](https://www.figma.com/design/Do69JP5vfRzBNw3OO2jRHH/Chatting-App-UI-Kit-Design-_-E-Chat-_-Figma--Community-?node-id=21-122)
/// (канвас Light Mode + Dark Mode).
class TColors {
  TColors._();

  static const Color colorFFE8F0F9 = Color(0xFFE8F0F9);
  static const Color colorFF4484CD = Color(0xFF4484CD);
  static const Color colorFF1565C0 = Color(0xFF1565C0);
  static const Color colorFF092A51 = Color(0xFF092A51);

  static const Color colorFFECF9FF = Color(0xFFECF9FF);
  static const Color colorFFC4EDFF = Color(0xFFC4EDFF);
  static const Color colorFFA7E4FF = Color(0xFFA7E4FF);
  static const Color colorFF7FD7FF = Color(0xFF7FD7FF);
  static const Color colorFF66D0FF = Color(0xFF66D0FF);
  static const Color colorFF40C4FF = Color(0xFF40C4FF);
  static const Color colorFF3AB2E8 = Color(0xFF3AB2E8);
  static const Color colorFF1B526B = Color(0xFF1B526B);

  static const Color colorFFFFFFFF = Color(0xFFFFFFFF);
  static const Color colorFF292929 = Color(0xFF292929);
  static const Color colorFF2C2D3A = Color(0xFF2C2D3A);
  static const Color colorFF0D1217 = Color(0xFF0D1217);
  static const Color colorFF393A4C = Color(0xFF393A4C);
  static const Color colorFF4A4B62 = Color(0xFF4A4B62);
  static const Color colorFF686A8A = Color(0xFF686A8A);
  static const Color colorFF8688A1 = Color(0xFF8688A1);
  static const Color colorFF4C555F = Color(0xFF4C555F);
  static const Color colorFF9A9BB1 = Color(0xFF9A9BB1);
  static const Color colorFFD0D1DB = Color(0xFFD0D1DB);
  static const Color colorFFF0F0F3 = Color(0xFFF0F0F3);
  static const Color colorFFE9EAEB = Color(0xFFE9EAEB);

  static const Color colorFFE7E7E7 = Color(0xFFE7E7E7);
  static const Color colorFFD9D9D9 = Color(0xFFD9D9D9);

  static const Color colorFFFEECEB = Color(0xFFFEECEB);
  static const Color colorFFF6695E = Color(0xFFF6695E);
  static const Color colorFFF44336 = Color(0xFFF44336);

  static const Color colorFF33D375 = Color(0xFF33D375);
  static const Color colorFF00C853 = Color(0xFF00C853);
  static const Color colorFF13C296 = Color(0xFF13C296);

  static const Color colorFFFFD233 = Color(0xFFFFD233);

  static const Color colorFF1A47B8 = Color(0xFF1A47B8);

  static const Color colorFFFF6347 = Color(0xFFFF6347);

  static const LinearGradient gradientBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFF0F4888)],
  );

  static const LinearGradient gradientLightBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF40C4FF), Color(0xFF03A9F4)],
  );

  static const List<BoxShadow> shadow2 = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static ColorScheme get lightColorScheme => const ColorScheme.light(
        primary: colorFF1565C0,
        onPrimary: colorFFFFFFFF,
        primaryContainer: colorFFE8F0F9,
        onPrimaryContainer: colorFF092A51,
        secondary: colorFF40C4FF,
        onSecondary: colorFFFFFFFF,
        secondaryContainer: colorFFECF9FF,
        onSecondaryContainer: colorFF1B526B,
        surface: colorFFFFFFFF,
        onSurface: colorFF2C2D3A,
        onSurfaceVariant: colorFF8688A1,
        outline: colorFFD0D1DB,
        outlineVariant: colorFFF0F0F3,
        error: colorFFF44336,
        onError: colorFFFFFFFF,
        errorContainer: colorFFFEECEB,
        onErrorContainer: colorFFF44336,
      );

  static ColorScheme get darkColorScheme => const ColorScheme.dark(
        primary: colorFF40C4FF,
        onPrimary: colorFF0D1217,
        primaryContainer: colorFF092A51,
        onPrimaryContainer: colorFFC4EDFF,
        secondary: colorFF66D0FF,
        onSecondary: colorFF0D1217,
        secondaryContainer: colorFF1B526B,
        onSecondaryContainer: colorFFC4EDFF,
        surface: colorFF0D1217,
        onSurface: colorFFFFFFFF,
        onSurfaceVariant: colorFF9A9BB1,
        outline: colorFF4A4B62,
        outlineVariant: colorFF393A4C,
        error: colorFFF6695E,
        onError: colorFF0D1217,
        errorContainer: Color(0xFF3D1F1D),
        onErrorContainer: colorFFF6695E,
      );
}
