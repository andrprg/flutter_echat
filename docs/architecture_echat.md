# Архитектура приложения E-Chat

Документ фиксирует целевую архитектуру Flutter-проекта **flutter_echat** с обязательным стеком:

| Технология | Роль |
| --- | --- |
| **Riverpod 3** + **аннотации** (`riverpod_annotation`) | DI, state management, реактивность UI |
| **Freezed** | Immutable-модели, union types, `copyWith` |
| **fpdart** | Функциональная обработка ошибок (`Either`, `Option`, `TaskEither`) |

Связанные документы: [firebase-database.md](./firebase-database.md), [firebase-setup.md](./firebase-setup.md), [firebase-registration.md](./firebase-registration.md), [firebase-flutter-connect.md](./firebase-flutter-connect.md), [firebase-events.md](./firebase-events.md).

Шпаргалки по стеку: [dart-riverpod.md](./dart-riverpod.md), [dart-fpdart.md](./dart-fpdart.md), [dart-freezed.md](./dart-freezed.md), [dart-classes.md](./dart-classes.md), [dart-future.md](./dart-future.md), [dart-stream.md](./dart-stream.md), [dart-map-enum.md](./dart-map-enum.md).

---

## Содержание

1. [Принципы](#1-принципы)
2. [Слои](#2-слои)
3. [Умный / глупый компонент](#3-умный--глупый-компонент)
4. [Адаптивный UI (phone / tablet / desktop)](#4-адаптивный-ui-phone--tablet--desktop)
5. [Структура каталогов](#5-структура-каталогов)
6. [Riverpod 3](#6-riverpod-3)
7. [Freezed](#7-freezed)
8. [fpdart](#8-fpdart)
9. [Поток данных](#9-поток-данных)
10. [Ошибки и Result](#10-ошибки-и-result)
11. [Features (модули)](#11-features-модули)
12. [Code generation](#12-code-generation)
13. [Тестирование](#13-тестирование)
14. [Правила для команды](#14-правила-для-команды)

---

## 1. Принципы

1. **Feature-first** — код группируется по фичам (auth, chats, groups), а не по типам файлов глобально.
2. **Unidirectional data flow** — UI → Notifier/Controller → Repository → DataSource → Firebase.
3. **Immutable state** — состояние экрана и доменные модели только через Freezed.
4. **Явные ошибки** — публичные методы репозиториев возвращают `Future<Either<Failure, T>>`, не бросают исключения наружу.
5. **Smart / Dumb** — умный контейнер подписывается на Riverpod и передаёт данные/колбэки; глупые виджеты только рисуют UI (см. [§3](#3-умный--глупый-компонент)).
6. **Один Notifier — много раскладок** — phone / tablet / desktop делят один controller и state подфичи; отличается только компоновка глупых виджетов. Если на wide рядом два экрана (list + thread) — **smart-shell** компонует dumb из разных подпапок, не сливая Notifier’ы ([§4.3](#43-masterdetail-chats--groups)).
7. **Firebase изолирован** — прямых вызовов Firestore/Auth из `presentation` нет. Подписки (`snapshots`, `onValue`) только в DataSource; как отлаживать события — [firebase-events.md](./firebase-events.md).

**Целевые форм-факторы:** phone (портрет), tablet (≥600 dp), desktop / wide (≥1024 dp, Windows / macOS / web / large tablet landscape).

---

## 2. Слои

```
┌─────────────────────────────────────────────────────────┐
│  PRESENTATION                                           │
│  Smart screens → Dumb widgets / layouts                 │
│  @riverpod Notifiers (UI state)                         │
└──────────────────────────┬──────────────────────────────┘
                           │ ref.read / ref.watch
┌──────────────────────────▼──────────────────────────────┐
│  APPLICATION (optional)                                 │
│  Use cases — только если логика reused в 2+ features    │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│  DOMAIN                                                 │
│  Entities (Freezed), Repository interfaces, Failures    │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│  DATA                                                   │
│  Repository impl, DTO (Freezed + json), DataSources       │
└──────────────────────────┬──────────────────────────────┘
                           │
                    Firebase / Local
```

| Слой | Зависит от | Не знает о |
| --- | --- | --- |
| **Presentation (smart)** | Domain, Riverpod, Adaptive shell | Firestore SDK, DTO, layout-детали |
| **Presentation (dumb)** | Flutter widgets, domain entities (read-only props) | Riverpod, Repository, Firebase, breakpoints |
| **Domain** | fpdart, Freezed | Flutter, Firebase, Riverpod |
| **Data** | Domain, Firebase SDK | Widgets, Notifiers |

---

## 3. Умный / глупый компонент

Паттерн **Container / Presentational** (smart / dumb) — обязателен для всех feature-экранов, особенно при поддержке нескольких форм-факторов.

### 3.1. Роли

| Тип | Ответственность | Запрещено |
| --- | --- | --- |
| **Smart** (`*_screen.dart`, `*_page.dart`, shell) | `ref.watch` / `ref.read`, выбор layout по breakpoint, маппинг state → props, вызов Notifier | тяжёлая вёрстка списков/пузырей, копипаст UI под каждое устройство |
| **Dumb** (`*_view.dart`, `*_body.dart`, tiles, bubbles) | отрисовка по props + callbacks (`VoidCallback`, `ValueChanged`) | `WidgetRef`, `ref.watch`, вызовы repository, знание `AppBreakpoint` |
| **Notifier** (`*_controller.dart`) | бизнес/UI state, Either → state | MediaQuery, BuildContext layout, «это tablet?» |

### 3.2. Поток в presentation

```
Breakpoint / WindowSize
        │
        ▼
┌───────────────────┐     watch/read      ┌──────────────────┐
│  Smart Screen     │ ◄────────────────── │  @riverpod       │
│  ChatListScreen   │ ──────────────────► │  ChatListCtrl    │
└─────────┬─────────┘     actions         └──────────────────┘
          │ props + callbacks
          ▼
┌───────────────────┐
│  Dumb views       │  ChatListView (с параметрами)
│  + shared widgets │  TChatListTile, TChatBubble, …
└───────────────────┘
```

### 3.3. Правила

1. **Один smart на route/feature-экран** — точка входа; внутри — только orchestration. Для master–detail (list + thread на одном wide-экране) точка входа — **smart-shell** (`ChatsShellScreen`), который компонует dumb из разных подпапок (§4.3).
2. **Dumb не импортирует `flutter_riverpod`** — тестируется `pumpWidget` без `ProviderScope`.
3. **Shared dumb** живут в `src/shared/widgets/` или `feature/.../widgets/`; параметры адаптивности передаются во `*_view.dart`; split — `TwoPane` / `ThreePane` в `shared/layouts/`.
4. **Не плодить Notifier на форм-фактор** — `ChatListController` / `ChatThreadController` по одному на подфичу; phone и desktop получают те же state. Не сливать list+thread в один Notifier «для desktop».
5. **Колбэки вместо side-effects в dumb** — `onChatTap(chatId)`, `onSend(text)`; навигацию и snackbar делает smart / shell.

### 3.4. Пример

```dart
// SMART — знает Riverpod и breakpoint
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(chatListControllerProvider);
    final breakpoint = ref.watch(appBreakpointProvider);

    return asyncState.when(
      loading: () => const ChatListShimmer(),
      error: (err, _) => ErrorView(
        message: err is Failure ? err.displayMessage : 'Unknown error',
        onRetry: () => ref.invalidate(chatListControllerProvider),
      ),
      data: (state) {
        // Или ResponsiveBuilder(phone: …, tablet: …, desktop: …) — §4.1.1
        // В нашем варианте просто параметризуем View
        return ChatListView(
          state: state,
          isDense: breakpoint != AppBreakpoint.phone,
          contentPadding: breakpoint == AppBreakpoint.phone
              ? const EdgeInsets.symmetric(horizontal: 16)
              : const EdgeInsets.symmetric(horizontal: 24),
          onSearchChanged: (q) =>
              ref.read(chatListControllerProvider.notifier).setSearchQuery(q),
          onChatTap: (id) => ref.read(appRouterProvider).go('/chats/$id'),
        );
      },
    );
  }
}

// DUMB — только UI
class ChatListView extends StatelessWidget {
  const ChatListView({
    super.key,
    required this.state,
    required this.onSearchChanged,
    required this.onChatTap,
    this.isDense = false,
    this.contentPadding = const EdgeInsets.all(16),
  });

  final ChatListState state;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onChatTap;
  final bool isDense;
  final EdgeInsets contentPadding;

  @override
  Widget build(BuildContext context) {
    // список, search field, empty state — без ref
    ...
  }
}
```

### 3.5. Пример: страница регистрации (auth / register)

Страница регистрации живёт в фиче `features/auth/presentation/register/` и строится по той же схеме smart/dumb, что и Login ([§3.4](#34-пример)): один `@riverpod` Notifier на все ширины, на широких экранах форма ограничена `MaxWidthBox`.

```dart
// register_state.dart
@freezed
abstract class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default('') String name,
    @Default('') String phone,
    @Default('') String password,
    @Default(false) bool isSubmitting,
    @Default(false) bool agreedToTerms,
    Failure? error,
  }) = _RegisterState;
}
```

```dart
// register_controller.dart
@riverpod
class RegisterController extends _$RegisterController {
  @override
  RegisterState build() => const RegisterState();

  void setName(String v) => state = state.copyWith(name: v);
  void setPhone(String v) => state = state.copyWith(phone: v);
  void setPassword(String v) => state = state.copyWith(password: v);
  void setAgreedToTerms(bool v) => state = state.copyWith(agreedToTerms: v);

  Future<void> submit() async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await ref.read(authRepositoryProvider).register(
          name: state.name,
          phone: state.phone,
          password: state.password,
        );
    state = state.copyWith(isSubmitting: false);
    result.fold(
      (failure) => state = state.copyWith(error: failure),
      (_) => ref.read(appRouterProvider).go('/home'),
    );
  }
}
```

```dart
// register_screen.dart — SMART
class RegisterScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerControllerProvider);
    return MaxWidthBox(
      child: RegisterView(
        state: state,
        onNameChanged: (v) =>
            ref.read(registerControllerProvider.notifier).setName(v),
        onPhoneChanged: (v) =>
            ref.read(registerControllerProvider.notifier).setPhone(v),
        onPasswordChanged: (v) =>
            ref.read(registerControllerProvider.notifier).setPassword(v),
        onSubmit: () => ref.read(registerControllerProvider.notifier).submit(),
      ),
    );
  }
}
```

**Dumb `RegisterView`** получает только `RegisterState` + колбэки: поля Name / Phone / Password, чекбокс Terms, кнопка Register, сообщение об ошибке из `state.error.displayMessage`. Без `WidgetRef`, без вызова repository (см. [§3.3](#33-правила)).

**Правила:** на phone — full-height скролл-форма; на wide — центрированная колонка с `maxWidth`. Ошибки — только через sealed `Failure` (§10); переход после успеха — на `/home`.

Вызов Firebase: не из smart/dumb, а через `AuthRepository` / DataSource — [firebase-registration.md](./firebase-registration.md).

---

## 4. Адаптивный UI (phone / tablet / desktop)

### 4.1. Breakpoints

| Имя | Ширина (logical px) | Типичная оболочка |
| --- | --- | --- |
| `phone` | `< 600` | Bottom NavigationBar |
| `tablet` | `600 … 1023` | NavigationRail + опционально master–detail |
| `desktop` | `≥ 1024` | NavigationRail / Sidebar + master–detail + secondary pane |

Источник ширины: `MediaQuery.sizeOf(context)` или `Window` (desktop/web). Значение публикуется как `@riverpod` `appBreakpointProvider`, чтобы smart-экраны не дублировали пороги.

### 4.1.1. `ResponsiveBuilder`

В том же файле `utils/providers/app_breakpoint_provider.dart` лежит smart-helper `ResponsiveBuilder` — `ConsumerWidget`, который читает `appBreakpointProvider` и возвращает нужный child.

| Параметр | Обязателен | Fallback |
| --- | --- | --- |
| `phone` | да | — |
| `tablet` | нет | `phone` |
| `desktop` | нет | `tablet` → `phone` |

```dart
// utils/providers/app_breakpoint_provider.dart — использование в smart
return ResponsiveBuilder(
  phone: ChatListView(isDense: false, ...),
  tablet: ChatListView(isDense: true, ...),
  desktop: ChatListView(isDense: true, ...),
);
```

Эквивалент вручную: `ref.watch(appBreakpointProvider)` + `switch` (см. §3.4, §4.6). Оба способа допустимы; `ResponsiveBuilder` удобен, когда нужна только смена child без дополнительной логики вокруг breakpoint.

**Не использовать** в dumb (`*_view.dart`, `shared/widgets`) — helper сам подписан на Riverpod.

### 4.2. Navigation shell

| Форм-фактор | Shell | Стек чатов |
| --- | --- | --- |
| Phone | 4 вкладки снизу: Chats \| Groups \| Profile \| More | push route `/chats/:id` поверх списка |
| Tablet | NavigationRail слева | master–detail: список + thread в одном shell |
| Desktop | широкий rail / sidebar + optional right pane (info) | master–detail + панель информации о чате |

**Правило:** маршруты (`/chats`, `/chats/:id`) общие; меняется только то, как shell **вкладывает** дочерние routes (nested navigator / `StatefulShellRoute` + split view).

### 4.3. Master–detail (chats / groups)

На phone список диалогов и переписка — **разные полноэкранные маршруты**. На tablet/desktop они должны быть **на одном экране рядом**, оставаясь в **разных подпапках** presentation (`chat_list/` и `chat_thread/`). Не склеивать две подфичи в один «супер-экран» и не копировать их в `tablet/` / `desktop/`.

**Решение:** третий **smart-shell** только оркестрирует — подписывается на оба Notifier’а, читает breakpoint + `selectedChatId` из `go_router` и компонует уже готовые **dumb**-views.

```
┌────────┬──────────────┬─────────────────┬────────────┐
│ Rail   │ Chat list    │ Thread          │ Info       │  desktop
│        │ (dumb)       │ (dumb)          │ (optional) │
└────────┴──────────────┴─────────────────┴────────────┘

┌────────┬──────────────┬─────────────────┐
│ Rail   │ Chat list    │ Thread          │  tablet
└────────┴──────────────┴─────────────────┘

┌──────────────────────┐
│ Chat list            │  phone → tap → full-screen thread
└──────────────────────┘
```

#### Роли файлов

| Роль | Где | Что делает |
| --- | --- | --- |
| Список (колонка 1) | `presentation/chat_list/` | свой `ChatListController` + `ChatListState` + dumb `ChatListView` |
| Переписка (колонка 2) | `presentation/chat_thread/` | свой `ChatThreadController` + `ChatThreadState` + dumb `ChatThreadView` |
| Оболочка | `presentation/shell/chats_shell_screen.dart` | **SMART:** breakpoint + `selectedChatId` → phone stack или `TwoPane` / `ThreePane` |

Оба контроллера остаются **отдельными** (не один «desktop-controller»). Dumb **не знает** про соседнюю колонку, Riverpod и breakpoints — только props + callbacks. Shell **не** содержит тяжёлую вёрстку списка/пузырей — только композицию.

Структура (оба экрана — подфичи **одной** feature `chats`, не top-level features):

```
features/chats/presentation/
├── shell/
│   └── chats_shell_screen.dart   # SMART master–detail
├── chat_list/
│   ├── chat_list_view.dart       # DUMB
│   ├── chat_list_controller.dart
│   └── chat_list_state.dart
└── chat_thread/
    ├── chat_thread_view.dart     # DUMB
    ├── chat_thread_controller.dart
    └── chat_thread_state.dart
```

Тонкие `chat_list_screen.dart` / `chat_thread_screen.dart` допустимы как smart-обёртки для phone full-screen маршрутов; на tablet/desktop точку входа вкладки держит **`ChatsShellScreen`**, который сам маппит оба controller → dumb-views (см. §4.6, §4.8).

#### Маршруты (общие для всех ширин)

| Маршрут | Phone | Tablet / Desktop |
| --- | --- | --- |
| `/chats` | только `ChatListView` | `TwoPane(list \| empty placeholder)` |
| `/chats/:id` | только `ChatThreadView` (push) | `TwoPane(list \| ChatThreadView)` — список **не** уезжает |

```dart
// chats_shell_screen.dart — SMART-композитор
class ChatsShellScreen extends ConsumerWidget {
  const ChatsShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(chatListControllerProvider);
    final threadAsync = ref.watch(chatThreadControllerProvider);
    final breakpoint = ref.watch(appBreakpointProvider);
    final chatId = GoRouterState.of(context).pathParameters['id'];

    final list = listAsync.when(
      loading: () => const ChatListShimmer(),
      error: (e, _) => ErrorView(
        message: (e as Failure).displayMessage,
        onRetry: () => ref.invalidate(chatListControllerProvider),
      ),
      data: (state) => ChatListView(
        state: state,
        onChatTap: (id) => context.go('/chats/$id'),
        onSearchChanged: (q) =>
            ref.read(chatListControllerProvider.notifier).setSearchQuery(q),
      ),
    );

    final thread = chatId == null
        ? const EmptyChatPlaceholder()
        : threadAsync.when(
            loading: () => const ChatThreadShimmer(),
            error: (e, _) => ErrorView(
              message: (e as Failure).displayMessage,
              onRetry: () => ref.invalidate(chatThreadControllerProvider),
            ),
            data: (state) => ChatThreadView(
              state: state,
              onSend: (text) =>
                  ref.read(chatThreadControllerProvider.notifier).send(text),
            ),
          );

    return switch (breakpoint) {
      AppBreakpoint.phone =>
        chatId == null ? list : thread, // один child на весь экран
      AppBreakpoint.tablet || AppBreakpoint.desktop =>
        TwoPane(master: list, detail: thread),
    };
  }
}
```

#### Как `ChatsShellScreen` выбирает phone / tablet / desktop

Краткий ответ: **не** отдельными файлами «для mobile/tablet/desktop», а одним smart-shell по двум входам — `appBreakpointProvider` и route (`chatId`).

**1. Откуда берётся форм-фактор**

Ширина окна → `AppBreakpoint` через `appBreakpointProvider` (пороги в `TBreakpoints` / `appBreakpointFromWidth`):

| `AppBreakpoint` | Ширина (dp) |
| --- | --- |
| `phone` | &lt; 600 |
| `tablet` | 600 … 1023 |
| `desktop` | ≥ 1024 |

Smart-экраны **не** читают пороги из `MediaQuery` напрямую — только `ref.watch(appBreakpointProvider)`. Dumb (`*_view`) breakpoints **не знает**.

**2. Что читает shell**

| Вход | Откуда | Зачем |
| --- | --- | --- |
| Breakpoint | `appBreakpointProvider` | phone stack vs `TwoPane` / `ThreePane` |
| Выбранный чат | `GoRouterState.pathParameters['id']` | list vs thread (phone) или empty vs thread (detail) |
| Данные списка | `chatListControllerProvider` | props → `ChatListView` |
| Данные переписки | `chatThreadControllerProvider` | props → `ChatThreadView` |

**3. Что возвращает `switch`**

| Breakpoint | `/chats` (`chatId == null`) | `/chats/:id` |
| --- | --- | --- |
| `phone` | только `ChatListView` | только `ChatThreadView` (один child на весь экран) |
| `tablet` / `desktop` | `TwoPane(list \| EmptyChatPlaceholder)` | `TwoPane(list \| ChatThreadView)` — список **остаётся** |

На phone и wide **одни и те же** controllers и dumb-views; отличается только композиция оболочки. Для desktop с info-pane shell может отдать `ThreePane` вместо `TwoPane` — выбор по-прежнему в smart-shell по `AppBreakpoint` (см. §4.6).

Развёрнутый разбор потока и схемы — [§4.6](#46-практический-разбор-как-выбирается-верстка-на-примере-featurechats).

Тот же паттерн для `groups`: `GroupsShellScreen` + `GroupListView` + переиспользование `ChatThreadView` (или `GroupThreadView`). Layout-обёртки `TwoPane` / `ThreePane` — dumb в `src/shared/layouts/`.

### 4.4. Что не адаптировать отдельно

- Domain, Data, Notifiers, Failure — **форм-фактор-агностичны**.
- Мелкие формы, модалки — часто один layout с `ConstrainedBox` / `maxWidth` на desktop.
- Тема, локализация, design tokens — общие; меняются spacing / density / max content width.

### 4.5. Платформы

| Платформа | Ожидание |
| --- | --- |
| Android / iOS phone | phone layout |
| Android / iOS tablet | tablet (или desktop в landscape при ≥1024) |
| Windows / macOS / Linux | desktop layout |
| Web | breakpoints по ширине окна |

Firebase / WebRTC / file picker могут отличаться по платформе в **Data** или `src/utils/device/`, не в dumb-виджетах.

### 4.6. Практический разбор: как выбирается верстка на примере feature/chats

Ниже — сквозной ответ на вопрос «как и где выбирается верстка для phone / tablet / desktop», привязанный к фиче `chats`. Этот раздел описывает **целевую структуру**: каркас — `lib/src/` (`app.dart`, `utils/`, `features/`, `shared/`); фичу `chats` предстоит реализовать по этому плану.

#### 1. Где живут breakpoints и как определяется форм-фактор

Единая точка правды для порогов — `src/utils/constants/` + провайдер в `src/utils/providers/`:

| Файл | Что делает |
| --- | --- |
| `utils/constants/breakpoints.dart` | `enum AppBreakpoint { phone, tablet, desktop }` + пороги `TBreakpoints` |
| `utils/providers/app_breakpoint_provider.dart` | `@riverpod appBreakpointProvider` + smart-helper `ResponsiveBuilder` |

Пороги: `phone` `< 600`, `tablet` `600 … 1023`, `desktop` `≥ 1024`. Источник ширины — `MediaQuery.sizeOf(context)` или `Window` на desktop/web. Провайдер пересчитывает это значение один раз; smart-экраны пороги не дублируют (прямой `MediaQuery` в фичах запрещён, см. §14 DON'T). API `ResponsiveBuilder` — в [§4.1.1](#411-responsivebuilder).

#### 2. Кто выбирает верстку — Smart-экран

Выбор делает **smart**-компонент по breakpoint — это суть принципа «Один Notifier — много раскладок» (§1 п.6, §3.3 п.4): controller и state общие, отличается только компоновка глупых виджетов. Два равноправных способа:

```dart
// Вариант A — ResponsiveBuilder (предпочтительно, если нужен только child)
return ResponsiveBuilder(
  phone: ChatListView(isDense: false, ...),
  tablet: ChatListView(isDense: true, ...),
  desktop: ChatListView(isDense: true, ...),
);

// Вариант B — явный switch (когда вокруг breakpoint есть доп. логика)
final breakpoint = ref.watch(appBreakpointProvider);
return switch (breakpoint) {
  AppBreakpoint.phone   => ChatListView(isDense: false, ...),
  AppBreakpoint.tablet  => ChatListView(isDense: true, ...),
  AppBreakpoint.desktop => ChatListView(isDense: true, ...),
};
```

Для **одиночного** экрана (только список или только форма) этого достаточно. Для **master–detail** (список + переписка) точка входа — `ChatsShellScreen` (§4.3): он выбирает не «обёртку вокруг одного view», а **композицию** двух dumb из разных подпапок.

Алгоритм для вкладки `chats`:

1. Smart-shell `ChatsShellScreen` подписывается на `chatListControllerProvider` и `chatThreadControllerProvider` (два Notifier’а, не один).
2. Собирает dumb `ChatListView` и `ChatThreadView` с props + колбэками (`onSearchChanged`, `onChatTap`, `onSend`).
3. Читает `appBreakpointProvider` + `pathParameters['id']` из `go_router`.
4. **Phone:** один child на весь экран — list (`/chats`) или thread (`/chats/:id`).
5. **Tablet / Desktop:** `TwoPane(master: list, detail: thread | EmptyChatPlaceholder)`; навигация — `context.go('/chats/$id')` без ухода списка.

#### 3. Где находятся сами верстки (для chats)

Верстки — **dumb**-компоненты в `features/chats/presentation/`:

```
features/chats/presentation/
├── shell/
│   └── chats_shell_screen.dart      # SMART: master–detail, собирает list + thread
├── chat_list/
│   ├── chat_list_screen.dart        # SMART (phone full-screen / тонкая обёртка)
│   ├── chat_list_view.dart          # DUMB — список/поиск/empty state
│   ├── chat_list_controller.dart    # один Notifier на все форм-факторы
│   └── chat_list_state.dart
├── chat_thread/
│   ├── chat_thread_screen.dart      # SMART (phone full-screen / тонкая обёртка)
│   ├── chat_thread_view.dart        # DUMB
│   ├── chat_thread_controller.dart
│   └── chat_thread_state.dart
└── widgets/                         # DUMB feature-widgets: TChatListTile, TChatBubble, …
```

Папки `mobile/`, `tablet/`, `desktop/` с копиями целых фич **не создаются** — только разные композиции одних dumb (§5). Переиспользуемые обёртки — в `src/shared/layouts/`: `MaxWidthBox`, `TwoPane`, `ThreePane`.

Поведение по форм-фактору:

- phone: одна колонка; `/chats` → list, `/chats/:id` → full-screen thread.
- tablet: `NavigationRail` слева + master–detail (`TwoPane`: список + переписка).
- desktop: широкий rail/sidebar + optional right pane (инфо о чате) + master–detail (`ThreePane` при необходимости).

На tablet/desktop `ChatsShellScreen` собирает `TwoPane(list + thread)` по `selectedChatId` + breakpoint (§4.3, §9). Не объединять `chat_list` и `chat_thread` в один controller/state «для desktop».

#### 4. Поток выбора верстки (схема)

```mermaid
flowchart LR
    W[MediaQuery sizeOf / Window] --> P[appBreakpointProvider]
    P --> S[ChatsShellScreen Smart]
    R[go_router /chats/:id] --> S
    S --> B{AppBreakpoint}
    B -->|phone| One[один child: list или thread]
    B -->|tablet desktop| Two[TwoPane master + detail]
    S --> CL[ChatListController]
    S --> CT[ChatThreadController]
    CL --> LV[ChatListView Dumb]
    CT --> TV[ChatThreadView Dumb]
    One --> LV
    One --> TV
    Two --> LV
    Two --> TV
```

**Резюме:** версию раскладки выбирает smart-shell `ChatsShellScreen`, читая `AppBreakpoint` и route; dumb `ChatListView` / `ChatThreadView` живут в разных подпапках и не знают друг о друге; у каждой подфичи свой Notifier и state на все форм-факторы; композиции — `shared/layouts/` (`TwoPane` / `ThreePane`).

### 4.7. Зачем нужен `chat_list_state.dart`

`chat_list_state.dart` — это **UI-состояние** фичи `chats`, описанное через Freezed. По архитектуре (§3, §7.4) каждый smart-экран имеет свою пару «state + controller».

**Зачем он нужен:** определяет, какие данные и флаги видит dumb-view `ChatListView`. Например:

```dart
// features/chats/presentation/chat_list/chat_list_state.dart
@freezed
abstract class ChatListState with _$ChatListState {
  const factory ChatListState({
    @Default(<Chat>[]) List<Chat> chats,
    @Default('') String query,
  }) = _ChatListState;
}
```

Роль в потоке данных:
- Controller (`chat_list_controller.dart`) держит это состояние в `AsyncValue<ChatListState>` и меняет его через `copyWith`: пришёл стрим чатов → обновились `chats`, пользователь печатает поиск → обновился `query` (§6.5).
- Smart (`ChatListScreen` на phone или `ChatsShellScreen` на wide) читает `ref.watch(chatListControllerProvider)` и в `data:` передаёт `ChatListState` в dumb-view.
- Dumb-view (`chat_list_view.dart`) получает `state` как props и только рисует по нему: фильтрация по `query`, рендер `chats`, empty state (§3.4).

Почему это важно (архитектурные принципы):
- **Immutable state** (§1 п.3) — только через Freezed, без мутируемого состояния.
- **Один state на все форм-факторы** (§1 п.6) — phone / tablet / desktop читают один и тот же `ChatListState`; сам файл форм-фактор-агностичен и не знает про breakpoints.
- **Smart/Dumb разделение** (§3.1) — dumb не знает про Riverpod и репозиторий, он знает только `ChatListState` + колбэки, поэтому тестируется простым `pumpWidget` без `ProviderScope` (§13).

**Резюме:** `chat_list_state.dart` — единый immutable «снимок» данных и UI-флагов экрана списка чатов, создаётся controller'ом, передаётся smart'ом в dumb-view и одинаков для всех трёх раскладок.

### 4.8. Что делают `chat_list_screen.dart`, `chat_list_view.dart` и shell

Пара «smart screen + dumb view» — ядро паттерна Smart/Dumb (§3) для **одной** подфичи (список). Master–detail на wide собирает **третий** smart — `ChatsShellScreen` (§4.3). Это **целевая структура**: каркас `lib/src/` уже есть; фичу `chats` предстоит реализовать по этому плану (§4.6).

#### `chat_list_screen.dart` — SMART-компонент (список)

Расположение: `features/chats/presentation/chat_list/chat_list_screen.dart`. «Умный контейнер» **только для списка**: подписывается на Riverpod списка, маппит state → props. На phone может быть builder маршрута `/chats`; на tablet/desktop ту же сборку `ChatListView` делает `ChatsShellScreen` (чтобы рядом положить thread). Полный пример одиночного smart — [§3.4](#34-пример).

Что он делает:

1. **Подписывается на состояние** — `ref.watch(chatListControllerProvider)` (`AsyncValue<ChatListState>`).
2. **Обрабатывает три состояния `AsyncValue`:**
   - `loading:` → `ChatListShimmer`;
   - `error:` → `ErrorView` с текстом из `Failure.displayMessage` и `onRetry` → `ref.invalidate(chatListControllerProvider)`;
   - `data:` → собирает dumb-view `ChatListView`.
3. **Маппит state → props + callbacks**:
   - `state: state`,
   - `onSearchChanged: (q) => ref.read(chatListControllerProvider.notifier).setSearchQuery(q)`,
   - `onChatTap: (id) => context.go('/chats/$id')` — навигацию делает smart, не dumb.
4. **Не** содержит вёрстку пузырей и **не** знает про `ChatThreadView` — соседнюю колонку компонует только shell (§4.3).

Аналогично `chat_thread_screen.dart` — smart только для переписки (phone `/chats/:id` или маппинг внутри shell).

#### `chat_list_view.dart` — DUMB-компонент

Расположение: `features/chats/presentation/chat_list/chat_list_view.dart`. Это «глупый» виджет — **только рисует UI по полученным props**. Пример — [§3.4](#34-пример).

Что он делает:

1. **Принимает данные как props**: `ChatListState state` + колбэки `ValueChanged<String> onSearchChanged`, `ValueChanged<String> onChatTap`.
2. **Рендерит интерфейс списка чатов**: сам список, поле поиска, empty state («No chats»); фильтрация чатов по `query` из `state` выполняется здесь.
3. **Не знает ни о Riverpod, ни о репозитории, ни о Firebase, ни о соседней колонке thread** — правило §3.3 п.2 и §14 DON'T: dumb не импортирует `flutter_riverpod`, не использует `WidgetRef`, не вызывает `MediaQuery` и не знает про breakpoints.
4. **Все действия отдаёт через колбэки** — side-effects (навигация, snackbar, вызовы Notifier) делает smart / shell.

#### `chats_shell_screen.dart` — SMART-композитор (list + thread)

На tablet/desktop (и как единая точка входа вкладки) shell:

1. `ref.watch` обоих controllers + `appBreakpointProvider` + `chatId` из route.
2. Собирает те же dumb `ChatListView` и `ChatThreadView` (или делегирует тонким screen-обёрткам).
3. Phone → один child; wide → `TwoPane` / `ThreePane` из `shared/layouts/`.

Код и таблица маршрутов — [§4.3](#43-masterdetail-chats--groups).

#### Взаимосвязь (паттерн Smart/Dumb + shell)

```mermaid
flowchart LR
    CL[ChatListController] --> Shell[ChatsShellScreen Smart]
    CT[ChatThreadController] --> Shell
    BP[AppBreakpoint] --> Shell
    Route["/chats/:id"] --> Shell
    Shell -->|props + callbacks| LV[ChatListView Dumb]
    Shell -->|props + callbacks| TV[ChatThreadView Dumb]
    Shell -->|phone| One[один child]
    Shell -->|tablet desktop| Two[TwoPane]
    One --> LV
    One --> TV
    Two --> LV
    Two --> TV
```

#### Ключевые правила

| Правило | Реализация |
| --- | --- |
| Разные подпапки, один экран на wide (§4.3) | shell компонует dumb из `chat_list/` и `chat_thread/` |
| Dumb без Riverpod (§3.3 п.2) | `ChatListView` / `ChatThreadView` — без `ref` |
| Два Notifier’а, не один «для desktop» (§3.3 п.4) | list и thread controllers раздельно; каждый на все форм-факторы |
| Колбэки вместо side-effects (§3.3 п.5) | `onChatTap`, `onSearchChanged`, `onSend` |
| Immutable state (§1 п.3) | Freezed `ChatListState` / `ChatThreadState` |
| Общие маршруты (§4.2) | `/chats`, `/chats/:id` — phone stack / wide split |

**Резюме:** `chat_list_view` и `chat_thread_view` — переиспользуемые dumb из разных папок; на phone их показывают отдельные smart-screen или один child shell; на desktop **не** мержат фичи — `ChatsShellScreen` кладёт оба view в `TwoPane` и оставляет два независимых Notifier’а.

### 4.9. Где находится вёрстка Bottom Navigation Bar

Bottom Navigation Bar — это **dumb-компонент**, который по архитектуре живёт в `src/shared/widgets/`, потому что это переиспользуемый виджет уровня приложения (не фичи).

#### Вёрстка самого бара

```
lib/src/shared/widgets/t_bottom_nav_bar.dart # DUMB TBottomNavBar: 4 вкладки Chats|Groups|Profile|More (phone)
```

Файл добавлен в структуру каталогов в [§5](#5-структура-каталогов). Это глупый виджет: без Riverpod, без `ref`, без `MediaQuery`. Он получает от smart-shell данные через props (выбранную вкладку + `onDestinationSelected`) и просто рисует `BottomNavigationBar` — тело бара и пункты вкладок.

#### Кто выбирает, что показывать (smart-слой)

Сама вёрстка бара — dumb, но **решение, когда показывать bar или rail**, принимает умный shell:

```
lib/src/utils/router/nav_shell.dart       # SMART UI: BottomNavBar (Phone) / NavigationRail (Wide)
lib/src/utils/router/app_router.dart      # CONFIG: GoRouter tree & Auth Guards
```

Здесь читается `appBreakpointProvider` (в `nav_shell.dart`, см. §4.1):

- `phone` → dumb `TBottomNavBar` из `src/shared/widgets/t_bottom_nav_bar.dart`;
- `tablet` / `desktop` → dumb `TNavigationRail` (в том же `shared/widgets/`).

*Совет на будущее:* Если проект сильно разрастётся, маршруты фич (из `app_router.dart`) можно будет разбить на отдельные файлы (например, `chats_routes.dart`), чтобы `app_router.dart` собирал их как модули. Также можно использовать библиотеку `go_router_builder` для кодогенерации типизированных маршрутов.

#### Схема

```mermaid
flowchart LR
    BP[appBreakpointProvider] --> NS[nav_shell.dart Smart]
    NS -->|phone| BBN[t_bottom_nav_bar.dart TBottomNavBar]
    NS -->|tablet desktop| NR[NavigationRail Dumb]
    BBN -->|StatefulShellRoute| Tabs[Chats Groups Profile More]
    NR --> Tabs
```

**Резюме:** вёрстка Bottom Navigation Bar находится в dumb-виджете `TBottomNavBar` (`src/shared/widgets/t_bottom_nav_bar.dart`) — там тело бара и пункты вкладок; а умная логика выбора между bar и rail — в `utils/router/nav_shell.dart`. Дерево маршрутов и Auth Guards лежат отдельно в `utils/router/app_router.dart`. Так соблюдается правило «Smart выбирает раскладку, Dumb её рисует» (§3.1).

---

## 5. Структура каталогов

```
lib/
├── main.dart
└── src/
    ├── app.dart                     # MaterialApp, тема, router
    │
    ├── utils/
    │   ├── exceptions/              # исключения / Failure
    │   ├── constants/               # размеры, цвета, breakpoints
    │   │   ├── colors.dart          # TColors
    │   │   ├── sizes.dart           # TSizes
    │   │   └── breakpoints.dart     # AppBreakpoint, TBreakpoints
    │   ├── device/                  # функции устройства
    │   ├── formatters/              # форматирование
    │   ├── helpers/                 # вспомогательные функции
    │   ├── logging/                 # логирование
    │   ├── theme/                   # темы приложения
    │   │   ├── theme.dart           # TAppTheme (light / dark)
    │   │   └── widget_themes/       # темы отдельных виджетов
    │   │       ├── appbar_theme.dart
    │   │       ├── bottom_navigator_bar_theme.dart
    │   │       ├── elevated_button_theme.dart
    │   │       ├── snack_bar_theme.dart
    │   │       ├── switch_theme.dart
    │   │       ├── tabbar_theme.dart
    │   │       ├── text_field_theme.dart
    │   │       └── text_theme.dart
    │   ├── validators/              # валидаторы
    │   ├── router/                  # go_router
    │   │   ├── app_router.dart      # CONFIG: GoRouter tree & Auth Guards
    │   │   └── nav_shell.dart       # SMART UI: BottomNavBar (Phone) / NavigationRail (Wide)
    │   └── providers/               # общие Riverpod-провайдеры
    │       └── app_breakpoint_provider.dart  # appBreakpointProvider + ResponsiveBuilder
    │
    ├── shared/
    │   ├── widgets/                 # DUMB: TChatButton, TAvatar, TChatBubble…
    │   │   └── t_bottom_nav_bar.dart  # DUMB: TBottomNavBar — 4 вкладки (phone)
    │   └── layouts/                 # DUMB: общие layout-обёртки (не feature-specific)
    │       ├── max_width_box.dart   # MaxWidthBox — формы auth/profile/more на desktop
    │       ├── two_pane.dart        # TwoPane — master–detail (chats/groups, tablet+)
    │       └── three_pane.dart      # ThreePane — list | thread | info (desktop)
    │
    └── features/
        ├── auth/
        │   ├── domain/
        │   │   ├── entities/
        │   │   │   └── auth_user.dart
        │   │   └── repositories/
        │   │       └── auth_repository.dart
        │   ├── data/
        │   │   ├── datasources/
        │   │   │   └── auth_remote_datasource.dart
        │   │   ├── dto/
        │   │   │   └── user_dto.dart
        │   │   └── repositories/
        │   │       └── auth_repository_impl.dart
        │   └── presentation/
        │       ├── login/
        │       │   ├── login_screen.dart      # SMART
        │       │   ├── login_view.dart        # DUMB
        │       │   ├── login_controller.dart
        │       │   └── login_state.dart
        │       └── register/
        │           ├── register_screen.dart   # SMART
        │           ├── register_view.dart     # DUMB
        │           ├── register_controller.dart
        │           └── register_state.dart
        │
        ├── chats/
        │   └── presentation/
        │       ├── shell/
        │       │   └── chats_shell_screen.dart   # SMART: phone → list|thread; wide → TwoPane/ThreePane из shared/layouts/
        │       ├── chat_list/
        │       │   ├── chat_list_screen.dart     # SMART (phone / тонкая обёртка)
        │       │   ├── chat_list_view.dart       # DUMB (Параметризованный)
        │       │   ├── chat_list_controller.dart
        │       │   └── chat_list_state.dart
        │       ├── chat_thread/
        │       │   ├── chat_thread_screen.dart   # SMART (phone / тонкая обёртка)
        │       │   ├── chat_thread_view.dart     # DUMB
        │       │   ├── chat_thread_controller.dart
        │       │   └── chat_thread_state.dart
        │       └── widgets/                      # DUMB feature widgets
        │
        ├── groups/                              # тот же master–detail, что chats (§4.3)
        │   ├── domain/
        │   │   ├── entities/
        │   │   │   └── group.dart               # или reuse Chat (type == group)
        │   │   └── repositories/
        │   │       └── group_repository.dart    # часто делегирует в ChatRepository
        │   ├── data/
        │   │   ├── datasources/
        │   │   │   └── group_remote_datasource.dart
        │   │   ├── dto/
        │   │   │   └── group_dto.dart
        │   │   └── repositories/
        │   │       └── group_repository_impl.dart
        │   └── presentation/
        │       ├── shell/
        │       │   └── groups_shell_screen.dart # SMART: list + thread (+ info на desktop)
        │       ├── group_list/
        │       │   ├── group_list_screen.dart   # SMART (phone / тонкая обёртка)
        │       │   ├── group_list_view.dart     # DUMB
        │       │   ├── group_list_controller.dart
        │       │   └── group_list_state.dart
        │       ├── group_thread/
        │       │   ├── group_thread_screen.dart # SMART (phone); можно reuse ChatThreadView
        │       │   ├── group_thread_view.dart   # DUMB (имя отправителя в ленте)
        │       │   ├── group_thread_controller.dart
        │       │   └── group_thread_state.dart
        │       ├── create_group/
        │       │   ├── create_group_screen.dart # SMART
        │       │   ├── create_group_view.dart   # DUMB: Name + Members
        │       │   ├── create_group_controller.dart
        │       │   └── create_group_state.dart
        │       ├── group_info/
        │       │   ├── group_info_screen.dart   # SMART (phone / detail pane)
        │       │   ├── group_info_view.dart     # DUMB: members, mute, roles
        │       │   ├── group_info_controller.dart
        │       │   └── group_info_state.dart
        │       └── widgets/                     # DUMB feature widgets
        │
        ├── profile/                             # вкладка Profile; desktop — MaxWidthBox
        │   ├── domain/
        │   │   ├── entities/
        │   │   │   └── user_profile.dart
        │   │   └── repositories/
        │   │       └── user_repository.dart
        │   ├── data/
        │   │   ├── datasources/
        │   │   │   └── user_remote_datasource.dart
        │   │   ├── dto/
        │   │   │   └── user_profile_dto.dart
        │   │   └── repositories/
        │   │       └── user_repository_impl.dart
        │   └── presentation/
        │       ├── profile/
        │       │   ├── profile_screen.dart      # SMART
        │       │   ├── profile_view.dart        # DUMB: аватар, имя, phone, eChatPublicId
        │       │   ├── profile_controller.dart
        │       │   └── profile_state.dart
        │       ├── edit_profile/
        │       │   ├── edit_profile_screen.dart # SMART
        │       │   ├── edit_profile_view.dart   # DUMB: имя, аватар, about
        │       │   ├── edit_profile_controller.dart
        │       │   └── edit_profile_state.dart
        │       └── widgets/                     # DUMB feature widgets
        │
        └── more/                                # вкладка More (настройки)
            ├── domain/
            │   ├── entities/
            │   │   └── user_settings.dart
            │   └── repositories/
            │       └── settings_repository.dart
            ├── data/
            │   ├── datasources/
            │   │   └── settings_remote_datasource.dart
            │   ├── dto/
            │   │   └── user_settings_dto.dart
            │   └── repositories/
            │       └── settings_repository_impl.dart
            └── presentation/
                ├── more/
                │   ├── more_screen.dart         # SMART: список пунктов настроек
                │   ├── more_view.dart           # DUMB
                │   ├── more_controller.dart
                │   └── more_state.dart
                ├── language/
                │   ├── language_screen.dart     # SMART (en/ru)
                │   ├── language_view.dart       # DUMB
                │   ├── language_controller.dart
                │   └── language_state.dart
                ├── theme/
                │   ├── theme_screen.dart        # SMART: ThemeMode + persist
                │   ├── theme_view.dart          # DUMB
                │   ├── theme_controller.dart
                │   └── theme_state.dart
                └── widgets/                     # DUMB: invite, help/about tiles…
```

**Layouts:**

| Где | Файлы / классы | Назначение |
| --- | --- | --- |
| `shared/layouts/` | `MaxWidthBox`, `TwoPane`, `ThreePane` | общие split / max-width обёртки |

Master–detail list+thread на wide по-прежнему собирает `ChatsShellScreen` через `TwoPane` / `ThreePane` (§4.3).

**Назначение `src/utils/`:**

| Папка | Содержимое |
| --- | --- |
| `exceptions/` | sealed `Failure` и прочие исключения домена/инфры |
| `constants/` | цвета (`TColors`), размеры (`TSizes`), breakpoints |
| `device/` | код работы с функциями устройства |
| `formatters/` | форматирование дат, телефонов и т.п. |
| `helpers/` | вспомогательные функции (в т.ч. adaptive helpers) |
| `logging/` | логирование |
| `theme/` | `TAppTheme` + `widget_themes/` (темы AppBar, Button, TextField…) |
| `validators/` | валидаторы форм |
| `router/` | конфиг `go_router`, Auth Guards, SMART shell (оболочка вкладок) |
| `providers/` | общие Riverpod-провайдеры (`appBreakpointProvider`, `ResponsiveBuilder`, …) |

**Тема (`theme.dart`):** класс `TAppTheme` с приватным конструктором и статическими `lightTheme` / `darkTheme`; виджет-темы подключаются из `widget_themes/` (как `TAppBarTheme`, `TTextTheme`, …). Цвета — из `utils/constants/colors.dart` (`TColors`).

**Правило именования файлов:**

| Тип | Шаблон | Пример |
| --- | --- | --- |
| Smart-экран | `{name}_screen.dart` | `chat_list_screen.dart` |
| Dumb-view | `{name}_view.dart` | `chat_list_view.dart` |
| Layout-обёртка (dumb, shared) | `shared/layouts/{name}.dart` | `two_pane.dart` → `TwoPane` |
| Notifier | `{name}_controller.dart` | `chat_list_controller.dart` |
| UI state | `{name}_state.dart` | `chat_list_state.dart` |
| Пользовательский виджет (класс `T…`) | `t_{name}.dart` | `t_chat_button.dart` → `TChatButton` |
| Repository (interface) | `{name}_repository.dart` | `chat_repository.dart` |
| Repository (impl) | `{name}_repository_impl.dart` | `chat_repository_impl.dart` |
| DTO | `{name}_dto.dart` | `message_dto.dart` |
| Entity | `{name}.dart` | `message.dart` |

**Пользовательские виджеты** (shared design-system и feature dumb: tiles, bubbles, buttons) — класс с префиксом **`T`**, файл `t_*.dart`. Пример: `TChatButton`, `TAvatar`, `TChatListTile`. Не относится к `*_screen` / `*_view` / `*_controller`, root `EChatApp`. Классы темы (`TAppTheme`, `TColors`, `TAppBarTheme`) — префикс `T`, файлы в `utils/theme/` и `utils/constants/`.

**Не создавать** папки `mobile/`, `tablet/`, `desktop/` с копиями целых фич — только параметризованные dumb-компоненты и общие обёртки из `shared/layouts/`.

---

## 6. Riverpod 3

### 6.1. Пакеты

```yaml
dependencies:
  flutter_riverpod: ^3.0.0
  riverpod_annotation: ^3.0.0
  freezed_annotation: ^3.0.0
  json_annotation: ^1.9.0
  fpdart: ^1.1.0

dev_dependencies:
  riverpod_generator: ^3.0.0
  freezed: ^3.0.0
  build_runner: ^2.4.0
  json_serializable: ^6.9.0
```

### 6.2. Обязательное использование аннотаций

**Запрещено** в production-коде:

- ручное объявление `Provider(...)`, `FutureProvider(...)` без codegen;
- `StateNotifier` / `ChangeNotifier` для новых фич.

**Разрешено и обязательно:**

- `@riverpod` / `@Riverpod` + `riverpod_generator`;
- `@Riverpod(keepAlive: true)` для singleton-сервисов (Firebase, repositories);
- `part '{file}.g.dart';` в каждом файле с аннотациями.

### 6.3. Типы провайдеров

| Задача | Аннотация | Пример |
| --- | --- | --- |
| Repository / Service | `@Riverpod(keepAlive: true)` | `AuthRepository`, `ChatRepository` |
| Stream данных | `@riverpod` → `Stream<T>` | список чатов, сообщения |
| Async загрузка | `@riverpod` class extends `_$X extends AsyncNotifier` | `ChatListController` |
| Синхронный UI state | `@riverpod` class extends `_$X extends Notifier` | форма Login, Register |
| Параметризованный | `@riverpod` с аргументами | `messageList(chatId)` |

### 6.4. Пример: repository provider

```dart
// features/chats/data/repositories/chat_repository_impl.dart
// + part и register в том же feature

// features/chats/presentation/providers/chat_repository_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_repository_provider.g.dart';

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  return ChatRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
}
```

### 6.5. Пример: AsyncNotifier для списка чатов

```dart
// features/chats/presentation/chat_list/chat_list_controller.dart
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_list_controller.g.dart';

// Realtime-источник: один стрим Firestore, каждая эмиссия несёт sealed Failure
// внутри Either (ошибки подписки оборачиваются в Left через handleError).
@riverpod
Stream<Either<Failure, List<Chat>>> chatListStream(Ref ref) =>
    ref.watch(chatRepositoryProvider).watchChats();

@riverpod
class ChatListController extends _$ChatListController {
  @override
  Future<ChatListState> build() async {
    // 1. Слушаем обновления стрима реактивно (работает автоматически вне build)
    ref.listen(
      chatListStreamProvider,
      (previous, next) {
        if (next is AsyncData) {
          next.value.fold(
            (failure) => state = AsyncError(failure, StackTrace.current),
            (chats) => state = AsyncData(
              (state.valueOrNull ?? const ChatListState(chats: [], query: ''))
                  .copyWith(chats: chats),
            ),
          );
        } else if (next is AsyncError) {
          final err = next.error;
          state = AsyncError(err is Failure ? err : Failure.unexpected(err), next.stackTrace);
        }
      },
    );

    // 2. Ждем первого значения из стрима для инициализации состояния
    final initialResult = await ref.watch(chatListStreamProvider.future);

    return initialResult.fold(
      (failure) => throw failure, // Ошибка попадёт в AsyncValue.error
      (chats) => ChatListState(chats: chats, query: ''),
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final result = await ref.read(chatRepositoryProvider).getChats();
      return result.fold(
        (failure) => throw failure, // sealed Failure → AsyncValue.error
        (chats) => (state.value ?? const ChatListState(chats: [], query: ''))
            .copyWith(chats: chats),
      );
    });
  }

  void setSearchQuery(String query) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(query: query));
  }
}
```

### 6.6. Пример: Smart UI → Dumb view

Smart подписывается на провайдеры; dumb получает только данные и колбэки. Полный пример с breakpoints — в [§3.4](#34-пример).

```dart
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(chatListControllerProvider);

    return asyncState.when(
      loading: () => const ChatListShimmer(),
      error: (err, _) => ErrorView(
        message: err is Failure ? err.displayMessage : 'Unknown error',
        onRetry: () => ref.invalidate(chatListControllerProvider),
      ),
      data: (state) => ChatListView(
        state: state,
        onSearchChanged: (q) =>
            ref.read(chatListControllerProvider.notifier).setSearchQuery(q),
        onChatTap: (id) => ref.read(appRouterProvider).go('/chats/$id'),
      ),
    );
  }
}
```

### 6.7. `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const ProviderScope(
      child: EChatApp(),
    ),
  );
}
```

### 6.8. Override для тестов

```dart
ProviderScope(
  overrides: [
    chatRepositoryProvider.overrideWithValue(FakeChatRepository()),
  ],
  child: const MaterialApp(home: ChatListScreen()),
);
```

---

## 7. Freezed

### 7.1. Где применять

| Объект | Freezed | json_serializable |
| --- | --- | --- |
| Domain entity | да | нет |
| DTO (Firestore) | да | да (`fromJson` / `toJson`) |
| UI state | да | нет |
| Failure / sealed errors | да (`@freezed sealed`) | нет |
| Union (Auth flow) | да | нет |

### 7.2. Entity (domain)

```dart
// features/chats/domain/entities/message.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String chatId,
    required String senderId,
    required MessageType type,
    required String? text,
    required MessageStatus status,
    required DateTime createdAt,
  }) = _Message;
}

enum MessageType { text, image, video, audio, voice, file, system }

enum MessageStatus { sending, sent, delivered, read, failed }
```

### 7.3. DTO + маппинг

```dart
// features/chats/data/dto/message_dto.dart
@freezed
abstract class MessageDto with _$MessageDto {
  const factory MessageDto({
    required String id,
    required String senderId,
    required String type,
    String? text,
    @TimestampConverter() required DateTime createdAt,
  }) = _MessageDto;

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);
}

extension MessageDtoX on MessageDto {
  Message toEntity(String chatId) => Message(
        id: id,
        chatId: chatId,
        senderId: senderId,
        type: MessageType.values.byName(type),
        text: text,
        status: MessageStatus.sent,
        createdAt: createdAt,
      );
}
```

### 7.4. UI state

```dart
// features/auth/presentation/login/login_state.dart
@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default('') String phone,
    @Default('') String password,
    @Default(false) bool isSubmitting,
    Failure? error,
  }) = _LoginState;
}
```

### 7.5. Sealed failures

```dart
// utils/exceptions/failures.dart
@freezed
sealed class Failure with _$Failure {
  const Failure._();

  const factory Failure.network([String? message]) = NetworkFailure;
  const factory Failure.auth(AuthFailureReason reason) = AuthFailure;
  const factory Failure.firestore(String code) = FirestoreFailure;
  const factory Failure.notFound() = NotFoundFailure;
  const factory Failure.unexpected(Object error) = UnexpectedFailure;

  String get displayMessage => switch (this) {
        NetworkFailure(:final message) => message ?? 'Нет сети',
        AuthFailure(:final reason) => reason.message,
        FirestoreFailure(:final code) => 'Ошибка базы: $code',
        NotFoundFailure() => 'Не найдено',
        UnexpectedFailure() => 'Что-то пошло не так',
      };
}
```

---

## 8. fpdart

### 8.1. Правила

1. **Repository** возвращает `Future<Either<Failure, T>>` или `Stream<Either<Failure, T>>`.
2. **Option** вместо `null` там, где «значения может не быть» в domain (avatar, draft). **Ошибки — никогда через `Option`**: только sealed `Failure`.
3. **TaskEither** — для композиции нескольких async-шагов в use case или repository.
4. **Do-нотация** — композиция 2+ шагов `Either` / `Option` / `TaskEither` только через `*.Do(($ ) { ... })`, не через вложенный `flatMap`. Один шаг — `TaskEither.tryCatch` без Do. На границе Notifier → UI — `fold` / `match`.
5. Исключения Firebase **перехватываются только в DataSource** и маппятся в `Failure`.

### 8.2. Repository interface

```dart
// features/chats/domain/repositories/chat_repository.dart
abstract class ChatRepository {
  Stream<Either<Failure, List<Chat>>> watchChats();
  Future<Either<Failure, Chat>> getChatById(String chatId);
  Future<Either<Failure, Unit>> sendMessage({
    required String chatId,
    required String text,
  });
}
```

### 8.3. Repository implementation

Один async-шаг — `TaskEither.tryCatch`, Do не нужен:

```dart
@override
Future<Either<Failure, Unit>> sendMessage({
  required String chatId,
  required String text,
}) {
  return TaskEither.tryCatch(
    () => _remote.sendMessage(chatId: chatId, text: text),
    (e, _) => e is FirebaseException
        ? Failure.firestore(e.code)
        : Failure.unexpected(e),
  ).map((_) => unit).run();
}
```

### 8.4. Цепочка TaskEither.Do (создание группы)

`$` достаёт `Right` / `Some`. Любой `Left` / `None` сразу останавливает цепочку.

```dart
Future<Either<Failure, Chat>> createGroup({
  required String title,
  required List<String> memberIds,
}) {
  return TaskEither<Failure, Chat>.Do(($) async {
    final uid = await $(
      TaskEither.fromEither(
        Option.fromNullable(_auth.currentUser?.uid).toEither(
          () => const Failure.auth(AuthFailureReason.notSignedIn),
        ),
      ),
    );

    final chatId = _firestore.collection('chats').doc().id;

    await $(
      TaskEither.tryCatch(
        () => _remote.createGroup(
          chatId: chatId,
          title: title,
          creatorId: uid,
          memberIds: [...memberIds, uid],
        ),
        (e, _) => e is FirebaseException
            ? Failure.firestore(e.code)
            : Failure.unexpected(e),
      ),
    );

    return await $(TaskEither(() => getChatById(chatId)));
  }).run();
}
```

Синхронные цепочки — `Either.Do` / `Option.Do` без `async` / `await`:

```dart
final result = Either<Failure, int>.Do(($) {
  final a = $(parseId(raw));
  final b = $(validatePositive(a));
  return b * 2;
});
```

Внутри `Do()` нельзя: `throw` вручную; `await` без `$`; вкладывать один `Do()` в другой; вызывать `$` внутри другого колбэка (`map`, `then`, `forEach`).

### 8.5. Notifier + Either

На границе UI Do не нужен: разбор результата через `fold`.

```dart
Future<void> login() async {
  state = state.copyWith(isSubmitting: true, error: null);

  final result = await ref.read(authRepositoryProvider).login(
        phone: state.phone,
        password: state.password,
      );

  result.fold(
    (failure) => state = state.copyWith(
      isSubmitting: false,
      error: failure, // sealed Failure → текст берётся из displayMessage
    ),
    (_) {
      state = state.copyWith(isSubmitting: false);
      ref.read(appRouterProvider).go('/home');
    },
  );
}
```

---

## 9. Поток данных

Пример: **отправка сообщения** (Chats _ Conversation).

```
ChatInputView.onSend                          # DUMB callback
    → ChatThreadScreen (SMART) → notifier.send(text)
        → ChatRepository.sendMessage()
            → ChatRemoteDataSource.sendMessage()
                → Firestore chats/{id}/messages
        ← Either<Failure, Unit>
    ← обновление optimistic UI / error snackbar (SMART)
```

Пример: **realtime typing** (Realtime Database, не Firestore).

```
TypingRemoteDataSource (RTDB)
    → TypingRepository
        → @riverpod Stream<bool> peerTyping(chatId, peerId)
            → ChatThreadScreen (SMART) → ChatThreadView (DUMB indicator)
```

Пример: **выбор чата на desktop** (master–detail, §4.3).

```
ChatListView.onChatTap(id)                    # DUMB (подпапка chat_list/)
    → ChatsShellScreen                        # SMART shell
        → context.go('/chats/$id')            # тот же route, что и на phone
        → TwoPane(
              master: ChatListView,           # DUMB
              detail: ChatThreadView,         # DUMB (подпапка chat_thread/)
            )
```

На phone тот же `onChatTap` → `/chats/:id` показывает **только** `ChatThreadView` (полный экран); контроллеры list и thread не сливаются.

---

## 10. Ошибки и Result

Организация исключений построена на строгом функциональном подходе с использованием **Freezed** и **fpdart**. В приложении не принято выбрасывать исключения наружу через `throw` и ловить их через глобальные `try/catch` на уровне бизнес-логики или UI. Все ошибки инкапсулируются в объекты `Failure`.

### 10.1. Где и как объявлять исключения (`utils/exceptions`)

Все ошибки приложения описываются как один или несколько `sealed class`, сгенерированных через **Freezed**.

```dart
// lib/src/utils/exceptions/failures.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const Failure._();

  const factory Failure.network([String? message]) = NetworkFailure;
  const factory Failure.auth(AuthFailureReason reason) = AuthFailure;
  const factory Failure.firestore(String code) = FirestoreFailure;
  const factory Failure.notFound() = NotFoundFailure;
  const factory Failure.unexpected(Object error) = UnexpectedFailure;

  // Обязательный геттер для получения текста ошибки
  String get displayMessage => switch (this) {
        NetworkFailure(:final message) => message ?? 'Нет подключения к сети',
        AuthFailure(:final reason) => reason.message,
        FirestoreFailure(:final code) => 'Ошибка базы данных: $code',
        NotFoundFailure() => 'Запрошенные данные не найдены',
        UnexpectedFailure() => 'Что-то пошло не так, попробуйте позже',
      };
}
```

### 10.2. Поток обработки ошибок по слоям

| Уровень | Формат ошибки | Описание |
| --- | --- | --- |
| **DataSource** | `try/catch` → `throw Failure` | Только DataSource ловит сырые исключения (FirebaseException и др.) через `try/catch` и сразу маппит их в доменный `Failure`. |
| **Repository** | `Either<Failure, T>` | Возвращают `Either` из `fpdart`. Никогда не выбрасывают исключения наружу. Если шагов несколько — используется `TaskEither.Do`. |
| **Notifier** | `fold()` → UI state | Riverpod-контроллер распаковывает `Either` через `.fold()` и кладет `Failure` в стейт (например, в `AsyncValue.error` или `error: failure` в классе состояния). |
| **Smart UI** | `err.displayMessage` | UI не знает о системных исключениях. Берет `Failure` из стейта и вызывает геттер `.displayMessage`. |
| **Dumb UI** | `message`, `onRetry` | Рисует текст `message` и callback `onRetry`, полученные из Smart-виджета. |

**Пример обработки в DataSource:**
```dart
try {
  await firebase.collection('chats').doc(id).set(data);
} on FirebaseException catch (e) {
  throw Failure.firestore(e.code); 
} catch (e) {
  throw Failure.unexpected(e);
}
```

**Пример обработки в Smart UI (`*_screen.dart`):**
```dart
return chatState.when(
  data: (chat) => ChatView(chat: chat),
  loading: () => const CircularProgressIndicator(),
  error: (err, stack) {
    final message = err is Failure ? err.displayMessage : 'Неизвестная ошибка';
    return ErrorView(message: message, onRetry: () => ref.invalidate(chatControllerProvider));
  },
);
```

### 10.3. Архитектурные табу (DON'Ts)

- **Строки для ошибок:** Ошибки нельзя передавать как `String` или `Option<String>`. Строки извлекаются из интерфейса пользователя только в самом конце через `Failure.displayMessage`.
- **Исключения выше DataSource:** Прямое использование Firebase SDK (`FirebaseException`) и сторонних классов-исключений в виджетах и слое Presentation запрещено.
- **Проглатывание ошибок:** Конструкция `catch (_) {}` без логирования или оборачивания в `Failure` недопустима.

### 10.4. Optimistic UI для сообщений

1. Notifier добавляет `Message` со `status: sending` в локальный state.
2. Repository возвращает `Either`.
3. При `Right` — `status: sent`; при `Left` — `status: failed` + retry action.

---

## 11. Features (модули)

Соответствие вкладкам Figma и слоям:

| Feature | Presentation (smart → dumb) | Domain | Data sources |
| --- | --- | --- | --- |
| `onboarding` | Introduce, Loading | — | SharedPreferences |
| `auth` | Login, Register, User Info | AuthRepository | Firebase Auth, Firestore `users` |
| `security` | PIN, Face/Touch ID | — | secure_storage (local) |
| `chats` | `ChatsShellScreen` + `chat_list` / `chat_thread` (dumb рядом на tablet/desktop) | ChatRepository, Message | Firestore, RTDB typing |
| `groups` | Group list, create, members (+ split view) | ChatRepository | Firestore |
| `calls` | Call, Video calling | CallRepository | Firestore `calls` + WebRTC provider |
| `contacts` | Add Friend | ContactRepository | Firestore `contacts`, `users` |
| `profile` | Profile, Edit (`maxWidth` на desktop) | UserRepository | Firestore `users` |
| `more` | Settings, Language, Theme | SettingsRepository | Firestore `userSettings` |
| `notifications` | Notification list | NotificationRepository | Firestore, FCM |

Каждый feature **самодостаточен**: своё `presentation`, `domain`, `data`. Общее — только `src/utils/`, `src/shared/`, `src/app.dart`.

Presentation внутри feature всегда: **smart screen** + **dumb view(s)** + **controller/state**. Layout-варианты phone/tablet/desktop — композиции dumb, не отдельные фичи. Если на wide нужны два экрана рядом (list + thread) — третий smart-shell компонует dumb из **разных подпапок** одной feature (§4.3); не сливать Notifier’ы и не плодить копии фич под форм-фактор.

---

## 12. Code generation

### 12.1. Команды

```bash
# Однократная генерация
dart run build_runner build --delete-conflicting-outputs

# Watch при разработке
dart run build_runner watch --delete-conflicting-outputs
```

### 12.2. Генерируемые файлы

| Инструмент | Вход | Выход |
| --- | --- | --- |
| `riverpod_generator` | `@riverpod` | `*.g.dart` |
| `freezed` | `@freezed` | `*.freezed.dart` |
| `json_serializable` | `@JsonSerializable` | `*.g.dart` |

**В git:** коммитить `*.freezed.dart` и `*.g.dart` — optional; команда может генерировать в CI. Для соло-разработки удобнее коммитить.

### 12.3. `analysis_options.yaml`

Подключите `riverpod_lint` **3.1+** как analyzer plugin (**без** `custom_lint`). Полная инструкция: [analysis-options-riverpod-lint.md](./analysis-options-riverpod-lint.md).

```yaml
# pubspec.yaml — dev_dependencies
riverpod_lint: ^3.1.8

# analysis_options.yaml — plugins на верхнем уровне файла
include: package:flutter_lints/flutter.yaml

plugins:
  riverpod_lint: 3.1.8

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
```

---

## 13. Тестирование

| Слой | Что тестировать | Как |
| --- | --- | --- |
| Domain | маппинг DTO → Entity | unit, pure Dart |
| Data | Repository | mock DataSource, проверка `Either` |
| Presentation | Notifier | `ProviderContainer` + overrides |
| Dumb widgets | UI по props | `pumpWidget` **без** ProviderScope |
| Smart screens | wiring + breakpoint layouts | `ProviderScope` + fake size / override `appBreakpointProvider` |
| Widget golden | phone / tablet / desktop | отдельные golden по breakpoint |

```dart
test('sendMessage returns Left on firestore error', () async {
  final container = ProviderContainer(
    overrides: [
      chatRepositoryProvider.overrideWithValue(FakeChatRepository(fail: true)),
    ],
  );
  addTearDown(container.dispose);

  final notifier = container.read(chatThreadControllerProvider('c1').notifier);
  await notifier.send('hello');

  expect(container.read(chatThreadControllerProvider('c1')).value?.lastError, isNotNull);
});
```

```dart
testWidgets('ChatListView shows empty state', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ChatListView(
        state: const ChatListState(chats: [], query: ''),
        onSearchChanged: (_) {},
        onChatTap: (_) {},
      ),
    ),
  );
  expect(find.text('No chats'), findsOneWidget);
});
```

---

## 14. Правила для команды

### DO

- `@riverpod` / `@Riverpod` для всех новых провайдеров.
- Freezed для state, entity, failure.
- `Either<Failure, T>` на границе domain ↔ data.
- fpdart: `TaskEither.Do` / `Either.Do` / `Option.Do` для цепочек из 2+ шагов.
- **Smart** = `ConsumerWidget` / `ConsumerStatefulWidget`; **Dumb** = `StatelessWidget` / `StatefulWidget` без Riverpod.
- Пользовательские виджеты — класс с префиксом `T` (`TChatButton`), файл `t_*.dart`.
- Один controller на подфичу-экран (list и thread — раздельно); layouts / shell для phone / tablet / desktop.
- Маппинг DTO → Entity только в `data/`.
- `ref.invalidate` / `ref.refresh` для pull-to-refresh.
- Breakpoints только через `appBreakpointProvider` / `utils/constants/breakpoints.dart` + `utils/providers/`.
- Выбор layout в smart: `ResponsiveBuilder` или `switch` по `AppBreakpoint` (§4.1.1).
- Master–detail (chats/groups): smart-shell компонует dumb из разных подпапок; общие маршруты `/…` и `/…/:id` (§4.3).

### DON'T

- `FirebaseFirestore.instance` в виджетах.
- `ref.watch` / `WidgetRef` в dumb (`*_view.dart`, shared widgets).
- Кастомные виджеты без префикса `T` / файла `t_` (`ChatButton`, `EChatButton` — только `TChatButton`).
- Отдельные Notifier или feature-копии «для tablet» / «для desktop».
- Сливать `chat_list` + `chat_thread` в один controller/state ради desktop; знать breakpoint внутри dumb-view.
- `setState` для бизнес-логики (только локальная анимация/форма без state).
- `dynamic` / `Map<String, dynamic>` в domain и presentation.
- Проглатывание ошибок (`catch (_) {}` без `Failure`).
- `String` / `Option<String>` для ошибок — все ошибки только через sealed `Failure`.
- Вложенный `flatMap` вместо Do-нотации fpdart.
- Циклические imports между features — выносить контракты в `domain` или `shared`.
- Хардкод `MediaQuery` порогов в feature-виджетах в обход `AppBreakpoint`.

### Чеклист PR

- [ ] `dart run build_runner build` проходит
- [ ] `flutter analyze` без ошибок
- [ ] Новые провайдеры через аннотации
- [ ] Repository возвращает `Either`; цепочки 2+ шагов — через Do-нотацию
- [ ] Models/state на Freezed
- [ ] Нет Firebase SDK в `presentation/`
- [ ] Smart/Dumb разделены; dumb без Riverpod
- [ ] Кастомные виджеты с префиксом `T` и файлом `t_*.dart`
- [ ] Новые экраны проверены на phone и хотя бы одном wide breakpoint (tablet или desktop)
- [ ] Master–detail (если есть): shell + два dumb, не копия фичи под wide

---

## Диаграмма зависимостей (features)

```mermaid
flowchart TB
  subgraph presentation
    Smart[Smart Screens / Shell]
    Dumb[Dumb Views / Layouts]
    NC[Riverpod Notifiers]
    BP[AppBreakpoint]
  end

  subgraph domain
    E[Freezed Entities]
    RI[Repository Interfaces]
    F[Failures]
  end

  subgraph data
    RImpl[Repository Impl]
    DS[DataSources]
    DTO[Freezed DTO]
  end

  subgraph external
    FB[Firebase]
  end

  BP --> Smart
  Smart --> NC
  Smart --> Dumb
  NC --> RI
  RImpl -.implements.-> RI
  RImpl --> DS
  DS --> FB
  DTO --> E
  RImpl --> F
  NC --> F
```

---

## Связанные документы

- [roadmap.md](./roadmap.md) — фазы, включая adaptive UI
- [firebase-database.md](./firebase-database.md) — модели Firestore для DTO/Entity
- [firebase-setup.md](./firebase-setup.md) — Auth, rules, Functions
- [firebase-registration.md](./firebase-registration.md) — Sign Up: Phone Auth, профиль, guard
- [firebase-flutter-connect.md](./firebase-flutter-connect.md) — инициализация Firebase в `main.dart`
- [firebase-events.md](./firebase-events.md) — Console, логи Functions, `snapshots()`, Analytics
- [Riverpod 3 docs](https://riverpod.dev/)
- [Freezed](https://pub.dev/packages/freezed)
- [fpdart](https://pub.dev/packages/fpdart)
