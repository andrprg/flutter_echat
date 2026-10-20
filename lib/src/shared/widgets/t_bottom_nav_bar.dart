import 'package:flutter/material.dart';
import 'package:flutter_echat/src/shared/widgets/t_icon_widget.dart';
import 'package:flutter_echat/src/utils/constants/sizes.dart';
import 'package:flutter_echat/src/utils/theme/widget_themes/bottom_navigator_bar_theme.dart';

/// Нижняя навигация вкладок shell: Чаты · Группы · Профиль · Ещё.
///
/// Dumb-виджет (`shared/widgets`): только визуал и колбэк, без Riverpod,
/// Firebase и `go_router`. Хост (smart `nav_shell`) передаёт
/// [currentIndex] и обрабатывает [onDestinationSelected] (например `goBranch`).
///
/// Не использует M3 [NavigationBar]: активная вкладка — плитка с градиентом
/// из [TBottomNavigatorBarTheme.selectedGradient] (Figma Navbar `58:2793`).
/// Токены (фон, inactive, размеры, тень, типографика лейбла) читаются через
/// [TBottomNavigatorBarTheme.of] (`ThemeData.extensions` в `TAppTheme`).
///
/// Порядок пунктов и индексов должен совпадать с ветками
/// `StatefulShellRoute` (0…3). Иконки — пары outline / selected SVG через
/// [TIconWidget].
class TBottomNavBar extends StatelessWidget {
  const TBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  /// Индекс активной вкладки (`0`…`3`, тот же, что у ветки shell).
  final int currentIndex;

  /// Вызов при тапе по пункту; хост меняет ветку / маршрут.
  final ValueChanged<int> onDestinationSelected;

  static const List<_NavDestination> _destinations = [
    _NavDestination(
      label: 'Чаты',
      icon: 'chat',
      selectedIcon: 'chat_selected',
    ),
    _NavDestination(
      label: 'Группы',
      icon: 'groups',
      selectedIcon: 'groups_selected',
    ),
    _NavDestination(
      label: 'Профиль',
      icon: 'profile',
      selectedIcon: 'profile_selected',
    ),
    _NavDestination(
      label: 'Ещё',
      icon: 'more',
      selectedIcon: 'more_selected',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    assert(
      currentIndex >= 0 && currentIndex < _destinations.length,
      'currentIndex ($currentIndex) вне диапазона 0..${_destinations.length - 1}',
    );

    final theme = TBottomNavigatorBarTheme.of(context);

    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(theme.borderRadius),
          ),
          boxShadow: theme.shadows,
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: theme.height,
            child: Row(
              children: [
                for (var i = 0; i < _destinations.length; i++)
                  Expanded(
                    child: _TBottomNavItem(
                      destination: _destinations[i],
                      selected: currentIndex == i,
                      onTap: () => onDestinationSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final String icon;
  final String selectedIcon;
}

/// Пункт бара: inactive — outline-иконка + лейбл; active — плитка с
/// [TBottomNavigatorBarTheme.selectedGradient] и bold SVG без color filter.
class _TBottomNavItem extends StatelessWidget {
  const _TBottomNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = TBottomNavigatorBarTheme.of(context);
    final color =
        selected ? theme.selectedForegroundColor : theme.inactiveColor;

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        TIconWidget(
          icon: selected ? destination.selectedIcon : destination.icon,
          // Selected SVG уже с нужными fill (белый / акцентные точки).
          applyColorFilter: !selected,
          color: selected ? null : theme.inactiveColor,
        ),
        gapH4,
        Text(
          destination.label,
          style: theme.labelStyle.copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        excludeFromSemantics: true,
        child: Center(
          child: selected
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: theme.selectedGradient,
                    borderRadius:
                        BorderRadius.circular(theme.tileBorderRadius),
                  ),
                  child: SizedBox(
                    width: theme.tileWidth,
                    height: theme.tileHeight,
                    child: content,
                  ),
                )
              : SizedBox(
                  width: theme.tileWidth,
                  height: theme.tileHeight,
                  child: content,
                ),
        ),
      ),
    );
  }
}
