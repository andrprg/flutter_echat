/// Пороги адаптивной вёрстки (dp).
abstract final class TBreakpoints {
  static const double tablet = 600;
  static const double desktop = 1024;
}

/// Текущий форм-фактор окна.
enum AppBreakpoint {
  phone,
  tablet,
  desktop,
}

/// Определяет [AppBreakpoint] по ширине окна.
AppBreakpoint appBreakpointFromWidth(double width) {
  if (width >= TBreakpoints.desktop) return AppBreakpoint.desktop;
  if (width >= TBreakpoints.tablet) return AppBreakpoint.tablet;
  return AppBreakpoint.phone;
}
