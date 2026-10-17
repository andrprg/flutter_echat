// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Поток текущего [NetworkStatus].
///
/// Сначала отдаёт сид через [Connectivity.checkConnectivity], затем
/// эмитит изменения из [Connectivity.onConnectivityChanged].
/// Онлайн — при [List<ConnectivityResult>.hasConnectivity] (любой
/// активный интерфейс); иначе — офлайн. Статус линка, не reachability.
/// Подряд одинаковые статусы (в т.ч. дубль seed ↔ первый эмит) отсекаются
/// [Stream.distinct] на всём потоке. Провайдер keepAlive.

@ProviderFor(networkStatus)
final networkStatusProvider = NetworkStatusProvider._();

/// Поток текущего [NetworkStatus].
///
/// Сначала отдаёт сид через [Connectivity.checkConnectivity], затем
/// эмитит изменения из [Connectivity.onConnectivityChanged].
/// Онлайн — при [List<ConnectivityResult>.hasConnectivity] (любой
/// активный интерфейс); иначе — офлайн. Статус линка, не reachability.
/// Подряд одинаковые статусы (в т.ч. дубль seed ↔ первый эмит) отсекаются
/// [Stream.distinct] на всём потоке. Провайдер keepAlive.

final class NetworkStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<NetworkStatus>,
          NetworkStatus,
          Stream<NetworkStatus>
        >
    with $FutureModifier<NetworkStatus>, $StreamProvider<NetworkStatus> {
  /// Поток текущего [NetworkStatus].
  ///
  /// Сначала отдаёт сид через [Connectivity.checkConnectivity], затем
  /// эмитит изменения из [Connectivity.onConnectivityChanged].
  /// Онлайн — при [List<ConnectivityResult>.hasConnectivity] (любой
  /// активный интерфейс); иначе — офлайн. Статус линка, не reachability.
  /// Подряд одинаковые статусы (в т.ч. дубль seed ↔ первый эмит) отсекаются
  /// [Stream.distinct] на всём потоке. Провайдер keepAlive.
  NetworkStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkStatusHash();

  @$internal
  @override
  $StreamProviderElement<NetworkStatus> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<NetworkStatus> create(Ref ref) {
    return networkStatus(ref);
  }
}

String _$networkStatusHash() => r'e345ed0fa241d2fed30ad55ff66b9b38c60b9d82';
