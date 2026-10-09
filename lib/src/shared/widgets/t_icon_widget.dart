import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

/// Виджет для отображения иконки.
///
/// Иконки хранятся в папке assets/icons.
///
/// Пример использования:
/// ```dart
/// TIconWidget(
///   icon: 'outline_search_magnifer',
/// )
/// ```
///
/// Параметры:
/// - [icon] — имя иконки
/// - [width] — ширина иконки
/// - [height] — высота иконки
/// - [color] — цвет иконки; если null — берётся из [IconTheme]
/// - [applyColorFilter] — если false, цвета из SVG сохраняются как есть
///   (нужно для многоцветных иконок)
class TIconWidget extends StatelessWidget {
  const TIconWidget({
    super.key,
    required this.icon,
    this.width = 24.0,
    this.height = 24.0,
    this.color,
    this.applyColorFilter = true,
  });

  final String icon;
  final double width;
  final double height;
  final Color? color;
  final bool applyColorFilter;


  static BytesLoader _createLoader(String icon) {
    final name = icon.endsWith('.svg') ? icon : '$icon.svg';
    return AssetBytesLoader('assets/icons/$name');
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? IconTheme.of(context).color;

    return VectorGraphic(
      loader: _createLoader(icon),
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        // иконки нет / битый ассет — рисуем запасной виджет
        return Icon(Icons.broken_image_outlined, size: width, color: effectiveColor);
      },
      colorFilter: applyColorFilter && effectiveColor != null
          ? ColorFilter.mode(effectiveColor, BlendMode.srcIn)
          : null,
    );
  }
}
