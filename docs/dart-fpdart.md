# Шпаргалка: fpdart

Краткая справка по **fpdart** для **flutter_echat**: `Either`, `Option`, `TaskEither`, Do-нотация. Связанные документы: [architecture.md](./architecture.md), [dart-riverpod.md](./dart-riverpod.md), [dart-freezed.md](./dart-freezed.md), [dart-classes.md](./dart-classes.md).

Официально: [pub.dev/fpdart](https://pub.dev/packages/fpdart), [API](https://pub.dev/documentation/fpdart/latest/), [Do notation](https://pub.dev/documentation/fpdart/latest/).

В проекте: `fpdart: ^1.1.0`. Ошибки домена — `Failure` (Freezed sealed); репозитории возвращают `Future/Stream<Either<Failure, T>>`, не «голый» `throw`.

---

## Содержание

1. [Зачем fpdart](#1-зачем-fpdart)
2. [Установка](#2-установка)
3. [Either](#3-either)
4. [Option](#4-option)
5. [Unit](#5-unit)
6. [TaskEither](#6-taskeither)
7. [Do-нотация](#7-do-нотация)
8. [Частые комбинаторы](#8-частые-комбинаторы)
9. [Граница Repository → Notifier → UI](#9-граница-repository--notifier--ui)
10. [Правила проекта](#10-правила-проекта)
11. [Частые ошибки](#11-частые-ошибки)
12. [Шпаргалка на одну страницу](#12-шпаргалка-на-одну-страницу)

---

## 1. Зачем fpdart

| Проблема | Решение fpdart |
| --- | --- |
| `null` как «нет значения» | `Option<T>` — `Some` / `None` |
| `throw` / коды ошибок наружу | `Either<L, R>` — `Left` (ошибка) / `Right` (успех) |
| Цепочка async с ошибками | `TaskEither` + `.run()` → `Future<Either>` |
| Вложенный `flatMap` | `*.Do(($ ) { ... })` |

В E-Chat `L` почти всегда `Failure`, `R` — entity / `Unit` / список.

---

## 2. Установка

```yaml
dependencies:
  fpdart: ^1.1.0
```

```dart
import 'package:fpdart/fpdart.dart';
```

Отдельно подключать ничего не нужно: типы в одном пакете.

---

## 3. Either

`Either<L, R>` — **ровно одно** из двух: ошибка `Left<L>` или успех `Right<R>`.

```dart
Either<Failure, Chat> result;

// создание
final ok = right<Failure, Chat>(chat);
final err = left<Failure, Chat>(const Failure.notFound());

// или
Either<Failure, int>.of(42);           // Right
Either<Failure, int>.left(failure);    // Left
```

### Разбор

```dart
result.fold(
  (failure) => showError(failure.displayMessage),
  (chat) => openChat(chat),
);

// match — то же по смыслу
result.match(
  (l) => ...,
  (r) => ...,
);

// getOrElse — только Right, иначе fallback
final chats = result.getOrElse((f) => <Chat>[]);

// pattern matching (Dart 3)
switch (result) {
  case Left(:final value):
    handle(value);
  case Right(:final value):
    use(value);
}
```

### Цепочки (без Do)

```dart
final doubled = parseId(raw)          // Either<Failure, int>
    .flatMap(validatePositive)        // Either<Failure, int>
    .map((n) => n * 2);               // Either<Failure, int>
```

| Метод | Смысл |
| --- | --- |
| `map` | преобразовать `R`, `L` не трогать |
| `mapLeft` | преобразовать `L` |
| `bimap` | оба |
| `flatMap` / `bind` | `R → Either<L, R2>`; при `Left` цепочка стоп |
| `getOrElse` | достать `R` или заменить |
| `isLeft` / `isRight` | проверка |
| `toOption()` | `Right` → `Some`, `Left` → `None` (ошибка теряется) |
| `swap` | `Left` ↔ `Right` |

```dart
Either.tryCatch(
  () => int.parse(raw),
  (e, s) => Failure.unexpected(e),
);
```

---

## 4. Option

`Option<T>` — значение **может отсутствовать**, без `null` в domain/UI-смысле.

```dart
Option<String> avatarUrl;

final someUrl = some('https://...');
final empty = none<String>();

Option.fromNullable(user.avatar); // null → None
```

```dart
avatarUrl.fold(
  () => const PlaceholderAvatar(),
  (url) => NetworkImage(url),
);

final raw = avatarUrl.getOrElse(() => '');
final mapped = avatarUrl.map((u) => u.toUpperCase());
```

| Когда Option | Когда Either |
| --- | --- |
| «нет значения» — норма | «ошибка операции» |
| draft, avatar, errorMessage в форме | сеть, auth, firestore fail |
| UI optional | Repository result |

В UI state проекта:

```dart
@Default(false) bool isSubmitting,
Option<String> errorMessage, // none() = нет ошибки
```

```dart
state = state.copyWith(errorMessage: some(failure.displayMessage));
state = state.copyWith(errorMessage: none());
```

`Option` → `Either`:

```dart
Option.fromNullable(uid).toEither(
  () => const Failure.auth(AuthFailureReason.notSignedIn),
);
```

---

## 5. Unit

`Unit` — «успех без данных» (как `void`, но значение). Константа: `unit`.

```dart
Future<Either<Failure, Unit>> sendMessage(...);

return TaskEither.tryCatch(
  () => _remote.sendMessage(...),
  (e, _) => ...,
).map((_) => unit).run();
```

Не возвращайте `null` / `true` для «ок без payload» — `Right(unit)`.

---

## 6. TaskEither

`TaskEither<L, R>` — **ленивая** async-операция → при `.run()` даёт `Future<Either<L, R>>`.

Пока не вызвали `run()`, сеть/IO не стартовали (удобно композировать).

### Создание

```dart
// из Future, который может бросить
TaskEither.tryCatch(
  () => _remote.getChat(id),
  (e, stack) => e is FirebaseException
      ? Failure.firestore(e.code)
      : Failure.unexpected(e),
);

// уже есть Future<Either>
TaskEither(() => getChatById(chatId));

// из Either / Option
TaskEither.fromEither(either);
TaskEither.fromOption(option, () => const Failure.notFound());
TaskEither.fromNullable(uid, () => const Failure.auth(...));

// готовые
TaskEither.right<Failure, Chat>(chat);
TaskEither.left<Failure, Chat>(failure);
```

### Один шаг в Repository

Do не нужен:

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

### Несколько шагов — Do

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

`$` достаёт `Right`. Любой `Left` → вся Do сразу возвращает этот `Left`.

| Метод TaskEither | Смысл |
| --- | --- |
| `map` / `mapLeft` | как у Either |
| `flatMap` | цепочка TaskEither |
| `run()` | `Future<Either<L, R>>` |
| `match` / `fold` после run | на Either |

Синхронный аналог без IO: `Either` / `IOEither`. Чистый async без ошибки: `Task` / `TaskOption` — в проекте реже нужны.

---

## 7. Do-нотация

Линейный код вместо пирамиды `flatMap`.

### Sync

```dart
final result = Either<Failure, int>.Do(($) {
  final a = $(parseId(raw));
  final b = $(validatePositive(a));
  return b * 2;
});
```

```dart
final name = Option.Do(($) {
  final user = $(findUser(id));
  final profile = $(user.profile);
  return $(profile.displayName);
});
```

### Async

```dart
TaskEither<Failure, T>.Do(($) async {
  final a = await $(step1());
  final b = await $(step2(a));
  return b;
});
```

### Запрещено внутри `Do`

1. `throw` вручную — возвращайте `Left` / используйте `tryCatch` снаружи шага  
2. `await` **без** `$` у TaskEither-шага  
3. Вложенный `Do()` внутри другого `Do()`  
4. Вызов `$` внутри чужого колбэка (`map`, `then`, `forEach`, `listen`)

Один шаг — `tryCatch` + `run`, без Do. Два и больше — Do.

---

## 8. Частые комбинаторы

```dart
// Option
some(1).alt(() => some(0));           // если None → другая Option
option.filter((x) => x > 0);

// Either
either.orElse((l) => right(fallback));
either.alt(() => otherEither);

// списки
final rights = eithers.whereType... // или:
final okItems = rights(listOfEither); // fpdart helper
final (ls, rs) = partitionEithers(listOfEither);
```

Преобразования:

```dart
either.toTaskEither();
option.toEither(() => failure);
option.toNullable(); // обратно в T?
```

---

## 9. Граница Repository → Notifier → UI

```
DataSource          throw / FirebaseException
     ↓
Repository          Future/Stream<Either<Failure, T>>
                    (tryCatch / Do / map → Failure)
     ↓
Notifier            await → fold / match
                    или throw в AsyncValue.guard
     ↓
UI                  Freezed state / AsyncValue.when
                    Option для optional полей
```

### Notifier: fold (предпочтительно для форм)

```dart
Future<void> submitOtp() async {
  state = state.copyWith(isSubmitting: true, errorMessage: none());

  final result = await ref.read(authRepositoryProvider).confirmOtp(
        verificationId: state.verificationId,
        code: state.code,
      );

  result.fold(
    (failure) => state = state.copyWith(
      isSubmitting: false,
      errorMessage: some(failure.displayMessage),
    ),
    (_) {
      state = state.copyWith(isSubmitting: false);
      ref.read(appRouterProvider).go('/home');
    },
  );
}
```

### AsyncNotifier: throw внутри guard

```dart
state = await AsyncValue.guard(() async {
  final result = await ref.read(chatRepositoryProvider).getChats();
  return result.fold((f) => throw f, (v) => v);
});
```

UI тогда показывает `AsyncError`; если `err is Failure` — `displayMessage`.

Do-нотацию в Notifier **не** тяните: граница UI — `fold` / `switch`.

---

## 10. Правила проекта

1. Публичный API Repository: `Future<Either<Failure, T>>` или `Stream<Either<Failure, T>>`.  
2. `Option` — там, где отсутствие значения **нормально** (avatar, draft, errorMessage).  
3. Несколько async-шагов → `TaskEither.Do`; один → `tryCatch` + `run`.  
4. Firebase exceptions ловить в DataSource / на краю Repository, мапить в `Failure`.  
5. В presentation не импортировать Firebase ради ошибок — только `Failure` / `Either`.  
6. Domain не зависит от Flutter/Riverpod; fpdart + Freezed — ок.

Интерфейс:

```dart
abstract class ChatRepository {
  Stream<Either<Failure, List<Chat>>> watchChats();
  Future<Either<Failure, Chat>> getChatById(String chatId);
  Future<Either<Failure, Unit>> sendMessage({
    required String chatId,
    required String text,
  });
}
```

---

## 11. Частые ошибки

| Антипаттерн | Как надо |
| --- | --- |
| `throw` из Repository наружу | `Left(Failure)` |
| `null` вместо «нет значения» в domain | `Option` / `none()` |
| Пирамида `flatMap` | `Either.Do` / `TaskEither.Do` |
| Забыли `.run()` у TaskEither | без `run` Future нет |
| `await taskEither` без `$` в Do | `await $(taskEither)` |
| `throw` внутри Do | `Left` / `tryCatch` |
| `$` в `.map((x) => $(...))` | сначала вычислите Either, потом `$` |
| Do на один `tryCatch` | избыточно; один шаг без Do |
| Путать `fold` у Option и Either | Option: `() / (v)`; Either: `(l) / (r)` |
| `getOrElse` глотает Failure молча в критичном месте | лучше `fold` с явным UI |

---

## 12. Шпаргалка на одну страницу

```dart
import 'package:fpdart/fpdart.dart';

// Either
right<Failure, int>(1);
left<Failure, int>(const Failure.notFound());
either.fold((l) => ..., (r) => ...);
either.map((r) => r + 1);
either.flatMap((r) => otherEither);

// Option
some('x');
none<String>();
Option.fromNullable(nullable);
option.fold(() => ..., (v) => ...);

// Unit
right<Failure, Unit>(unit);

// TaskEither
TaskEither.tryCatch(
  () => api.call(),
  (e, s) => Failure.unexpected(e),
).map((_) => unit).run();

TaskEither<Failure, Chat>.Do(($) async {
  final a = await $(step1());
  final b = await $(step2(a));
  return b;
}).run();

// Sync Do
Either<Failure, int>.Do(($) {
  final a = $(parse(raw));
  return $(validate(a));
});

// Notifier
result.fold(
  (f) => state = state.copyWith(errorMessage: some(f.displayMessage)),
  (v) => state = state.copyWith(data: v, errorMessage: none()),
);
```

| Хочу | Пишу |
| --- | --- |
| Успех / ошибка | `Either<Failure, T>` |
| Может не быть | `Option<T>` |
| Успех без данных | `Either<Failure, Unit>` |
| Один async-шаг | `TaskEither.tryCatch(...).run()` |
| Несколько async-шагов | `TaskEither.Do(($) async { ... }).run()` |
| Sync-цепочка | `Either.Do` / `Option.Do` |
| Разбор в UI/Notifier | `fold` / `match` / `switch` |
| Optional в Freezed state | `Option<String> errorMessage` |
