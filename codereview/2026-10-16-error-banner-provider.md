# Code review: error banner (`lib/src/utils/providers/error_banner_provider.dart`)

Дата: 2026-10-16  
Контекст: глобальный баннер ошибок действия (`architecture_echat.md` §10.5, правило `error-display`).

---

## Ревью #1

### Вердикт

**Request changes.** Архитектурно направление верное (`Failure?`, `keepAlive`, канал действия vs `ErrorView`), но есть опечатка в публичном API, гонка автоскрытия и риск «тишины» при повторном показе того же `Failure`.

### Что сделано хорошо

- `@Riverpod(keepAlive: true)` + стейт `Failure?` — совпадает с §10.5 / `error-display`.
- Текст ошибки не кладётся в state как `String`; UI должен брать `Failure.displayMessage`.
- Dartdoc чётко разводит три канала ошибок и место хоста (`MaterialApp.builder`, не `nav_shell`).
- Синхронный `Notifier` уместен для UI-стейта баннера.

### Findings

#### [blocker] Опечатка публичного API: `dimiss` вместо `dismiss`
- Где: `ErrorBanner.dimiss()`; также вызов в `show` → `dimiss()`
- Что: метод назван `dimiss`; в `architecture_echat.md` §10.5, `error-display.mdc` и примерах — `dismiss`.
- Почему: расхождение с контрактом команды; автодополнение и копипаст из доков сломаются; опечатка закрепится в call-sites.
- Статус: fixed  
- Исправление: метод переименован в `dismiss`.

#### [major] Гонка `Future.delayed` при повторном `show` / ручном закрытии
- Где: `show` — `Future.delayed(..., () => dimiss())` без отмены предыдущего таймера
- Что: при `show(A, timeout: 5)` → затем `show(B)` (или ручной dismiss + новый `show`) колбэк от A всё равно вызовет dismiss и скроет актуальный баннер B раньше срока.
- Почему: нет `Timer` / generation token / проверки «это всё ещё тот же failure». Для глобального keepAlive-провайдера сценарий частый (повтор логина, серия ошибок).
- Статус: fixed  
- Направление фикса: хранить `Timer?`, в `show`/`dismiss` делать `cancel()`, в колбэке сверять `state` с показанным `failure` (или монотонный `_epoch`).
- Исправление: `_autoDismissTimer` (`dart:async` `Timer`), `cancel()` в `show` и `dismiss`.

#### [major] Повторный `show` того же `Failure` может не обновить UI
- Где: `state = failure` при value-equality Freezed
- Что: Riverpod не нотифицирует слушателей, если новый `state ==` старому. Два одинаковых `Failure.auth(...)` подряд (баннер ещё виден или только что показан) → нет rebuild / нет повторной анимации тоста.
- Почему: типичный UX-баг глобальных тостов на value-типах; пользователь повторяет действие и «не видит» ошибку.
- Статус: fixed  
- Исправление: `ErrorBannerState(failure, id)` + монотонный `_id` при каждом `show`.

#### [minor] Сигнатура `show` расходится с документацией
- Где: `void show({required Failure failure, int? timeoutSeconds})`
- Что: в §10.5 и `error-display` пример — `show(failure)` (позиционный); здесь named `failure:` + опциональный timeout.
- Почему: лишнее трение при внедрении; timeout в доках не описан (ок как расширение, но базовый вызов лучше выровнять: `show(Failure failure, {Duration? autoDismissAfter})`).
- Статус: fixed  
- Исправление: доки выровнены под named API (`show(failure: …)`, `timeoutSeconds`, `ErrorBannerState`).

#### [suggestion] `timeoutSeconds` как `int?` вместо `Duration?`
- Где: параметр `timeoutSeconds`
- Что: менее идиоматично для Flutter; нет защиты от `<= 0`.
- Почему: `Duration` снимает неоднозначность единиц; при `0`/`отрицательном` delayed ведёт себя неожиданно.
- Статус: open

#### [info] Провайдер пока без хоста / потребителей в коде
- Где: репозиторий (кроме самого файла и `.g.dart` / доков)
- Что: `TErrorToast` + `MaterialApp.builder` ещё не подключены (WIP).
- Почему: ок для инкремента; перед мержем фичи — хост + хотя бы один call-site после `fold`.
- Статус: open

### Чеклист перед merge

- [x] Переименовать `dimiss` → `dismiss`
- [x] Отменять предыдущий таймер автоскрытия
- [x] Решить повторный показ идентичного `Failure`
- [x] Выровнять API/`docs` (`show(failure: …)` named)
- [ ] После правок — `dart run build_runner build --delete-conflicting-outputs` (если менялся API провайдера)

