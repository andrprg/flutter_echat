import 'package:flutter/material.dart';

/// Отступы и размеры в логических пикселях (dp).
///
/// Flutter уже использует device-independent pixels, поэтому фиксированные
/// значения выглядят согласованно на телефонах и планшетах без масштабирования.
/// Для разного поведения на планшете используйте [TBreakpoints] и условные значения.

/// Общие размеры UI (кнопки, поля ввода, радиусы).
///
/// Ширины chrome / pane — см. [docs/layouts-tablet-desktop.md].
abstract final class TSizes {
  static const double buttonHeight = 60;
  static const double inputRadius = 12;
  static const double buttonRadius = 30;

  /// Максимальная ширина контента на desktop (auth / profile / more).
  static const double maxContentWidth = 720;

  /// Максимальная ширина формы auth / модалок на wide.
  static const double maxFormWidth = 480;

  /// NavigationRail (tablet) — только иконки.
  static const double railWidth = 72;

  /// Sidebar (desktop) — иконки + подписи.
  static const double sidebarWidth = 240;

  /// Master-колонка списка чатов / групп (tablet).
  static const double masterPaneWidthTablet = 300;

  /// Master-колонка списка чатов / групп (desktop).
  static const double masterPaneWidthDesktop = 320;

  /// Правая info-панель (desktop ThreePane).
  static const double infoPaneWidth = 320;

  /// Высота conversation tile на tablet / desktop.
  static const double conversationTileHeightWide = 64;
}

const gapW4 = SizedBox(width: 4.0);
const gapW8 = SizedBox(width: 8.0);
const gapW12 = SizedBox(width: 12.0);
const gapW16 = SizedBox(width: 16.0);
const gapW20 = SizedBox(width: 20.0);
const gapW24 = SizedBox(width: 24.0);
const gapW32 = SizedBox(width: 32.0);
const gapW48 = SizedBox(width: 48.0);
const gapW64 = SizedBox(width: 64.0);

const gapH4 = SizedBox(height: 4.0);
const gapH8 = SizedBox(height: 8.0);
const gapH12 = SizedBox(height: 12.0);
const gapH16 = SizedBox(height: 16.0);
const gapH20 = SizedBox(height: 20.0);
const gapH24 = SizedBox(height: 24.0);
const gapH32 = SizedBox(height: 32.0);
const gapH40 = SizedBox(height: 40.0);
const gapH48 = SizedBox(height: 48.0);
const gapH64 = SizedBox(height: 64.0);
