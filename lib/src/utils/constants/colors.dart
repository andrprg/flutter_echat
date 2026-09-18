import 'package:flutter/material.dart';

/// Палитра E-Chat из Figma Design Tokens.
///
/// Источник: [Chatting App UI Kit | E-Chat](https://www.figma.com/design/Do69JP5vfRzBNw3OO2jRHH/Chatting-App-UI-Kit-Design-_-E-Chat-_-Figma--Community-?node-id=21-122)
/// (канвас Light Mode + Dark Mode).
class TColors {
  TColors._();

  // ─── Brand / Blue ──────────────────────────────────────────────────────────

  static const Color blue50 = Color(0xFFE8F0F9);
  static const Color blue400 = Color(0xFF4484CD);
  static const Color blue500 = Color(0xFF1565C0);
  static const Color blue900 = Color(0xFF092A51);

  // ─── Brand / Light Blue (акцент, кнопки, onboarding) ────────────────────────

  static const Color lightBlue50 = Color(0xFFECF9FF);
  static const Color lightBlue100 = Color(0xFFC4EDFF);
  static const Color lightBlue200 = Color(0xFFA7E4FF);
  static const Color lightBlue300 = Color(0xFF7FD7FF);
  static const Color lightBlue400 = Color(0xFF66D0FF);
  static const Color lightBlue500 = Color(0xFF40C4FF);
  static const Color lightBlue600 = Color(0xFF3AB2E8);
  static const Color lightBlue900 = Color(0xFF1B526B);

  // ─── Neutrals ──────────────────────────────────────────────────────────────

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF292929);

  /// Light mode — основной текст / иконки.
  static const Color neutral900 = Color(0xFF2C2D3A);

  /// Dark mode — фон экранов.
  static const Color neutral900Dark = Color(0xFF0D1217);

  static const Color neutral800 = Color(0xFF393A4C);
  static const Color neutral700 = Color(0xFF4A4B62);
  static const Color neutral500 = Color(0xFF686A8A);
  static const Color neutral400 = Color(0xFF8688A1);
  static const Color neutral400Alt = Color(0xFF4C555F);
  static const Color neutral300 = Color(0xFF9A9BB1);
  static const Color neutral100 = Color(0xFFD0D1DB);
  static const Color neutral50 = Color(0xFFF0F0F3);
  static const Color neutral50Alt = Color(0xFFE9EAEB);

  static const Color divider = Color(0xFFE7E7E7);
  static const Color placeholder = Color(0xFFD9D9D9);

  // ─── Semantic ──────────────────────────────────────────────────────────────

  static const Color error50 = Color(0xFFFEECEB);
  static const Color error400 = Color(0xFFF6695E);
  static const Color error500 = Color(0xFFF44336);

  static const Color success400 = Color(0xFF33D375);
  static const Color success500 = Color(0xFF00C853);
  static const Color success500Alt = Color(0xFF13C296);

  static const Color warning400 = Color(0xFFFFD233);

  static const Color navyBlue = Color(0xFF1A47B8);

  // ─── Chat bubble accents (Custom Color Chat) ───────────────────────────────

  static const Color chatAccentCoral = Color(0xFFFF6347);

  // ─── Gradients (Figma: 127deg) ─────────────────────────────────────────────

  /// Gradient Blue — logo, акцентные блоки.
  static const LinearGradient gradientBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFF0F4888)],
  );

  /// Gradient Light Blue — primary CTA («Get started»).
  static const LinearGradient gradientLightBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF40C4FF), Color(0xFF03A9F4)],
  );

  // ─── Shadows ───────────────────────────────────────────────────────────────

  /// Shadow 2 — boxShadow: 0px 4px 12px rgba(0,0,0,0.06).
  static const List<BoxShadow> shadow2 = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // ─── ColorScheme ───────────────────────────────────────────────────────────

  static ColorScheme get lightColorScheme => const ColorScheme.light(
        primary: blue500,
        onPrimary: white,
        primaryContainer: blue50,
        onPrimaryContainer: blue900,
        secondary: lightBlue500,
        onSecondary: white,
        secondaryContainer: lightBlue50,
        onSecondaryContainer: lightBlue900,
        surface: white,
        onSurface: neutral900,
        onSurfaceVariant: neutral400,
        outline: neutral100,
        outlineVariant: neutral50,
        error: error500,
        onError: white,
        errorContainer: error50,
        onErrorContainer: error500,
      );

  static ColorScheme get darkColorScheme => const ColorScheme.dark(
        primary: lightBlue500,
        onPrimary: neutral900Dark,
        primaryContainer: blue900,
        onPrimaryContainer: lightBlue100,
        secondary: lightBlue400,
        onSecondary: neutral900Dark,
        secondaryContainer: lightBlue900,
        onSecondaryContainer: lightBlue100,
        surface: neutral900Dark,
        onSurface: white,
        onSurfaceVariant: neutral300,
        outline: neutral700,
        outlineVariant: neutral800,
        error: error400,
        onError: neutral900Dark,
        errorContainer: Color(0xFF3D1F1D),
        onErrorContainer: error400,
      );
}

/// Семантические алиасы для UI-компонентов чата (по макету E-Chat).
class TSemanticColors {
  TSemanticColors._();

  static const Color chatBubbleOutgoing = TColors.lightBlue500;
  static const Color chatBubbleIncomingLight = TColors.neutral50;
  static const Color chatBubbleIncomingDark = TColors.neutral800;

  static const Color unreadBadge = TColors.blue500;
  static const Color onlineIndicator = TColors.success500Alt;

  static const Color messageSent = TColors.neutral300;
  static const Color messageDelivered = TColors.lightBlue500;
  static const Color messageRead = TColors.blue500;

  static const Color codeError = TColors.error500;
  static const Color codeFilled = TColors.blue500;
}
