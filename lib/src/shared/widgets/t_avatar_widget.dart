import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';

/// Аватар с инициалами на градиентной подложке.
///
/// Градиент детерминированно выбирается по имени, точка online — справа снизу.
/// Dumb-виджет: без Riverpod и знания о breakpoints.
class TAvatarWidget extends StatelessWidget {
  const TAvatarWidget({
    super.key,
    required this.name,
    this.size = 48,
    this.showOnlineDot = false,
  });

  /// Имя — источник инициалов и градиента.
  final String name;

  /// Диаметр аватара.
  final double size;

  /// Показывать ли зелёную точку «в сети».
  final bool showOnlineDot;

  /// Инициалы: первые буквы двух первых слов, верхний регистр.
  static String initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  /// Детерминированный хеш имени (как `avHash` в макетах design_kimi).
  static int _hashOf(String name) {
    var h = 0;
    for (final c in name.codeUnits) {
      h = (h * 31 + c) & 0x7FFFFFFF;
    }
    return h;
  }

  @override
  Widget build(BuildContext context) {
    final gradients = TColors.avatarGradients;
    final gradient = gradients[_hashOf(name) % gradients.length];
    final surface = Theme.of(context).colorScheme.surface;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
              ),
              child: Center(
                child: Text(
                  initialsOf(name),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: size * 0.36,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          if (showOnlineDot)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TColors.onlineGreen,
                  border: Border.all(color: surface, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
