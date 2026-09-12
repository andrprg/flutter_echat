# Шпаргалка: `Stream` и `StreamController` в Dart

Краткая справка по потокам событий для **flutter_echat**. Рядом: [dart-future.md](./dart-future.md). Живые подписки Firestore/RTDB — `Stream<Either<Failure, T>>` из Repository; UI через Riverpod — см. [architecture.md](./architecture.md), [firebase-events.md](./firebase-events.md).

Официально: [Stream](https://api.dart.dev/dart-async/Stream-class.html), [StreamController](https://api.dart.dev/dart-async/StreamController-class.html), [StreamSubscription](https://api.dart.dev/dart-async/StreamSubscription-class.html), [dart:async](https://dart.dev/libraries/dart-async).

---

## Содержание

1. [Что такое Stream](#1-что-такое-stream)
2. [Future vs Stream](#2-future-vs-stream)
3. [Single-subscription vs broadcast](#3-single-subscription-vs-broadcast)
4. [Создание Stream](#4-создание-stream)
5. [Чтение: await for и listen](#5-чтение-await-for-и-listen)
6. [StreamSubscription](#6-streamsubscription)
7. [Трансформации](#7-трансформации)
8. [Свойства → Future](#8-свойства--future)
9. [Ошибки](#9-ошибки)
10. [StreamController](#10-streamcontroller)
11. [Broadcast-контроллер](#11-broadcast-контроллер)
12. [Жизненный цикл и пауза](#12-жизненный-цикл-и-пауза)
13. [В этом проекте](#13-в-этом-проекте)
14. [Частые ошибки](#14-частые-ошибки)
15. [Шпаргалка на одну страницу](#15-шпаргалка-на-одну-страницу)

---

## 1. Что такое Stream

`Stream<T>` — источник **последовательности** асинхронных событий.

Три вида событий:

| Событие | Смысл |
| --- | --- |
| **data** | Элемент типа `T` |
| **error** | Что-то пошло не так (поток может продолжить или закрыться) |
| **done** | Больше событий не будет |

В отличие от `Future`, значений может быть **ноль, одно или много**. После `done` подписка завершена.

```dart
Stream<int> ticks() async* {
  for (var i = 0; i < 3; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    yield i;
  }
}
// 0, 1, 2 → done
```

---

## 2. Future vs Stream

| | `Future<T>` | `Stream<T>` |
| --- | --- | --- |
| Сколько значений | Одно | 0…N |
| Конец | completed (value / error) | событие `done` |
| Чтение | `await` | `await for` / `listen` |
| «Первый элемент» | сам Future | `stream.first` → `Future` |
| Типичный API | HTTP GET, `getDoc` | `snapshots()`, typing, auth state |
| Отмена | нет встроенной | `subscription.cancel()` |

```dart
final first = await chatsStream.first; // Future из Stream
```

В проекте: разовый запрос — `Future<Either<...>>`; живые данные — `Stream<Either<...>>`.

---

## 3. Single-subscription vs broadcast

| | Single-subscription | Broadcast |
| --- | --- | --- |
| Слушателей | **ровно один** за жизнь потока | сколько угодно |
| Старт генерации | обычно после `listen` | события идут, даже если никто не слушает |
| Повторный `listen` | запрещён (даже после cancel) | ок |
| Откуда | `async*`, файл, большинство SDK | `asBroadcastStream`, `StreamController.broadcast` |
| Зачем | непрерывные данные (чанки файла) | независимые наблюдатели (события UI) |

```dart
final single = Stream.fromIterable([1, 2, 3]);
single.listen(print);
// single.listen(print); // StateError: уже слушают / уже слушали

final multi = single.asBroadcastStream();
multi.listen(print);
multi.listen(print); // ок
```

`async*` каждый **вызов** функции даёт **новый** single-subscription stream — повторный вызов `ticks()` безопасен, повторный `listen` на тот же экземпляр — нет.

Firestore: `snapshots()` — single-subscription. Несколько UI-подписчиков на один и тот же raw-stream без обёртки — ошибка. В Riverpod обычно один провайдер держит одну подписку.

---

## 4. Создание Stream

```dart
import 'dart:async';
```

### 4.1. `async*` / `yield` / `yield*`

```dart
Stream<String> names() async* {
  yield 'Alice';
  yield 'Bob';
}

Stream<int> doubled(Stream<int> source) async* {
  await for (final n in source) {
    yield n * 2;
  }
}

Stream<int> forward(Stream<int> source) async* {
  yield* source; // пробросить все data/error/done
}
```

Тело `async*` **не стартует**, пока кто-то не подпишется.

### 4.2. Конструкторы

| Конструктор | Что делает |
| --- | --- |
| `Stream.empty()` | сразу `done` (по умолчанию broadcast с Dart 3.2+) |
| `Stream.value(x)` | один data → `done` |
| `Stream.error(e, [st])` | один error → `done` |
| `Stream.fromIterable(list)` | элементы по очереди |
| `Stream.fromFuture(f)` | один data (или error) из Future → `done` |
| `Stream.fromFutures(fs)` | по мере готовности Future (порядок ≠ порядок списка) |
| `Stream.periodic(d, [fn])` | тики каждые `d`; без `take` — бесконечный |
| `Stream.multi(onListen)` | новый контроллер на каждую подписку |
| `Stream.eventTransformed(...)` | низкоуровневый sink-map |

```dart
Stream<int>.periodic(const Duration(seconds: 1), (i) => i).take(5);
Stream.fromFuture(loadUser()); // Stream<User>
```

### 4.3. Из контроллера

См. [§10](#10-streamcontroller) — когда нужно **пушить** события снаружи (`add`).

---

## 5. Чтение: `await for` и `listen`

### 5.1. `await for` (предпочтительно в `async`)

```dart
Future<void> printAll(Stream<int> s) async {
  try {
    await for (final n in s) {
      print(n);
    }
    print('done');
  } catch (e, st) {
    // ошибка из потока
  }
}
```

`break` / `return` из цикла **отписывает** от потока.

### 5.2. `listen` (колбэки, ручное управление)

```dart
final sub = stream.listen(
  (data) => print(data),
  onError: (Object e, StackTrace st) => log(e, st),
  onDone: () => print('done'),
  cancelOnError: false, // true → отписка на первой ошибке
);
```

`listen` — база всего API Stream; остальное (`map`, `first`, …) внутри тоже подписывается.

| Способ | Когда |
| --- | --- |
| `await for` | последовательная обработка в `async` / `async*` |
| `listen` | нужны pause/cancel, несколько колбэков, «фоновая» подписка |
| `ref.watch(streamProvider)` | UI в Riverpod (подписка/отписка за вас) |

Не вызывайте `listen` в `build()` виджета вручную — утечка подписок.

---

## 6. StreamSubscription

Объект, который возвращает `listen`:

| Член | Смысл |
| --- | --- |
| `cancel()` | отписаться (`Future`, дождитесь при dispose) |
| `pause([resumeSignal])` | попросить источник приостановить |
| `resume()` | продолжить |
| `isPaused` | на паузе ли |
| `onData` / `onError` / `onDone` | заменить колбэки |
| `asFuture([value])` | Future, завершится на `done` или `error` |

```dart
late final StreamSubscription<QuerySnapshot> sub;

@override
void initState() {
  super.initState();
  sub = query.snapshots().listen(onSnap, onError: onErr);
}

@override
void dispose() {
  unawaited(sub.cancel());
  super.dispose();
}
```

В DataSource/Notifier с Riverpod `ref.onDispose` — тот же паттерн.

---

## 7. Трансформации

Возвращают **новый** Stream (тот же режим: single / broadcast, если не сказано иное).

| Метод | Аналог Iterable |
| --- | --- |
| `map` | `map` (синхронно) |
| `asyncMap` | `map` + `await` на каждый элемент |
| `asyncExpand` | каждый элемент → вложенный Stream |
| `expand` | элемент → несколько синхронных |
| `where` | `where` |
| `distinct([equals])` | пропуск равных подряд |
| `skip` / `take` / `skipWhile` / `takeWhile` | как у Iterable |
| `handleError` | перехват части ошибок без остановки |
| `transform(transformer)` | `StreamTransformer` (декодеры и т.п.) |
| `cast<R>()` | смена типа |
| `timeout(d, {onTimeout})` | если слишком долго нет событий |

```dart
final names = usersStream
    .map((u) => u.name)
    .where((n) => n.isNotEmpty)
    .distinct();

final enriched = ids.asyncMap((id) => repo.getChatById(id));
```

`asyncMap` **последовательно** ждёт Future каждого элемента (backpressure). Для параллели — собирайте сами через `Future.wait` осознанно.

`pipe(consumer)` — прокачать события в `StreamConsumer` (например другой sink).

---

## 8. Свойства → Future

Каждое такое свойство/метод **подписывается** на поток (для single — «съедает» единственную подписку).

| API | Результат |
| --- | --- |
| `first` / `last` / `single` | один элемент |
| `length` / `isEmpty` | после `done` |
| `toList()` / `toSet()` | все элементы |
| `any` / `every` / `contains` | предикаты |
| `fold` / `reduce` / `join` | агрегация |
| `forEach` | как `await for` без `break` |
| `drain([v])` | игнор data, Future на done/error |
| `elementAt(i)` | i-й data-event |
| `firstWhere` / `lastWhere` / `singleWhere` | с `orElse` |

```dart
final list = await stream.toList();
final ok = await stream.any((e) => e > 0);
```

На бесконечном `periodic` без `take` — `toList()` / `last` **никогда** не завершатся.

---

## 9. Ошибки

- В `await for` ошибка потока → исключение (ловите `try`/`catch`).
- В `listen` — колбэк `onError`; без него — uncaught async error.
- После ошибки поток **может** продолжить слать data (если источник так устроен); `cancelOnError: true` отпишет сразу.
- `handleError` — перехватить и (опционально) не пробрасывать дальше.

```dart
stream
    .handleError(
      (e, st) => log(e, st),
      test: (e) => e is FormatException,
    )
    .listen(print);
```

В **flutter_echat** ошибки Firebase в DataSource мапятся в `Left(Failure)` и идут как **data** (`Either`), а не как error-event Stream — UI/`fold` проще. «Голый» `addError` наружу из Repository не выпускаем.

---

## 10. StreamController

Контроллер = **вы пишете** в sink, другие **читают** `stream`.

```dart
final c = StreamController<int>(
  onListen: () => print('listen'),
  onPause: () => print('pause'),
  onResume: () => print('resume'),
  onCancel: () => print('cancel'),
  sync: false, // по умолчанию: add асинхронно доставляет слушателю
);

c.stream.listen(print);
c.add(1);
c.addError(StateError('x'));
await c.close(); // done
```

### API

| Член | Смысл |
| --- | --- |
| `stream` | то, что отдаёте наружу |
| `sink` | только запись (`StreamSink`) — удобно отдать «писателю» |
| `add(event)` | data |
| `addError(e, [st])` | error |
| `addStream(other)` | прокачать другой Stream; Future завершится когда other закончится |
| `close()` | больше нельзя `add`; шлёт `done` |
| `done` | Future: контроллер закончил слать |
| `hasListener` | есть подписчик |
| `isClosed` | уже `close` |
| `isPaused` | подписчик на паузе (нужен буфер) |

Обычный `StreamController` — **single-subscription**.

`sync: true` — колбэк слушателя вызывается **синхронно** внутри `add`. Опасно (реентрантность, порядок); нужен редко. По умолчанию `false`.

```dart
// Типичный «мост» из колбэков
Stream<String> codes() {
  late final StreamController<String> c;
  c = StreamController<String>(
    onListen: () {
      startListening((code) => c.add(code));
    },
    onCancel: () {
      stopListening();
    },
  );
  return c.stream;
}
```

После `close()` — `add` бросит. Второй `close` не нужен. Не забывайте `close` / `onCancel`, иначе утечки и «вечные» подписки на SDK.

---

## 11. Broadcast-контроллер

```dart
final c = StreamController<int>.broadcast(
  onListen: () {},
  onCancel: () {}, // когда отписался **последний** слушатель
  sync: false,
);
```

| Отличие от обычного | |
| --- | --- |
| Много `listen` | да |
| События без слушателей | **теряются** (не буферизуются) |
| `onPause` / `onResume` | **нет** (у broadcast-контроллера) |
| Поздний слушатель | видит только будущие события |

```dart
c.add(1); // никто не слушает → 1 пропал
c.stream.listen(print);
c.add(2); // напечатает 2
```

Нужен «последний снимок» новым подписчикам — не чистый broadcast, а свой кеш / `rxdart` `BehaviorSubject` / состояние в Riverpod Notifier. В этом проекте для UI-состояния предпочитаем Riverpod, не ручной broadcast на весь экран.

`asBroadcastStream` на single:

```dart
final broadcast = single.asBroadcastStream(
  onListen: (sub) { /* первая подписка на broadcast */ },
  onCancel: (sub) { /* отписались все → можно sub.cancel() у исходного */ },
);
```

---

## 12. Жизненный цикл и пауза

```
создали stream / controller
  → listen / await for
  → data / error …
  → cancel ИЛИ done (close)
```

Пауза:

```dart
subscription.pause();
// источник лучше тоже тормозить (isPaused у контроллера)
subscription.resume();
// или: subscription.pause(futureThatCompletesWhenReady);
```

Пока `isPaused == true`, контроллер буферизует `add` (память!). На broadcast пауза «по-контроллерному» не та же модель — события просто некому отдать.

`addStream(source)`: пока идёт, не вызывайте `add`/`addError` вручную; дождитесь Future или используйте аккуратно.

---

## 13. В этом проекте

### DataSource → Repository

```dart
// DataSource
Stream<List<ChatDto>> watchChats(String uid) {
  return _firestore
      .collection('chats')
      .where('memberIds', arrayContains: uid)
      .snapshots()
      .map((snap) => snap.docs.map(ChatDto.fromFirestore).toList());
}

// Repository
Stream<Either<Failure, List<Chat>>> watchChats();
```

Ошибки Firestore → `Left` в data-event (или `handleError` + маппинг), не «сырой» exception в UI.

### Riverpod

```dart
@riverpod
Stream<List<Chat>> chatList(Ref ref) {
  return ref.watch(chatRepositoryProvider).watchChats().map(
        (either) => either.getOrElse((_) => <Chat>[]), // или AsyncError через другой паттерн
      );
}
```

Либо Notifier слушает stream и кладёт в `AsyncValue` / Freezed-state. Подписка живёт, пока провайдер слушают; `ref.onDispose` для ручных `StreamSubscription`.

### Когда нужен StreamController

| Нужен | Не нужен |
| --- | --- |
| Адаптер колбэк-API → Stream | Уже есть `snapshots()` / `onValue` |
| Склейка нескольких источников с ручным `add` | Просто `map`/`asyncMap` над одним Stream |
| Тесты с контролируемыми событиями | UI-state → Riverpod Notifier |

Не дублируйте Firebase-stream самодельным контроллером «на всякий случай».

---

## 14. Частые ошибки

| Антипаттерн | Как надо |
| --- | --- |
| Второй `listen` на single-stream | Новый экземпляр / `asBroadcastStream` / один владелец |
| `listen` в `build()` без cancel | Riverpod / `dispose` + `cancel` |
| Забыли `close()` у контроллера | `onCancel` + `close`, или владелец в `dispose` |
| Broadcast: ждут старые события | их нет; кешируйте сами или `first` с нового single |
| `await stream.last` на бесконечном | `take` / явный `close` / `timeout` |
| Путают Stream error и `Either.left` | В репозитории — `Either` в data |
| `asyncMap` думают «параллельно» | Он последовательный |
| Тяжёлая работа в `listen` синхронно | Не блокировать event loop; вынести |
| `sync: true` «для скорости» | Риск реентрантности; почти никогда |

---

## 15. Шпаргалка на одну страницу

```dart
import 'dart:async';

// создать
Stream<int> gen() async* { yield 1; yield 2; }
Stream.value(1);
Stream.fromIterable([1, 2]);
Stream.periodic(const Duration(seconds: 1), (i) => i).take(3);

// читать
await for (final x in stream) { ... }
final sub = stream.listen(onData, onError: onErr, onDone: onDone);
await sub.cancel();

// трансформировать
stream.map(f).where(p).distinct().asyncMap(load).take(10);

// в Future
await stream.first;
await stream.toList();

// контроллер (1 слушатель)
final c = StreamController<int>(onCancel: () { /* stop */ });
c.stream.listen(print);
c.add(1);
c.addError(e);
await c.close();

// broadcast (N слушателей, без буфера истории)
final b = StreamController<int>.broadcast();
b.stream.listen(print);
b.add(1);

// single → multi
final multi = single.asBroadcastStream();
```

| Хочу | Пишу |
| --- | --- |
| Много значений во времени | `Stream` |
| Одно значение | `Future` |
| Пушить снаружи | `StreamController` / `.broadcast` |
| Firestore live | `snapshots()` в DataSource → `Stream<Either<...>>` |
| UI-подписка | `@riverpod` Stream / Notifier + `ref.onDispose` |
| Отписаться | `subscription.cancel()` / выход из `await for` |
| Несколько наблюдателей | broadcast **или** один провайдер Riverpod |
| Ошибка домена | `Either` в событии, не обязательно `addError` |
