import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/breakpoints.dart';

part 'app_breakpoint_provider.g.dart';

/// Публикует текущий [AppBreakpoint] по ширине окна.
///
/// Smart-экраны читают этот провайдер; dumb-виджеты пороги не знают.
@Riverpod(keepAlive: true)
AppBreakpoint appBreakpoint(Ref ref) {
  // Заглушка до подключения View.of / MediaQuery в shell.
  // Реальная ширина будет браться из окна приложения.
  return AppBreakpoint.phone;
}

/// Smart-helper: выбирает child по [appBreakpointProvider].
///
/// Только для smart-слоя (`*_screen`, shell). В dumb (`*_view`, shared)
/// не использовать — там нет знания о breakpoints.
///
/// Fallback: `tablet ?? phone`, `desktop ?? tablet ?? phone`.
///
/// ```dart
/// ResponsiveBuilder(
///   phone: ChatListPhoneLayout(child: view),
///   tablet: ChatListTabletLayout(child: view),
///   desktop: ChatListDesktopLayout(child: view),
/// )
/// ```
class ResponsiveBuilder extends ConsumerWidget {
  const ResponsiveBuilder({
    super.key,
    required this.phone,
    this.tablet,
    this.desktop,
  });

  /// Layout для phone (`< 600`). Обязателен — базовый вариант.
  final Widget phone;

  /// Layout для tablet (`600 … 1023`). Если `null` — используется [phone].
  final Widget? tablet;

  /// Layout для desktop (`≥ 1024`). Если `null` — [tablet] или [phone].
  final Widget? desktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakpoint = ref.watch(appBreakpointProvider);
    return switch (breakpoint) {
      AppBreakpoint.phone => phone,
      AppBreakpoint.tablet => tablet ?? phone,
      AppBreakpoint.desktop => desktop ?? tablet ?? phone,
    };
  }
}
