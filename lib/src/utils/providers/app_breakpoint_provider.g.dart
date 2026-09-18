// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_breakpoint_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Публикует текущий [AppBreakpoint] по ширине окна.
///
/// Ширина: [FlutterView] (logical px) + при наличии дерева —
/// [MediaQuery.sizeOf] через [AppBreakpointListener].
/// При ресайзе окна пересчитывается (`didChangeMetrics`).
///
/// Smart-экраны читают этот провайдер; dumb-виджеты пороги не знают.

@ProviderFor(AppBreakpointNotifier)
final appBreakpointProvider = AppBreakpointNotifierProvider._();

/// Публикует текущий [AppBreakpoint] по ширине окна.
///
/// Ширина: [FlutterView] (logical px) + при наличии дерева —
/// [MediaQuery.sizeOf] через [AppBreakpointListener].
/// При ресайзе окна пересчитывается (`didChangeMetrics`).
///
/// Smart-экраны читают этот провайдер; dumb-виджеты пороги не знают.
final class AppBreakpointNotifierProvider
    extends $NotifierProvider<AppBreakpointNotifier, AppBreakpoint> {
  /// Публикует текущий [AppBreakpoint] по ширине окна.
  ///
  /// Ширина: [FlutterView] (logical px) + при наличии дерева —
  /// [MediaQuery.sizeOf] через [AppBreakpointListener].
  /// При ресайзе окна пересчитывается (`didChangeMetrics`).
  ///
  /// Smart-экраны читают этот провайдер; dumb-виджеты пороги не знают.
  AppBreakpointNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appBreakpointProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appBreakpointNotifierHash();

  @$internal
  @override
  AppBreakpointNotifier create() => AppBreakpointNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppBreakpoint value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppBreakpoint>(value),
    );
  }
}

String _$appBreakpointNotifierHash() =>
    r'2474d7d550e8a420e9299543a7b7e478da4b15b7';

/// Публикует текущий [AppBreakpoint] по ширине окна.
///
/// Ширина: [FlutterView] (logical px) + при наличии дерева —
/// [MediaQuery.sizeOf] через [AppBreakpointListener].
/// При ресайзе окна пересчитывается (`didChangeMetrics`).
///
/// Smart-экраны читают этот провайдер; dumb-виджеты пороги не знают.

abstract class _$AppBreakpointNotifier extends $Notifier<AppBreakpoint> {
  AppBreakpoint build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppBreakpoint, AppBreakpoint>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppBreakpoint, AppBreakpoint>,
              AppBreakpoint,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
