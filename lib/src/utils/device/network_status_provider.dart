import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_status_provider.g.dart';

/// Статус сетевого линка устройства (тип интерфейса, не reachability).
///
/// [online] означает наличие активного сетевого интерфейса
/// (Wi‑Fi, mobile, ethernet, VPN и т.п.), но не гарантирует доступ
/// в интернет (captive portal, DNS и т.д.).
enum NetworkStatus {
  /// Нет активного сетевого интерфейса ([ConnectivityResult.none]).
  offline,

  /// Есть хотя бы один активный сетевой интерфейс.
  online,
}

/// Поток текущего [NetworkStatus].
///
/// Сначала отдаёт сид через [Connectivity.checkConnectivity], затем
/// эмитит изменения из [Connectivity.onConnectivityChanged].
/// Онлайн — при [List<ConnectivityResult>.hasConnectivity] (любой
/// активный интерфейс); иначе — офлайн. Статус линка, не reachability.
/// Подряд одинаковые статусы (в т.ч. дубль seed ↔ первый эмит) отсекаются
/// [Stream.distinct] на всём потоке. Провайдер keepAlive.
@Riverpod(keepAlive: true)
Stream<NetworkStatus> networkStatus(Ref ref) =>
    _networkStatusEvents().distinct();

Stream<NetworkStatus> _networkStatusEvents() async* {
  final connectivity = Connectivity();
  yield _map(await connectivity.checkConnectivity()); // seed
  yield* connectivity.onConnectivityChanged.map(_map);
}

NetworkStatus _map(List<ConnectivityResult> results) =>
    results.hasConnectivity ? NetworkStatus.online : NetworkStatus.offline;
