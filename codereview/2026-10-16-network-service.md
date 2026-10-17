# Code review: network status (`lib/src/utils/device/network_status_provider.dart`)

Дата: 2026-10-16  
Зависимость: `connectivity_plus: ^7.3.2`.

---

## Ревью #8 — approve

### Вердикт

**Approve.** Дубль seed закрыт: `_networkStatusEvents()` (seed + изменения) → снаружи `.distinct()` на всём потоке.

### Статус

| Finding | Статус |
| --- | --- |
| Все блокеры прошлых ревью | **fixed** |
| Дубль seed + первый эмит | **fixed** — `distinct` на объединённом stream |
| Hash в `.g.dart` | после правки — `build_runner` |

### Исправление дубля

```dart
Stream<NetworkStatus> networkStatus(Ref ref) =>
    _networkStatusEvents().distinct();

Stream<NetworkStatus> _networkStatusEvents() async* {
  yield _map(await connectivity.checkConnectivity()); // seed
  yield* connectivity.onConnectivityChanged.map(_map);
}
```

`distinct` видит и seed, и последующие эмиты как один stream.

---

## Ревью #9 — approve (повторный проход)

Контекст: свежий разбор текущего `network_status_provider.dart` (35 строк) + API `connectivity_plus` 7.3.2.

### Вердикт

**Approve.** Код корректный, семантика линка задокументирована, `distinct` на `NetworkStatus` оправдан. Блокеров нет; ниже — замечания уровня suggestion / info.

### Что сделано хорошо

- Чёткое разделение **link vs reachability** в dartdoc (`online` ≠ доступ в интернет).
- Корректное использование `List<ConnectivityResult>.hasConnectivity` (расширение пакета).
- Seed + `onConnectivityChanged` + `.distinct()` на всём потоке — закрывает дубль seed↔первый эмит и коллапсирует смену транспорта (`wifi`→`mobile` → оба `online`).
- `@Riverpod(keepAlive: true)` уместен для app-wide мониторинга.
- Расположение `utils/device/` соответствует directory-structure.
- `Connectivity()` — singleton плагина; лишних инстансов нет.

### Findings

#### [suggestion] Нет инъекции `Connectivity` — сложно тестировать
- Где: `network_status_provider.dart` → `_networkStatusEvents()`
- Что: `Connectivity()` захардкожен; override через `ProviderScope` без обёртки невозможен.
- Почему: unit-тесты стрима/маппинга потребуют platform mock или рефакторинг (`connectivityProvider`).
- Статус: open (не блокер, пока нет потребителей/тестов)

#### [info] Окно гонки между seed и подпиской на stream
- Где: `_networkStatusEvents` — `await checkConnectivity()` затем `yield* onConnectivityChanged`
- Что: изменение линка в промежутке между await и listen теоретически может быть пропущено.
- Почему: типичное ограничение паттерна seed+stream у `connectivity_plus`; на практике редко, keepAlive снижает частоту пересоздания.
- Статус: accepted risk

#### [suggestion] Ошибки платформы → сырой `AsyncError`, не `Failure`
- Где: провайдер без `handleError` / маппинга
- Что: исключение из `checkConnectivity` / канала уронит `AsyncValue` в error с сырым exception.
- Почему: для utils допустимо; UI-потребителям лучше заранее договориться о retry / `Failure.network` на границе feature, а не пробрасывать plugin exception.
- Статус: open (актуально при первом UI-потребителе)

#### [info] Провайдер пока нигде не используется
- Где: репозиторий (grep по `networkStatusProvider` / `NetworkStatus`)
- Что: только определение + `.g.dart`.
- Почему: ок для WIP; перед мержем в продукт — хотя бы один consumer или тест маппинга.
- Статус: open

### Не findings (осознанно ок)

| Тема | Почему ок |
| --- | --- |
| `enum` без Freezed | два литерала; Freezed обязателен для state/entity/failure/DTO |
| `ref` не используется | норма для functional stream-provider |
| Двойной `distinct` (пакет + наш) | пакет — по `List`; наш — по `NetworkStatus` (другая семантика) |
| Имена `online`/`offline` | при наличии dartdoc не вводят в заблуждение |

### Чеклист перед первым UI-потребителем

1. Не трактовать `online` как «можно бить API» (captive portal / DNS).
2. В UI: `ref.watch(networkStatusProvider)` → обработка `AsyncLoading` / `AsyncError`.
3. По желанию: `Provider` для `Connectivity` + unit-тест `_map` / сценария distinct.
)
