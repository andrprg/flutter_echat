# Шпаргалка: `Future` в Dart

Краткая справка по асинхронности Dart для **flutter_echat**. Предпочтительный стиль в проекте: `async` / `await` + `try`/`catch`. На границе репозитория результат оборачивается в `Future<Either<Failure, T>>` — см. [architecture.md](./architecture.md).

Официально: [Future API](https://api.dart.dev/dart-async/Future-class.html), [async/await](https://dart.dev/language/async), [dart:async](https://dart.dev/libraries/dart-async).

---

## Содержание

1. [Что такое Future](#1-что-такое-future)
2. [async / await](#2-async--await)
3. [Создание Future](#3-создание-future)
4. [Очередь событий (когда что запускается)](#4-очередь-событий-когда-что-запускается)
5. [Методы экземпляра](#5-методы-экземпляра)
6. [Несколько Future сразу](#6-несколько-future-сразу)
7. [Ошибки](#7-ошибки)
8. [Не ждать результат: unawaited и ignore](#8-не-ждать-результат-unawaited-и-ignore)
9. [Completer](#9-completer)
10. [FutureOr](#10-futureor)
11. [Таймаут и «зависший» Future](#11-таймаут-и-зависший-future)
12. [Future vs Stream](#12-future-vs-stream)
13. [В этом проекте (Riverpod, fpdart)](#13-в-этом-проекте-riverpod-fpdart)
14. [Частые ошибки](#14-частые-ошибки)
15. [Шпаргалка на одну страницу](#15-шпаргалка-на-одну-страницу)

---

## 1. Что такое Future

`Future<T>` — обещание **одного** результата, который появится позже: значение типа `T` или ошибка.

Два состояния:

| Состояние | Смысл |
| --- | --- |
| **uncompleted** | Работа ещё идёт |
| **completed** | Есть значение **или** ошибка |

`Future<void>` — «операция закончилась», полезного значения нет.

Вызов async-функции **сразу** возвращает незавершённый `Future`. Сама работа идёт в фоне; UI не блокируется (это не поток OS, а event loop).

```dart
Future<String> fetchName() async {
  await Future<void>.delayed(const Duration(seconds: 1));
  return 'Alice';
}

void example() {
  final future = fetchName(); // уже Future, имя ещё не готово
  future.then(print);         // напечатает Alice через ~1 с
}
```

---

## 2. async / await

Правило по умолчанию: **await, а не `.then()`**.

```dart
Future<String> loadUser() async {
  final raw = await api.getUser();
  return User.fromJson(raw).name;
}
```

| Правило | Деталь |
| --- | --- |
| `await` только внутри `async` | Иначе ошибка компиляции |
| `async` меняет тип возврата | `T` → `Future<T>`, «ничего» → `Future<void>` |
| Код до **первого** `await` синхронный | Выполняется сразу при вызове |
| `await` не Future | Значение автоматически оборачивается в `Future` |
| `main` с `await` | `void main() async { ... }` или `Future<void> main() async` |

Последовательность (каждый шаг ждёт предыдущий):

```dart
final a = await step1();
final b = await step2(a);
await step3(b);
```

Параллельно независимые шаги — **не** ставьте `await` сразу на вызов, сначала запустите оба:

```dart
final f1 = loadProfile();
final f2 = loadSettings();
final profile = await f1;
final settings = await f2;
// или: final (profile, settings) = await (f1, f2).wait;
```

---

## 3. Создание Future

```dart
import 'dart:async';
```

| Конструктор | Когда использовать |
| --- | --- |
| `Future.value(x)` | Уже есть значение (или другой Future) |
| `Future.syncValue(x)` | Значение **точно не** Future; чуть дешевле `value` |
| `Future.error(e, [st])` | Сразу завершить ошибкой |
| `Future(computation)` | Запустить `computation` через `Timer.run` (очередь событий) |
| `Future.microtask(fn)` | Запустить в очереди **микрозадач** (раньше event queue) |
| `Future.sync(fn)` | Вызвать `fn` **сейчас**; если бросит — Future с ошибкой; если вернёт Future — пробросит его |
| `Future.delayed(d, [fn])` | Подождать `d`, затем `fn` (или `null`) |
| `Future.pause([d])` | «Поспать» `d` (по умолчанию `Duration.zero`) и завершиться |

```dart
Future<int> already = Future.value(42);
Future<int> failed = Future.error(StateError('нет данных'));

Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 300));

// sync: исключение сразу попадает в Future, без микрозадачи
Future<int> parsed = Future.sync(() => int.parse(raw));
```

`async`-функция сама создаёт Future — конструкторы нужны редко (тесты, адаптеры, задержки).

---

## 4. Очередь событий (когда что запускается)

Dart — однопоточный event loop (UI isolate).

```
вызов функции
  → синхронный код до первого await
  → await отдаёт управление event loop
  → когда Future готов, продолжение ставится в очередь
```

Порядок очередей (упрощённо):

1. **Синхронный код** текущего стека
2. **Microtask queue** (`scheduleMicrotask`, `Future.microtask`)
3. **Event queue** (`Timer`, I/O, `Future()`, `Future.delayed`)

```dart
void order() {
  print('1 sync');
  Future.microtask(() => print('2 microtask'));
  Future(() => print('3 event'));
  print('4 sync again');
}
// 1 → 4 → 2 → 3
```

Пока isolate занят тяжёлым синхронным кодом, Future не «тикает». Долгий CPU — в `Isolate` / `compute`, не в `Future`.

---

## 5. Методы экземпляра

Предпочитайте `await`. Цепочки `.then` — для коротких колбэков вне `async` или когда нужно вернуть Future без `async`.

| Метод | Аналог | Заметка |
| --- | --- | --- |
| `then(onValue, {onError})` | `await` + тело | Если колбэк вернул Future — ждут его |
| `catchError(onError)` | `catch` | Ловит ошибку **этого** Future и ошибок в предыдущем `then` |
| `whenComplete(action)` | `finally` | Выполнится и при успехе, и при ошибке; результат не меняет |
| `timeout(d, {onTimeout})` | — | Если не успел — ошибка `TimeoutException` или значение `onTimeout` |
| `ignore()` | — | Проглотить и значение, и ошибку (расширение `FutureExtensions`) |

```dart
future
    .then((v) => use(v))
    .catchError((e, st) => fallback)
    .whenComplete(() => hideSpinner());
```

Эквивалент:

```dart
try {
  use(await future);
} catch (e, st) {
  fallback;
} finally {
  hideSpinner();
}
```

`onError` у `then` **не** ловит ошибки из самого `onValue`. `catchError` после `then` — ловит. Поэтому `then` + `catchError` надёжнее, чем `then(..., onError: ...)`.

Несколько подписчиков на один Future независимы; порядок их завершения не гарантирован.

---

## 6. Несколько Future сразу

### 6.1. `Future.wait` — список одного типа

```dart
final results = await Future.wait<String>([
  loadA(),
  loadB(),
  loadC(),
]);
// results — List<String> в том же порядке
```

| Параметр | Смысл |
| --- | --- |
| `eagerError: true` | Упасть при **первой** ошибке, не ждать остальных |
| `eagerError: false` (по умолчанию) | Дождаться всех, затем отдать **первую** ошибку |
| `cleanUp` | Для успешно завершённых, если кто-то упал (закрыть ресурс) |

### 6.2. `.wait` на списке / record (Dart 3) — разные типы и разбор ошибок

```dart
final (user, chats) = await (
  loadUser(),
  loadChats(),
).wait;
```

Если кто-то упал — `ParallelWaitError`: в `e.values` успешные результаты (остальные `null`), в `e.errors` — ошибки.

```dart
try {
  await [a(), b(), c()].wait;
} on ParallelWaitError<List<Object?>, List<AsyncError?>> catch (e) {
  // e.values[i], e.errors[i]
}
```

### 6.3. Первым завершился

```dart
final winner = await Future.any([slow(), fast()]);
```

Остальные Future **не отменяются** — они продолжают работать. Отмены у `Future` нет.

### 6.4. По очереди по коллекции

```dart
await Future.forEach(ids, (id) => deleteChat(id));

await Future.doWhile(() async {
  final more = await fetchPage();
  return more.isNotEmpty;
});
```

---

## 7. Ошибки

`throw` внутри `async` завершает возвращённый Future **ошибкой**. `await` такого Future снова бросает — ловится обычным `try`/`catch`.

```dart
Future<int> risky() async {
  throw FormatException('bad');
}

Future<void> call() async {
  try {
    await risky();
  } on FormatException catch (e, st) {
    log(e, st);
  }
}
```

Необработанная ошибка Future (никто не сделал `await` / `catchError`) — **uncaught async error**. В Flutter часто попадает в `FlutterError` / Zone и может выглядеть как краш.

Обработчик ошибок вешайте **сразу**, не через `Timer` / второй `await` позже: если Future упадёт раньше, ошибка уже «убежит».

В **flutter_echat** исключения Firebase не выпускают наружу из DataSource: ловят и кладут в `Left(Failure)`. Публичный API репозитория — `Future<Either<...>>`, а не «голый» `throw`.

---

## 8. Не ждать результат: `unawaited` и `ignore`

Линты `unawaited_futures` / `discarded_futures` требуют явно решить судьбу Future.

| API | Эффект |
| --- | --- |
| `await f` | Ждать значение и ошибки |
| `unawaited(f)` | «Намеренно не жду». **Ошибки всё равно надо обработать** (иначе uncaught) |
| `f.ignore()` | Не ждать и **проглотить ошибки** |

```dart
import 'dart:async';

unawaited(analytics.logOpen()); // только если ошибка обработана внутри logOpen

someFuture.ignore(); // сознательно выбросить и результат, и ошибку
```

`unawaited` ничего не «глушит» — только снимает линт. Для fire-and-forget с возможным fail безопаснее:

```dart
unawaited(
  sendReceipt().catchError((e, st) => log(e, st)),
);
```

---

## 9. Completer

Мост из колбэк-API в `Future`. Создаёте Completer, отдаёте `completer.future`, позже вызываете `complete` / `completeError` **ровно один раз**.

```dart
Future<String> waitForCode() {
  final c = Completer<String>();

  auth.verifyPhoneNumber(
    phoneNumber: phone,
    verificationCompleted: (_) {},
    verificationFailed: (e) => c.completeError(e),
    codeSent: (id, _) => c.complete(id),
    codeAutoRetrievalTimeout: (_) {
      if (!c.isCompleted) c.completeError(TimeoutException('OTP'));
    },
  );

  return c.future;
}
```

| Член | Смысл |
| --- | --- |
| `future` | То, что возвращаете вызывающему |
| `complete(value)` | Успех (`value` может быть Future — пробросится) |
| `completeError(e, [st])` | Ошибка |
| `isCompleted` | Уже вызывали complete* |

Второй `complete` — ошибка. Completer не нужен, если можно написать `async`/`await`.

---

## 10. FutureOr

`FutureOr<T>` = `T | Future<T>`. Так описаны колбэки `then`, `timeout`, конструкторы `Future(...)`.

```dart
FutureOr<int> maybeSync(bool fromCache) {
  if (fromCache) return 1;          // T
  return fetchRemote();             // Future<T>
}
```

После `await maybeSync(...)` тип — `int`. Не злоупотребляйте в публичном API репозиториев: там лучше явный `Future<Either<...>>`.

---

## 11. Таймаут и «зависший» Future

```dart
final user = await loadUser().timeout(
  const Duration(seconds: 10),
  onTimeout: () => throw TimeoutException('user'),
);
```

Таймаут **не отменяет** исходную работу. Исходный Future может позже завершиться — если на него больше никто не подписан, ошибка/значение нужно либо `ignore()`, либо не оставлять «висящим» без обработчика.

Future может **никогда** не завершиться (забытый Completer, вечный `wait`). Колбэки тогда не вызовутся. Для UI — всегда `timeout` или индикатор + отмена на уровне источника (отписка от Stream, `CancelToken` у HTTP).

---

## 12. Future vs Stream

| | `Future<T>` | `Stream<T>` |
| --- | --- | --- |
| Сколько значений | Одно | Ноль, одно или много |
| Типичный API | `get()`, HTTP, `run()` | `snapshots()`, события, пагинация |
| Ожидание | `await` | `await for` / `listen` |
| «Первый элемент» | сам Future | `stream.first` → `Future` |

```dart
final firstChatPage = await repo.watchChats().first;
```

В проекте: разовые операции — `Future<Either<...>>`; живые подписки Firestore — `Stream<Either<...>>`. Подробнее: [dart-stream.md](./dart-stream.md).

---

## 13. В этом проекте (Riverpod, fpdart)

### Репозиторий

```dart
Future<Either<Failure, Chat>> getChatById(String chatId);
```

Один шаг — `TaskEither.tryCatch(...).run()`. Несколько шагов — `TaskEither.Do(($) async { ... })`. Не смешивать голый `throw` с Do-нотацией.

### Notifier

```dart
Future<void> refresh() async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    final result = await ref.read(chatRepositoryProvider).getChats();
    return result.fold((f) => throw f, (v) => v); // или разбор без throw
  });
}
```

Либо без исключений: `await repo...` → `fold` в `state` (как `submitOtp` в architecture).

### UI

Не кладите `await` в `build()`. Либо `ref.watch(futureProvider)`, либо кнопка → метод Notifier.

```dart
asyncState.when(
  data: (data) => ...,
  loading: () => ...,
  error: (e, st) => ...,
);
```

---

## 14. Частые ошибки

| Антипаттерн | Как надо |
| --- | --- |
| `await a(); await b();` когда `a` и `b` независимы | Запустить оба, потом ждать |
| Вызов async без `await` | `await`, `unawaited` + обработка ошибок, или `ignore()` |
| `try/catch` вокруг вызова **без** `await` | `catch` не поймает ошибку Future |
| `.then` без `catchError` | Ошибка уйдёт в Zone |
| Completer «на всякий случай» | Обычный `async` |
| Тяжёлый цикл внутри `async` | Режет кадры UI; вынести в isolate |
| Ждать `Future.wait` и думать, что остальные отменились при ошибке | Не отменились; при необходимости `cleanUp` / флаги |
| `Future.value(someFuture)` путают с «уже готово» | Если передан Future — ждут **его** завершения |

---

## 15. Шпаргалка на одну страницу

```dart
// объявить
Future<T> f() async { ... }

// ждать
final x = await f();

// ошибки
try { await f(); } catch (e, st) { ... } finally { ... }

// уже готово / сразу ошибка
Future.value(1);
Future.error(Exception('x'));

// задержка
await Future<void>.delayed(const Duration(ms: 200));

// параллельно, один тип
await Future.wait([a(), b()]);

// параллельно, разные типы
final (u, c) = await (loadUser(), loadChats()).wait;

// кто первый
await Future.any([a(), b()]);

// цепочка (лучше await)
f().then(use).catchError(handle).whenComplete(cleanup);

// намеренно не ждать
unawaited(okFuture);
risky.ignore();

// колбэк → Future
final c = Completer<T>();
// ... c.complete(v) / c.completeError(e);
return c.future;

// лимит ожидания
await f().timeout(const Duration(seconds: 5));
```

| Хочу | Пишу |
| --- | --- |
| Последовательные шаги | `await` друг за другом |
| Параллельные шаги | сначала вызовы, потом `wait` / record `.wait` |
| Результат в UI | Riverpod `AsyncValue` / `ref.watch` |
| Ошибка домена | `Future<Either<Failure, T>>`, не `throw` из репозитория |
| Подписка на изменения | `Stream`, не `Future` |
| Fire-and-forget | `unawaited` + свой `catchError`, либо `ignore()` |
