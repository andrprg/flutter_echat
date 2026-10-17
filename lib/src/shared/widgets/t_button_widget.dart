import 'package:flutter/material.dart';
import 'package:flutter_echat/src/shared/widgets/t_icon_widget.dart';
import 'package:flutter_echat/src/utils/constants/colors.dart';
import 'package:flutter_echat/src/utils/constants/sizes.dart';
import 'package:flutter_echat/src/utils/helpers/helper_functions.dart';
import 'package:flutter_echat/src/utils/theme/widget_themes/progress_indicator_theme.dart';
import 'package:flutter_echat/src/utils/theme/widget_themes/text_theme.dart';

/// Визуальный вариант кнопки [TButton].
enum TButtonVariant {
  /// Основное действие: фон [TColors.gradientLightBlue].
  primary,

  /// Опасное действие: сплошной фон [TColors.error500].
  danger,
}

/// Кнопка design-system E-Chat.
///
/// Фон рисует [DecoratedBox] (градиент / цвет / disabled), поверх — прозрачный
/// [ElevatedButton] для нажатия и ripple. Иконка слева, состояние загрузки,
/// варианты [TButtonVariant]. Dumb-виджет: без Riverpod и breakpoints.
///
/// Пример:
/// ```dart
/// TButton(
///   label: 'Войти',
///   icon: 'outline_arrows_action_login_3',
///   onTap: () {},
/// )
/// ```
///
/// Параметры:
/// - [label] — текст на кнопке
/// - [variant] — [TButtonVariant.primary] (градиент) или [TButtonVariant.danger]
/// - [onTap] — колбэк; `null` отключает кнопку (серый фон)
/// - [isLoading] — спиннер вместо текста; кнопка не нажимается
/// - [icon] — имя SVG из `assets/icons` (как у [TIconWidget]); опционально
/// - [radius] — радиус скругления; по умолчанию [TSizes.buttonRadius]
/// - [width] — ширина; по умолчанию на всю доступную
class TButtonWidget extends StatelessWidget {
  /// Текст на кнопке.
  final String label;

  /// Вариант оформления ([TButtonVariant.primary] / [TButtonVariant.danger]).
  final TButtonVariant variant;

  /// Обработчик нажатия; `null` — disabled.
  final VoidCallback? onTap;

  /// Если `true` — индикатор загрузки вместо текста, `onPressed` сбрасывается.
  final bool isLoading;

  /// Имя иконки слева от текста; `null` — без иконки.
  final String? icon;

  /// Радиус скругления; `null` — [TSizes.buttonRadius].
  final double? radius;

  /// Ширина контейнера; по умолчанию [double.infinity].
  final double width;

  const TButtonWidget({
    super.key,
    required this.label,
    this.variant = TButtonVariant.primary,
    this.onTap,
    this.isLoading = false,
    this.radius,
    this.icon,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final r = BorderRadius.circular(radius ?? TSizes.buttonRadius);
    final isDisabled = onTap == null && !isLoading;

    final Decoration decoration = isDisabled
        ? BoxDecoration(
            color: isDark ? TColors.neutral800 : TColors.neutral100,
            borderRadius: r,
          )
        : BoxDecoration(
            gradient: variant == TButtonVariant.primary ? TColors.gradientLightBlue : null,
            color: variant == TButtonVariant.danger ? TColors.error500 : null,
            borderRadius: r,
          );

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: decoration,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent, // фон рисует DecoratedBox
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: r),
          ),
          onPressed: isLoading ? null : onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null && !isLoading) ...[
                TIconWidget(icon: icon!, color: isDark ? TColors.neutral900 : TColors.white),
                gapW8,
              ],
              _ButtonContent(label: label, isDark: isDark, isLoading: isLoading),
            ],
          ),
        ),
      ),
    );
  }
}

/// Контент [TButton]: текст метки или индикатор загрузки.
class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.label, required this.isDark, this.isLoading = false});

  /// Отображаемый текст (если не [isLoading]).
  final String label;

  /// Показывать спиннер вместо текста.
  final bool isLoading;

  /// Тёмная тема — цвет текста ([TColors.neutral900] / [TColors.white]).
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const _CircularProgress()
        : Text(
            label,
            style: TTextTheme.lightTextTheme.labelLarge?.copyWith(color: isDark ? TColors.neutral900 : TColors.white),
          );
  }
}

/// Круговой индикатор загрузки для [TButton.isLoading].
///
/// Цвета — как [TProgressIndicatorTheme.onPrimary]; размер 22×22 (design_kimi).
class _CircularProgress extends StatelessWidget {
  const _CircularProgress();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        color: TColors.white,
        backgroundColor: TColors.white.withValues(alpha: 0.35),
        strokeWidth: TProgressIndicatorTheme.buttonStrokeWidth,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}
