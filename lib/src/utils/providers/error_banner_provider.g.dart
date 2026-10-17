// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_banner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Глобальный баннер ошибки: [ErrorBannerState] или `null` (скрыт).
///
/// Канал для ошибок **действия** (логин, отправка), когда экран остаётся
/// на месте. Не для загрузки экрана (`AsyncValue.error` → `ErrorView`)
/// и не для валидации поля до submit (`errorBorder` у поля).
///
/// KeepAlive: баннер живёт вне шелла вкладок (Login / Register тоже его
/// видят). Хост — `MaterialApp.builder` в `EChatApp` (`Stack` над
/// навигатором + dumb `TErrorBannerWidget`). Не класть в `nav_shell`.
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

@ProviderFor(ErrorBanner)
final errorBannerProvider = ErrorBannerProvider._();

/// Глобальный баннер ошибки: [ErrorBannerState] или `null` (скрыт).
///
/// Канал для ошибок **действия** (логин, отправка), когда экран остаётся
/// на месте. Не для загрузки экрана (`AsyncValue.error` → `ErrorView`)
/// и не для валидации поля до submit (`errorBorder` у поля).
///
/// KeepAlive: баннер живёт вне шелла вкладок (Login / Register тоже его
/// видят). Хост — `MaterialApp.builder` в `EChatApp` (`Stack` над
/// навигатором + dumb `TErrorBannerWidget`). Не класть в `nav_shell`.
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
final class ErrorBannerProvider
    extends $NotifierProvider<ErrorBanner, ErrorBannerState?> {
  /// Глобальный баннер ошибки: [ErrorBannerState] или `null` (скрыт).
  ///
  /// Канал для ошибок **действия** (логин, отправка), когда экран остаётся
  /// на месте. Не для загрузки экрана (`AsyncValue.error` → `ErrorView`)
  /// и не для валидации поля до submit (`errorBorder` у поля).
  ///
  /// KeepAlive: баннер живёт вне шелла вкладок (Login / Register тоже его
  /// видят). Хост — `MaterialApp.builder` в `EChatApp` (`Stack` над
  /// навигатором + dumb `TErrorBannerWidget`). Не класть в `nav_shell`.
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
  ErrorBannerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'errorBannerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$errorBannerHash();

  @$internal
  @override
  ErrorBanner create() => ErrorBanner();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ErrorBannerState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ErrorBannerState?>(value),
    );
  }
}

String _$errorBannerHash() => r'3aaa0f710f76645cbf71fd8fca774f226a850f7b';

/// Глобальный баннер ошибки: [ErrorBannerState] или `null` (скрыт).
///
/// Канал для ошибок **действия** (логин, отправка), когда экран остаётся
/// на месте. Не для загрузки экрана (`AsyncValue.error` → `ErrorView`)
/// и не для валидации поля до submit (`errorBorder` у поля).
///
/// KeepAlive: баннер живёт вне шелла вкладок (Login / Register тоже его
/// видят). Хост — `MaterialApp.builder` в `EChatApp` (`Stack` над
/// навигатором + dumb `TErrorBannerWidget`). Не класть в `nav_shell`.
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

abstract class _$ErrorBanner extends $Notifier<ErrorBannerState?> {
  ErrorBannerState? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ErrorBannerState?, ErrorBannerState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ErrorBannerState?, ErrorBannerState?>,
              ErrorBannerState?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
