# Шпаргалка: классы Dart (включая `sealed`)

Краткая справка по ООП Dart 3 для **flutter_echat**. Рядом: [dart-future.md](./dart-future.md), [dart-stream.md](./dart-stream.md), [dart-freezed.md](./dart-freezed.md), [dart-map-enum.md](./dart-map-enum.md). В проекте модели и ошибки — Freezed (`@freezed` / `@freezed sealed`) — см. [architecture.md](./architecture.md).

Официально: [Classes](https://dart.dev/language/classes), [Class modifiers](https://dart.dev/language/class-modifiers), [Modifiers for APIs](https://dart.dev/language/class-modifiers-for-apis), [Constructors](https://dart.dev/language/constructors), [Mixins](https://dart.dev/language/mixins).

---

## Содержание

1. [Основы класса](#1-основы-класса)
2. [Конструкторы](#2-конструкторы)
3. [extends / implements / with](#3-extends--implements--with)
4. [Модификаторы классов (таблица)](#4-модификаторы-классов-таблица)
5. [abstract](#5-abstract)
6. [sealed — подробно](#6-sealed--подробно)
7. [base / interface / final](#7-base--interface--final)
8. [mixin и mixin class](#8-mixin-и-mixin-class)
9. [Паттерны и exhaustive switch](#9-паттерны-и-exhaustive-switch)
10. [enum vs sealed](#10-enum-vs-sealed)
11. [В этом проекте (Freezed)](#11-в-этом-проекте-freezed)
12. [Частые ошибки](#12-частые-ошибки)
13. [Шпаргалка на одну страницу](#13-шпаргалка-на-одну-страницу)

---

## 1. Основы класса

Каждый объект — экземпляр класса. У класса ровно один суперкласс (`extends`); доп. поведение — через `with` (mixin) и `implements` (контракт).

```dart
class Point {
  double x;
  double y;

  Point(this.x, this.y);

  double distanceTo(Point other) { /* ... */ return 0; }
}

final p = Point(2, 2);
print(p.x);
print(p.runtimeType); // Point
```

| Член | Смысл |
| --- | --- |
| instance field | данные объекта; неявный getter; если не `final` — setter |
| `final` field | один раз при создании |
| `late` | отложенная инициализация (осторожно с API) |
| method | функция на экземпляре, есть `this` |
| getter / setter | `T get name` / `set name(T v)` |
| `static` | принадлежит классу, без `this` |
| `_name` | library-private (файл / часть library) |

Без модификатора `class X` снаружи библиотеки можно: **конструировать**, **extends**, **implements**, а с Dart 3 — **не** использовать в `with`, если это не `mixin` / `mixin class`.

---

## 2. Конструкторы

```dart
class User {
  final String id;
  final String name;

  // generative
  User(this.id, this.name);

  // named
  User.guest() : id = 'guest', name = 'Guest';

  // initializer list + body
  User.normalized(String raw)
      : id = raw.trim(),
        name = raw.toUpperCase();

  // const — compile-time, канонические экземпляры
  const User.system() : id = '0', name = 'System';

  // factory — может вернуть подтип / кеш / другой конструктор
  factory User.fromJson(Map<String, dynamic> json) {
    return User(json['id'] as String, json['name'] as String);
  }

  // redirecting
  User.empty() : this('', '');
}
```

| Вид | Заметка |
| --- | --- |
| Generative | создаёт именно этот класс |
| `factory` | не обязан создавать новый; нет initializer list с `this.` полями напрямую как у generative |
| `const` | все поля `final`, аргументы константны |
| Redirecting `: this(...)` | делегирует другому конструктору того же класса |
| Super `: super(...)` | вызов конструктора родителя |

У `abstract` / `sealed` generative-конструктор снаружи не вызвать; **factory** на sealed — ок (часто у Freezed).

---

## 3. `extends` / `implements` / `with`

| Ключевое слово | Что берёте |
| --- | --- |
| `extends` | одну реализацию-родителя (код + контракт) |
| `implements` | только контракт (все члены заново) |
| `with` | тела mixin’ов (несколько) |

```dart
class Animal {
  void eat() {}
}

mixin Flyer {
  void fly() {}
}

class Bird extends Animal with Flyer {
  void tweet() {}
}

class FakeBird implements Bird {
  @override
  void eat() {}
  @override
  void fly() {}
  @override
  void tweet() {}
}
```

Порядок: `class C extends Super with Mixin1, Mixin2 implements I1, I2`.

Каждый класс неявно задаёт интерфейс из своих instance-членов — поэтому `implements Point` законно даже без слова `interface`.

---

## 4. Модификаторы классов (таблица)

Ограничения действуют **из других libraries** (другой файл без `part of` / другой пакет). Внутри своей library правила мягче.

| Объявление | new | extends | implements | with | Exhaustive switch |
| --- | --- | --- | --- | --- | --- |
| `class` | ✅ | ✅ | ✅ | ❌* | ❌ |
| `mixin class` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `mixin` | ❌ | ❌ | ✅† | ✅ | ❌ |
| `abstract class` | ❌ | ✅ | ✅ | ❌* | ❌ |
| `base class` | ✅ | ✅‡ | ❌ | ❌* | ❌ |
| `interface class` | ✅ | ❌ | ✅ | ❌ | ❌ |
| `abstract interface class` | ❌ | ❌ | ✅ | ❌ | ❌ |
| `final class` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `sealed class` | ❌ | ❌§ | ❌§ | ❌ | ✅ |

\* `with` только если `mixin` / `mixin class`.  
† mixin нельзя `extends`, но его интерфейс можно `implements`.  
‡ подтипы `base`/`final`/`sealed` снаружи тоже должны быть `base`/`final`/`sealed`.  
§ снаружи; **внутри той же library** — можно (иначе не будет подтипов для switch).

Порядок ключевых слов:

```text
[abstract] [base | interface | final | sealed] [mixin] class Name
```

Нельзя: `abstract` + `sealed` (sealed уже abstract); `interface`/`final`/`sealed` + `mixin`.

---

## 5. `abstract`

Нельзя создать экземпляр. Может содержать абстрактные методы (без тела) и обычные.

```dart
abstract class Repository {
  Future<Chat> getById(String id); // abstract

  String describe() => 'repo'; // concrete — можно наследовать
}

class ChatRepositoryImpl extends Repository {
  @override
  Future<Chat> getById(String id) async => /* ... */ Chat();
}
```

Частый паттерн «чистый контракт»:

```dart
abstract interface class ChatRepository {
  Stream<Either<Failure, List<Chat>>> watchChats();
  Future<Either<Failure, Chat>> getChatById(String chatId);
}
```

Снаружи: только `implements`, не `extends`. Внутри library `extends` всё ещё можно.

---

## 6. `sealed` — подробно

**Зачем:** закрытое семейство подтипов + **exhaustive** `switch` / pattern matching. Компилятор знает все **прямые** подтипы, потому что они обязаны жить в **той же library**.

### Правила

1. `sealed` ⇒ неявно `abstract` ⇒ `Vehicle()` нельзя.
2. Прямые подтипы (`extends` / `implements` / `with` / `on`) — **только в той же library**.
3. Подтипы **не** обязаны быть abstract; их можно конструировать.
4. Ограничение **не транзитивно**: снаружи нельзя наследовать `Vehicle`, но можно наследовать `Car`, если `Car` не `final`/`sealed`/`base`.
5. Factory-конструкторы у sealed — можно.
6. Новый прямой подтип в library = **breaking change** для всех exhaustive switch (как новое значение enum).

```dart
// vehicle.dart — одна library
sealed class Vehicle {
  const Vehicle();
}

class Car extends Vehicle {
  final int seats;
  Car(this.seats);
}

class Truck implements Vehicle {
  final double tons;
  Truck(this.tons);
}

class Bike extends Vehicle {}

String kind(Vehicle v) => switch (v) {
      Car(:final seats) => 'car($seats)',
      Truck(:final tons) => 'truck($tons)',
      Bike() => 'bike',
      // default не нужен — exhaustive
    };
```

```dart
// other.dart
class Taxi extends Car { ... }   // ок (непрямой подтип)
class Scooter extends Vehicle {} // ERROR снаружи
```

### `sealed` vs `final`

| | `sealed` | `final` |
| --- | --- | --- |
| Инстанс самого типа | нет (abstract) | да (если не abstract) |
| Подтипы в своей library | да, ради union | можно, но редкость |
| Exhaustive switch | **да** | нет → нужен `default` / `_` |
| Добавить подтип позже | breaking для switch | можно; старый `default` поймает |
| Смысл | «это sum-type / union» | «закрыть иерархию, эволюция API» |

Нет подтипов и нужен объект — берите `final`, не `sealed`.

### Когда `sealed`

- ошибки / результат: `Failure`, `AuthState`
- шаги флоу: OTP, загрузка сообщения
- любой closed union с полями (богаче, чем `enum`)

---

## 7. `base` / `interface` / `final`

### `base`

Снаружи можно `extends` / `with`, **нельзя** `implements`. Гарантия: у каждого экземпляра есть реальная реализация (в т.ч. private-члены). Подтипы снаружи — тоже `base` | `final` | `sealed`.

```dart
base class Engine {
  void _tick() {}
  void start() => _tick();
}

base class DieselEngine extends Engine {}
```

### `interface`

Снаружи можно `implements` и часто `new`, **нельзя** `extends`. Свои методы вызывают «свои» реализации — меньше fragile base class.

### `final`

Снаружи нельзя ни `extends`, ни `implements`, ни `with`. Максимальная свобода эволюции API. Внутри library подтипы ещё возможны.

### Быстрый выбор

| Цель | Модификатор |
| --- | --- |
| Контракт для моков / impl | `abstract interface class` |
| Наследовать код, запретить «пустой» implements | `base class` |
| Закрыть тип, можно `new` | `final class` |
| Union + exhaustive switch | `sealed class` |
| Модель данных без иерархии | обычный / Freezed `abstract class` |

---

## 8. `mixin` и `mixin class`

```dart
mixin Logger {
  void log(String m) => print(m);
}

mixin Validator on FormState { // только на подтипах FormState
  bool get isValid;
}

mixin class Timestamped {
  DateTime createdAt = DateTime.now();
}

class Screen with Logger {}
class Model extends Timestamped {}
class Model2 with Timestamped {}
```

| Объявление | `new` | `extends` | `with` |
| --- | --- | --- | --- |
| `mixin` | ❌ | ❌ | ✅ |
| `mixin class` | ✅ | ✅ | ✅ |

`on Super` ограничивает, куда можно подмешать mixin.

---

## 9. Паттерны и exhaustive switch

`sealed` раскрывает силу pattern matching:

```dart
String message(Failure f) => switch (f) {
      NetworkFailure(:final message) => message ?? 'Нет сети',
      AuthFailure(:final reason) => reason.message,
      FirestoreFailure(:final code) => 'Ошибка базы: $code',
      NotFoundFailure() => 'Не найдено',
      UnexpectedFailure() => 'Что-то пошло не так',
    };

// if-case
if (f case NetworkFailure(:final message?)) {
  showSnack(message ?? 'offline');
}
```

Без sealed компилятор потребует `default` / `_`, даже если вы перечислили все известные классы.

`enum` тоже exhaustive — для простых вариантов без разных полей часто хватает enum.

---

## 10. `enum` vs `sealed`

Подробнее про enum и Map: [dart-map-enum.md](./dart-map-enum.md).

| | `enum` | `sealed` + классы |
| --- | --- | --- |
| Варианты | фиксированный список | классы с разными полями |
| Поля у варианта | enhanced enum может | любые, разные у каждого |
| Exhaustive switch | да | да |
| Наследование | нет | подтипы / implements |
| В проекте | `MessageType`, `MessageStatus` | `Failure`, UI unions |

```dart
enum MessageStatus { sending, sent, delivered, read, failed }

sealed class LoadState {}
class Loading extends LoadState {}
class Ready extends LoadState {
  final List<Chat> chats;
  Ready(this.chats);
}
class Failed extends LoadState {
  final Failure error;
  Failed(this.error);
}
```

---

## 11. В этом проекте (Freezed)

Подробная шпаргалка: [dart-freezed.md](./dart-freezed.md).

### Entity / DTO / UI state — без sealed

Один вариант данных:

```dart
@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String chatId,
    // ...
  }) = _Message;
}
```

### Ошибки и unions — sealed

```dart
@freezed
sealed class Failure with _$Failure {
  const Failure._();

  const factory Failure.network([String? message]) = NetworkFailure;
  const factory Failure.auth(AuthFailureReason reason) = AuthFailure;
  const factory Failure.firestore(String code) = FirestoreFailure;
  const factory Failure.notFound() = NotFoundFailure;
  const factory Failure.unexpected(Object error) = UnexpectedFailure;

  String get displayMessage => switch (this) { /* ... */ };
}
```

Freezed генерирует подтипы в том же файле/`part` — это одна library, условие sealed соблюдено.

### Repository

```dart
abstract class ChatRepository {
  Stream<Either<Failure, List<Chat>>> watchChats();
  Future<Either<Failure, Chat>> getChatById(String chatId);
}
```

Или явно: `abstract interface class ChatRepository` — снаружи только `implements` (удобно для тестов).

### Виджеты / Notifier

```dart
class ChatListScreen extends ConsumerWidget { ... }
class ChatListController extends _$ChatListController { ... }
```

Обычные `class` / codegen Riverpod; sealed здесь не нужен.

### Правило команды

| Тип | Как объявлять |
| --- | --- |
| Domain entity / DTO / простой state | `@freezed abstract class` |
| Failure, multi-case UI/domain union | `@freezed sealed class` |
| Порт репозитория | `abstract class` или `abstract interface class` |
| Простой закрытый набор меток | `enum` |

---

## 12. Частые ошибки

| Антипаттерн | Как надо |
| --- | --- |
| `sealed` без подтипов | бессмысленно; `final` или обычный class |
| Подтип sealed в другом файле без `part of` | другая library → ошибка; держите в одном library |
| Ждут, что sealed запретит наследовать `Car` снаружи | не запретит; пометьте подтипы `final`/`sealed` |
| Switch по обычному abstract без `_` | не exhaustive; сделайте `sealed` или добавьте default |
| `implements` у `base`, чтобы «замокать» | нельзя снаружи; мокайте через интерфейс / Riverpod override |
| Путают `abstract class` и `interface class` | abstract — можно extends; interface — снаружи только implements |
| Класс в `with` без `mixin` | с Dart 3 нужно `mixin` / `mixin class` |
| Добавили вариант Failure и не обновили switch | ожидаемый break; поправьте все exhaustive места |
| Ручной sealed вместо Freezed для Failure | в проекте — Freezed (`copyWith`, equality, codegen) |

---

## 13. Шпаргалка на одну страницу

```dart
// обычный
class User {
  final String id;
  User(this.id);
  factory User.fromJson(Map<String, dynamic> j) => User(j['id'] as String);
}

// контракт
abstract interface class ChatRepository {
  Future<Either<Failure, Chat>> getChatById(String id);
}

// union + exhaustive switch
sealed class Result {}
class Ok extends Result { final int value; Ok(this.value); }
class Err extends Result { final String msg; Err(this.msg); }

String show(Result r) => switch (r) {
      Ok(:final value) => '$value',
      Err(:final msg) => msg,
    };

// закрытый тип (можно new, нельзя subtype снаружи)
final class Token {
  final String value;
  const Token(this.value);
}

// только implements снаружи
interface class Service {
  void start() {}
}

// только extends снаружи (+ base на наследниках)
base class Entity {
  void save() {}
}

// mixin
mixin Disposable {
  void dispose();
}
mixin class IdHolder {
  String id = '';
}
```

| Хочу | Пишу |
| --- | --- |
| Данные + equality / unions | Freezed (`abstract` / `sealed`) |
| Exhaustive разбор вариантов | `sealed` + `switch` |
| Репозиторий / порт | `abstract interface class` |
| Запретить наследование снаружи | `final` |
| Запретить implements, оставить extends | `base` |
| Только контракт, без extends | `interface` / `abstract interface` |
| Простые метки без полей | `enum` |
| Переиспользовать код в нескольких иерархиях | `mixin` / `mixin class` |