---

## Ревью #2 — 2026-10-16 (повторный проход)

### Вердикт

**Approve.** Актуальный код (64 строки): `ErrorBannerState` (только `Failure`), `Timer` с отменой, `timeoutSeconds = 0` + `> 0`. Блокеров нет.

### Статус прошлых findings

| Finding | Статус |
| --- | --- |
| `dimiss` → `dismiss` | **fixed** |
| Гонка auto-dismiss | **fixed** (`Timer` + `cancel`) |
| Повтор того же `Failure` | **fixed иначе** — не через `id`, а через plain `ErrorBannerState` (identity `==`) |
| Named `show` vs доки | **частично** — в dartdoc провайдера named; `error-display.mdc` / §10.5 всё ещё `show(failure)` и `Failure?` |
| `timeoutSeconds` / `<= 0` | **fixed** по сути (`default 0`, таймер только при `> 0`) |
| Нет хоста | **open** |

### Почему повторный `show` ок без `id`

`ErrorBannerState` — обычный класс без своего `==` → сравнение по identity. Каждый `show` делает `new ErrorBannerState(...)` → `old != new` → Riverpod нотифицирует, даже если внутри тот же Freezed-`Failure`.

`id` для нотификации не нужен. Для повторной анимации тоста в хосте по-прежнему полезен `ValueKey` (например `ObjectKey(banner)` или свой epoch) — это зона UI, не провайдера.

### Findings (новые / актуальные)

#### [minor] Дрейф `error-display.mdc` / §10.5 относительно кода
- Где: правило и `architecture_echat.md` §10.5 — стейт как `Failure?`, вызов `show(failure)`
- Что: код — `ErrorBannerState?`, `show({required Failure failure, int timeoutSeconds = 0})`
- Почему: агенты и люди копируют устаревший контракт
- Статус: open

#### [suggestion] `.g.dart` со старым dartdoc («Failure?»)
- Где: `error_banner_provider.g.dart` (скопированный class-doc)
- Что: текст про `Failure?` не совпадает с текущим комментарием класса
- Почему: нужен `build_runner` после смены API/доков класса
- Статус: open

#### [suggestion] `Duration?` вместо `int timeoutSeconds`
- Где: `show`
- Что: работает; `Duration` идиоматичнее во Flutter
- Статус: open (не блокер)

#### [info] Нет хоста / call-site в `lib/`
- Где: grep по `errorBannerProvider` / `TErrorToast`
- Что: только провайдер + codegen
- Статус: open (WIP)

#### [info] `ErrorBannerState` с одним полем
- Где: `ErrorBannerState { failure }`
- Что: по сути обёртка ради identity-equality (и будущего расширения)
- Почему: оправдано; возвращать сырой `Failure?` снова откроет silent skip на Freezed-`==`
- Статус: accepted

### Чеклист

- [ ] Синхронизировать `error-display.mdc` (+ при желании §10.5) с `ErrorBannerState?` / named `show`
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] При подключении хоста — `ValueKey` для повторной анимации

---

## Ревью #3 — 2026-10-16 (перепроверка)

### Вердикт

**Approve.** Код провайдера без изменений по сути с ревью #2; блокеров нет. `.g.dart` после `build_runner` синхронизирован (`ErrorBannerState?`, актуальный dartdoc).

### Код (проверка)

- `ErrorBannerState` — plain, только `Failure` → identity `==` → повторный `show` нотифицирует
- `Timer?` cancel в `show`/`dismiss`; `timeoutSeconds = 0`, таймер при `> 0`
- `keepAlive: true`, канал задокументирован, без `String` в state
- Потребителей/`TErrorToast` в `lib/` по-прежнему нет

### Findings

| Finding | Статус |
| --- | --- |
| `.g.dart` stale dartdoc | **fixed** (build_runner) |
| Дрейф docs/rules (`Failure?`, `show(failure)`) vs код | **open** — `architecture_echat.md` §10.5 и дерево файлов; `error-display.mdc` в workspace не найден (path missing) |
| `Duration?` vs `int` | open (suggestion) |
| Нет хоста | open (info) |

### Чеклист

- [x] `build_runner` — `.g.dart` актуален
- [ ] Выровнять `docs/architecture_echat.md` (§10.5, дерево) под `ErrorBannerState?` / named `show`
- [ ] Восстановить/обновить `error-display.mdc`, если правило ещё нужно
- [ ] Хост + `ValueKey` при интеграции UI
