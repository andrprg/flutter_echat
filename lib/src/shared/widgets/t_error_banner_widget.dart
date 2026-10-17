import 'package:flutter/material.dart';
import 'package:flutter_echat/src/utils/constants/colors.dart';
import 'package:flutter_echat/src/utils/constants/sizes.dart';

/// Toast ошибки.
///
/// Dumb-виджет: только [message] + [onClose], без Riverpod и
/// `ScaffoldMessenger`. Закрытие (кнопка / swipe) всегда через [onClose] —
/// хост вызывает `errorBannerProvider.notifier.dismiss()`.
///
/// Хост (`MaterialApp.builder` / Widgetbook) обязан задать [key] на **каждый
/// show** (новый снимок баннера), иначе повтор того же текста после swipe
/// оставит dismissed-[Dismissible] в дереве:
/// ```dart
/// if (banner != null)
///   TErrorBannerWidget(
///     key: ObjectKey(banner),
///     message: banner.failure.displayMessage,
///     onClose: () => ref.read(errorBannerProvider.notifier).dismiss(),
///   )
/// ```
class TErrorBannerWidget extends StatelessWidget {
  const TErrorBannerWidget({
    super.key,
    required this.message,
    required this.onClose,
    this.leftMargin = 0,
    this.rightMargin = 0,
  });

  /// Текст ошибки ([Failure.displayMessage]).
  final String message;

  /// Скрыть баннер: хост → `errorBannerProvider.notifier.dismiss()`.
  final VoidCallback onClose;

  final double leftMargin;
  final double rightMargin;

  @override
  Widget build(BuildContext context) {
    return _ErrorBannerShell(
      onClose: onClose,
      leftMargin: leftMargin,
      rightMargin: rightMargin,
      child: _ErrorBannerCard(
        message: message,
        onClose: onClose,
        colors: _ErrorBannerColors.of(context),
      ),
    );
  }
}

/// Токены toast-error (light / dark).
class _ErrorBannerColors {
  const _ErrorBannerColors({
    required this.background,
    required this.error,
    required this.errorContainer,
    required this.onVariant,
    required this.text,
  });

  factory _ErrorBannerColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ErrorBannerColors(
      background: isDark ? TColors.neutral800 : TColors.white,
      error: isDark ? TColors.error400 : TColors.error500,
      errorContainer: isDark ? TColors.error50Dark : TColors.error50,
      onVariant: isDark ? TColors.neutral300 : TColors.neutral400,
      text: isDark ? TColors.white : TColors.neutral900,
    );
  }

  final Color background;
  final Color error;
  final Color errorContainer;
  final Color onVariant;
  final Color text;
}

const double _kRadius = 14;
const double _kMinHeight = 48;

/// Стабильный ключ [Dismissible] внутри одного mount.
///
/// Remount после повторного show — через [Key] у [TErrorBannerWidget], не от текста.
const Key _kDismissibleKey = ValueKey<String>('t_error_banner');

/// Overlay-оболочка: safe-area top, margins, центрирование, swipe → [onClose].
class _ErrorBannerShell extends StatelessWidget {
  const _ErrorBannerShell({
    required this.onClose,
    required this.leftMargin,
    required this.rightMargin,
    required this.child,
  });

  final VoidCallback onClose;
  final double leftMargin;
  final double rightMargin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Padding(
      padding: EdgeInsets.only(
        top: topPadding + 8,
        left: leftMargin,
        right: rightMargin,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: TSizes.maxFormWidth),
          child: Dismissible(
            key: _kDismissibleKey,
            direction: DismissDirection.up,
            resizeDuration: null,
            onDismissed: (_) => onClose(),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Карточка Material: полоска + контент; высота ≥ [_kMinHeight].
class _ErrorBannerCard extends StatelessWidget {
  const _ErrorBannerCard({
    required this.message,
    required this.onClose,
    required this.colors,
  });

  final String message;
  final VoidCallback onClose;
  final _ErrorBannerColors colors;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.background,
      elevation: 6,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(_kRadius),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _kMinHeight),
        child: IntrinsicHeight(
          child: Stack(
            children: [
              _ErrorAccentBar(color: colors.error),
              _ErrorBannerBody(
                message: message,
                onClose: onClose,
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row: статус-иконка, текст (до 2 строк), close.
class _ErrorBannerBody extends StatelessWidget {
  const _ErrorBannerBody({
    required this.message,
    required this.onClose,
    required this.colors,
  });

  final String message;
  final VoidCallback onClose;
  final _ErrorBannerColors colors;

  @override
  Widget build(BuildContext context) {
    final messageStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 14,
          height: 1.35,
          color: colors.text,
        );

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(_kRadius - 2),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ErrorStatusIcon(
                background: colors.errorContainer,
                foreground: colors.error,
              ),
              gapW12,
              Expanded(
                child: Text(
                  message,
                  style: messageStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: Icon(Icons.close, color: colors.onVariant, size: 20),
                tooltip:
                    MaterialLocalizations.of(context).closeButtonTooltip,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Левая акцентная полоска toast-error.
class _ErrorAccentBar extends StatelessWidget {
  const _ErrorAccentBar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(_kRadius),
            bottomLeft: Radius.circular(_kRadius),
          ),
        ),
        child: const SizedBox(width: 8),
      ),
    );
  }
}

/// Круглая иконка ошибки 28×28.
class _ErrorStatusIcon extends StatelessWidget {
  const _ErrorStatusIcon({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(Icons.error_outline, color: foreground, size: 16),
    );
  }
}
