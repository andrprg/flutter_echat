import 'dart:async';

import 'package:flutter_echat/src/utils/exceptions/failures.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'error_banner_provider.g.dart';

/// Снимок показа глобального баннера ошибки.
///
/// Хранит только [failure]; текст для UI — [Failure.displayMessage],
/// не отдельный `String`.
class ErrorBannerState {
  final Failure failure;

  ErrorBannerState({required this.failure});
}

/// Глобальный баннер ошибки: [ErrorBannerState] или `null` (скрыт).
///
/// Канал для ошибок **действия** (логин, отправка), когда экран остаётся
/// на месте. Не для загрузки экрана (`AsyncValue.error` → `ErrorView`)
/// и не для валидации поля до submit (`errorBorder` у поля).
///
/// KeepAlive: баннер живёт вне шелла вкладок (Login / Register тоже его
/// видят). Хост — `MaterialApp.builder` в `EChatApp` (`Stack` над
/// навигатором + dumb `TErrorToast`). Не класть в `nav_shell`.
///
/// Smart / Notifier после `fold`:
/// ```dart
/// result.fold(
///   (failure) => ref.read(errorBannerProvider.notifier).show(
///     failure: failure,
///   ),
///   (_) => ...,
/// );
/// ```
@Riverpod(keepAlive: true)
class ErrorBanner extends _$ErrorBanner {
  Timer? _autoDismissTimer;

  /// Начальное состояние: баннер скрыт.
  @override
  ErrorBannerState? build() => null;

  /// Показывает [failure] в глобальном баннере.
  ///
  /// При [timeoutSeconds] > 0 баннер скрывается через это число секунд.
  /// Предыдущий таймер автоскрытия отменяется.
  void show({required Failure failure, int timeoutSeconds = 0}) {
    _autoDismissTimer?.cancel();
    state = ErrorBannerState(failure: failure);
    if (timeoutSeconds > 0) {
      _autoDismissTimer = Timer(Duration(seconds: timeoutSeconds), dismiss);
    }
  }

  /// Скрывает баннер (`state = null`) и отменяет таймер автоскрытия.
  void dismiss() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    state = null;
  }
}
