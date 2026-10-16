// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_breakpoint_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Публикует текущий [AppBreakpoint] по ширине окна.
///
/// Smart-экраны читают этот провайдер; dumb-виджеты пороги не знают.

@ProviderFor(appBreakpoint)
final appBreakpointProvider = AppBreakpointProvider._();

/// Публикует текущий [AppBreakpoint] по ширине окна.
///
/// Smart-экраны читают этот провайдер; dumb-виджеты пороги не знают.

final class AppBreakpointProvider
    extends $FunctionalProvider<AppBreakpoint, AppBreakpoint, AppBreakpoint>
    with $Provider<AppBreakpoint> {
  /// Публикует текущий [AppBreakpoint] по ширине окна.
  ///
  /// Smart-экраны читают этот провайдер; dumb-виджеты пороги не знают.
  AppBreakpointProvider._()
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
  String debugGetCreateSourceHash() => _$appBreakpointHash();

  @$internal
  @override
  $ProviderElement<AppBreakpoint> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppBreakpoint create(Ref ref) {
    return appBreakpoint(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppBreakpoint value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppBreakpoint>(value),
    );
  }
}

String _$appBreakpointHash() => r'f200bd91557303eab30821cd8d6d656149eb84d1';
