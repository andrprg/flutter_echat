# Шпаргалка: Riverpod 3

Краткая справка по **Riverpod 3** + codegen для **flutter_echat**. DI, state, реактивность UI. Связанные документы: [architecture.md](./architecture.md), [analysis-options-riverpod-lint.md](./analysis-options-riverpod-lint.md), [dart-fpdart.md](./dart-fpdart.md), [dart-freezed.md](./dart-freezed.md).

Официально: [riverpod.dev](https://riverpod.dev/), [What's new in 3.0](https://riverpod.dev/docs/whats_new), [миграция 2 → 3](https://riverpod.dev/docs/3.0_migration).

В проекте: только `@riverpod` / `@Riverpod` + `riverpod_generator`. Ручные `Provider(...)` / `FutureProvider(...)` и `StateNotifier` в production **запрещены**.

---

## Содержание

1. [Зачем Riverpod](#1-зачем-riverpod)
2. [Установка и codegen](#2-установка-и-codegen)
3. [ProviderScope и виджеты](#3-providerscope-и-виджеты)
4. [ref: watch / read / listen](#4-ref-watch--read--listen)
5. [Типы провайдеров (@riverpod)](#5-типы-провайдеров-riverpod)
6. [Notifier и AsyncNotifier](#6-notifier-и-asyncnotifier)
7. [Параметры (family)](#7-параметры-family)
8. [keepAlive, dispose, mounted](#8-keepalive-dispose-mounted)
9. [AsyncValue](#9-asyncvalue)
10. [Overrides и тесты](#10-overrides-и-тесты)
11. [Правила проекта](#11-правила-проекта)
12. [Частые ошибки](#12-частые-ошибки)
13. [Шпаргалка на одну страницу](#13-шпаргалка-на-одну-страницу)

---

## 1. Зачем Riverpod

| Задача | Как |
| --- | --- |
| DI (Firebase, repositories) | `@Riverpod(keepAlive: true)` |
| UI state (форма OTP) | `@riverpod` + `Notifier` |
| Async / загрузка | `@riverpod` + `AsyncNotifier` |
| Live данные | `@riverpod` → `Stream<T>` |
| Тесты | `overrides` без моков виджетов |

В Riverpod **3**: один тип `Ref` (без `XxxRef`), параметры family — в `build(...)`, нет отдельных `FamilyAsyncNotifier`.

---

## 2. Установка и codegen

```yaml
dependencies:
  flutter_riverpod: ^3.0.0
  riverpod_annotation: ^3.0.0

dev_dependencies:
  riverpod_generator: ^3.0.0
  riverpod_lint: ^3.1.8
  build_runner: ^2.4.0
```

В каждом файле с аннотациями:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_list_controller.g.dart';
```

```bash
dart run build_runner watch -d
```

Lint: [analysis-options-riverpod-lint.md](./analysis-options-riverpod-lint.md) — плагин `riverpod_lint` в `analysis_options.yaml`.

---

## 3. ProviderScope и виджеты

Корень приложения **обязательно** в `ProviderScope`:

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

| Виджет | Когда |
| --- | --- |
| `ConsumerWidget` | экран / виджет с `ref` |
| `ConsumerStatefulWidget` + `ConsumerState` | нужен `State` (контроллеры, focus) |
| `Consumer` | точечная подписка внутри обычного виджета |
| `HookConsumerWidget` | только если уже используете hooks |

```dart
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(chatListControllerProvider);
    // ...
  }
}
```

---

## 4. `ref`: watch / read / listen

| Метод | Эффект |
| --- | --- |
| `ref.watch(p)` | подписка; при изменении → rebuild / пересчёт провайдера |
| `ref.read(p)` | один раз, **без** подписки (клики, callbacks, init) |
| `ref.listen(p, (prev, next) { })` | побочные эффекты (snackbar, навигация), без rebuild |
| `ref.invalidate(p)` | сбросить и пересоздать |
| `ref.refresh(p)` | invalidate + сразу прочитать новое значение |

```dart
// в build — только watch
final chats = ref.watch(chatListControllerProvider);

// в onPressed — read
onPressed: () => ref.read(chatListControllerProvider.notifier).refresh(),

// побочный эффект
ref.listen(authControllerProvider, (prev, next) {
  next.whenOrNull(
    error: (e, _) => showSnack(context, '$e'),
  );
});
```

В **Notifier** после `await` проверяйте `ref.mounted` (аналог `BuildContext.mounted`):

```dart
final data = await repo.load();
if (!ref.mounted) return;
state = AsyncData(data);
```

`ref.watch` / `ref.read` **после dispose** нельзя — используйте `mounted`.

---

## 5. Типы провайдеров (`@riverpod`)

Codegen выводит тип провайдера из **возвращаемого значения** / вида класса.

| Задача | Объявление | Доступ |
| --- | --- | --- |
| Синхронное значение / DI | `@riverpod T foo(Ref ref)` | `fooProvider` |
| Singleton (repo, Firebase) | `@Riverpod(keepAlive: true)` | то же |
| Future | `@riverpod Future<T> foo(Ref ref)` | `AsyncValue<T>` |
| Stream | `@riverpod Stream<T> foo(Ref ref)` | `AsyncValue<T>` |
| Синхронный state + методы | `@riverpod class X extends _$X` → `Notifier` | `xProvider` / `.notifier` |
| Async state + методы | class с `Future<T> build()` → `AsyncNotifier` | `AsyncValue` + `.notifier` |

### Functional (простой DI / derived)

```dart
@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  return ChatRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
}

@riverpod
Stream<List<Chat>> watchChats(Ref ref) {
  return ref.watch(chatRepositoryProvider).watchChats().map(
        (either) => either.getOrElse((_) => <Chat>[]),
      );
}
```

В 3.x параметр всегда **`Ref`**, не `ChatRepositoryRef`.

### Class (логика + state)

```dart
@riverpod
class OtpController extends _$OtpController {
  @override
  OtpState build() => OtpState(/* ... */);

  void setCode(String code) {
    state = state.copyWith(code: code);
  }
}
```

---

## 6. Notifier и AsyncNotifier

### Notifier — синхронный UI state

```dart
@riverpod
class LoginController extends _$LoginController {
  @override
  LoginState build() => const LoginState();

  void setPhone(String phone) {
    state = state.copyWith(phone: phone);
  }
}

// UI
ref.watch(loginControllerProvider);           // LoginState
ref.read(loginControllerProvider.notifier);   // LoginController
```

### AsyncNotifier — загрузка / refresh

```dart
@riverpod
class ChatListController extends _$ChatListController {
  @override
  Future<ChatListState> build() async {
    final result = await ref.read(chatRepositoryProvider).watchChats().first;
    return result.fold(
      (failure) => throw failure,
      (chats) => ChatListState(chats: chats, query: ''),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(chatRepositoryProvider).getChats();
      return result.fold(
        (f) => throw f,
        (chats) => state.value!.copyWith(chats: chats),
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

| API | Где |
| --- | --- |
| `state` | в Notifier / AsyncNotifier |
| `future` | у AsyncNotifier — `Future` текущего значения |
| `listenSelf((prev, next) { })` | на Notifier, не на `ref` |
| `AsyncValue.guard(() async { ... })` | try/catch → `AsyncData` / `AsyncError` |

---

## 7. Параметры (family)

Аргументы — в сигнатуре функции или в `build`:

```dart
@riverpod
Stream<List<Message>> messages(Ref ref, String chatId) {
  return ref.watch(chatRepositoryProvider).watchMessages(chatId);
}

@riverpod
class MessageListController extends _$MessageListController {
  @override
  Future<List<Message>> build(String chatId) async {
    // chatId доступен в методах класса
    final result = await ref.read(chatRepositoryProvider).getMessages(chatId);
    return result.getOrElse((f) => throw f);
  }
}
```

Использование:

```dart
ref.watch(messagesProvider(chatId));
ref.read(messageListControllerProvider(chatId).notifier).reload();
```

Аргументы должны быть **immutable** и стабильно сравниваться (`==` / Freezed). Не передавайте `Widget`, `BuildContext`, `TextEditingController`.

---

## 8. keepAlive, dispose, mounted

| Режим | Поведение |
| --- | --- |
| По умолчанию (`@riverpod`) | autoDispose: нет слушателей → уничтожается |
| `@Riverpod(keepAlive: true)` | живёт весь срок `ProviderScope` |

```dart
@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;
```

Жизненный цикл:

```dart
ref.onDispose(() {
  subscription.cancel();
});
```

Для репозиториев / Firebase — `keepAlive: true`. Для экранов и списков — autoDispose ок.

---

## 9. AsyncValue

Состояние async-провайдера / AsyncNotifier:

| Вариант | Смысл |
| --- | --- |
| `AsyncLoading` | загрузка (может нести previous value) |
| `AsyncData(value)` | успех |
| `AsyncError(err, st)` | ошибка |

```dart
asyncState.when(
  data: (state) => ChatListView(state: state),
  loading: () => const ChatListShimmer(),
  error: (err, _) => ErrorView(
    message: err is Failure ? err.displayMessage : 'Unknown error',
    onRetry: () => ref.invalidate(chatListControllerProvider),
  ),
);

// или pattern matching (Riverpod 3):
switch (asyncState) {
  case AsyncData(:final value):
    return ChatListView(state: value);
  case AsyncError(:final error):
    return ErrorView(message: '$error');
  case AsyncLoading():
    return const ChatListShimmer();
}
```

Полезное:

| API | Смысл |
| --- | --- |
| `value` / `valueOrNull` | данные или null |
| `requireValue` | данные или throw |
| `hasValue` / `isLoading` / `hasError` | флаги |
| `whenOrNull` / `maybeWhen` | частичный разбор |
| `AsyncValue.guard` | обернуть async в Data/Error |

Не путать с Freezed `.when` — у unions Freezed 3 используйте `switch` ([dart-freezed.md](./dart-freezed.md)).

---

## 10. Overrides и тесты

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      chatRepositoryProvider.overrideWithValue(FakeChatRepository()),
    ],
    child: const MaterialApp(home: ChatListScreen()),
  ),
);
```

Без UI:

```dart
final container = ProviderContainer(
  overrides: [
    chatRepositoryProvider.overrideWithValue(fake),
  ],
);
addTearDown(container.dispose);

final state = await container.read(chatListControllerProvider.future);
```

---

## 11. Правила проекта

| Делать | Не делать |
| --- | --- |
| `@riverpod` + codegen | ручной `Provider` / `FutureProvider` в prod |
| `Notifier` / `AsyncNotifier` | `StateNotifier` / `ChangeNotifier` для новых фич |
| `keepAlive` для repo / Firebase | `keepAlive` на каждый экранный контроллер |
| `ref.watch` в `build` | `ref.watch` в `onPressed` |
| `ref.read` в callbacks | `ref.read` в `build` вместо watch (потеря обновлений) |
| Freezed state | мутабельный state в Notifier |
| Either в repository → `fold` / throw в guard | Firebase SDK прямо в UI |
| `riverpod_lint` | игнор зависимостей провайдеров |

Слой: UI → Notifier → Repository → DataSource. Прямых вызовов Firestore из `presentation` нет.

---

## 12. Частые ошибки

| Антипаттерн | Как надо |
| --- | --- |
| Нет `ProviderScope` | обернуть `runApp` |
| `XxxRef` из Riverpod 2 | просто `Ref` |
| Family через отдельный тип Notifier | аргументы в `build(id)` |
| `listen` / `watch` после dispose | `if (!ref.mounted) return` |
| Side-effect в `build` без `listen` | `ref.listen` |
| Забыли `.notifier` для методов | `ref.read(xProvider.notifier).method()` |
| Нестабильный family-аргумент | Freezed / примитивы |
| Не запустили codegen | `build_runner watch -d` |
| `await` в `build` виджета | async — в провайдере / Notifier |

---

## 13. Шпаргалка на одну страницу

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'x.g.dart';

// DI
@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) => ChatRepositoryImpl(...);

// sync state
@riverpod
class OtpController extends _$OtpController {
  @override
  OtpState build() => const OtpState();
  void setCode(String c) => state = state.copyWith(code: c);
}

// async + family
@riverpod
class MessagesController extends _$MessagesController {
  @override
  Future<List<Message>> build(String chatId) async { ... }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async { ... });
  }
}

// UI
class Screen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(messagesControllerProvider(chatId));
    return async.when(
      data: (d) => View(d),
      loading: () => const Spinner(),
      error: (e, _) => ErrorView(
        onRetry: () => ref.invalidate(messagesControllerProvider(chatId)),
      ),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: App()));
}
```

| Хочу | Пишу |
| --- | --- |
| Подписка в UI | `ref.watch` |
| Клик / один раз | `ref.read` |
| Snackbar / navigate | `ref.listen` |
| Сброс | `ref.invalidate` |
| Repo / Firebase | `@Riverpod(keepAlive: true)` |
| Форма | `Notifier` + Freezed state |
| Список с сетью | `AsyncNotifier` + `AsyncValue` |
| По `chatId` | `build(String chatId)` / `provider(id)` |
| Мок в тесте | `overrides: [...]` |
