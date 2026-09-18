# Шпаргалка: Freezed

Краткая справка по **Freezed 3** для **flutter_echat**. Immutable-модели, unions, `copyWith`, JSON. Связанные документы: [architecture.md](./architecture.md), [dart-classes.md](./dart-classes.md), [dart-riverpod.md](./dart-riverpod.md), [dart-fpdart.md](./dart-fpdart.md).

Официально: [pub.dev/freezed](https://pub.dev/packages/freezed), [миграция 2 → 3](https://github.com/rrousselGit/freezed/blob/master/packages/freezed/migration_guide.md), [freezed_annotation](https://pub.dev/packages/freezed_annotation).

В `architecture.md` зафиксированы версии `freezed: ^3.0.0` / `freezed_annotation: ^3.0.0`. Ниже — стиль **3.x** (обязательны `abstract` / `sealed`; разбор union через `switch`, не `.when` / `.map`).

---

## Содержание

1. [Зачем Freezed](#1-зачем-freezed)
2. [Установка и генерация](#2-установка-и-генерация)
3. [Минимальная модель (abstract)](#3-минимальная-модель-abstract)
4. [Что генерируется](#4-что-генерируется)
5. [Геттеры и методы: `Class._()`](#5-геттеры-и-методы-class_)
6. [@Default, @Assert, defaults](#6-default-assert-defaults)
7. [copyWith и deep copy](#7-copywith-и-deep-copy)
8. [Union / sealed](#8-union--sealed)
9. [Pattern matching (вместо when/map)](#9-pattern-matching-вместо-whenmap)
10. [JSON: fromJson / toJson](#10-json-fromjson--tojson)
11. [Коллекции, @unfreezed, classic class](#11-коллекции-unfreezed-classic-class)
12. [Конфиг @Freezed и build.yaml](#12-конфиг-freezed-и-buildyaml)
13. [Где применять в проекте](#13-где-применять-в-проекте)
14. [Частые ошибки](#14-частые-ошибки)
15. [Шпаргалка на одну страницу](#15-шпаргалка-на-одну-страницу)

---

## 1. Зачем Freezed

Вручную для модели нужны: поля, конструктор, `==` / `hashCode`, `toString`, `copyWith`, иногда JSON и union-типы. Freezed генерирует это из короткого объявления.

| Без Freezed | С Freezed |
| --- | --- |
| Много boilerplate | `@freezed` + factory |
| Легко сломать equality | генерируется |
| Ручной union | `sealed` + несколько factory |
| Вложенный clone | deep `copyWith` |

В **flutter_echat**: entity, DTO, UI state, `Failure` — только Freezed (immutable).

---

## 2. Установка и генерация

```yaml
dependencies:
  freezed_annotation: ^3.0.0
  json_annotation: ^4.9.0   # только если нужен JSON (DTO)

dev_dependencies:
  freezed: ^3.0.0
  build_runner: ^2.4.0
  json_serializable: ^6.9.0 # только для fromJson/toJson
```

В каждом файле с моделью:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
// part 'message.g.dart'; // только если есть fromJson
```

Команды:

```bash
dart run build_runner watch -d
# или одноразово:
dart run build_runner build -d
```

`-d` = удалить конфликтующие outputs.

Опционально в `analysis_options.yaml` (для связки с json_serializable):

```yaml
analyzer:
  errors:
    invalid_annotation_target: ignore
```

---

## 3. Минимальная модель (`abstract`)

**Один** вариант данных → `abstract class` + один factory.

```dart
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
```

| Элемент | Роль |
| --- | --- |
| `@freezed` | включить генератор (immutable) |
| `abstract class` | обязательно для factory-синтаксиса в 3.x |
| `with _$Message` | mixin со сгенерированным API |
| `const factory ... = _Message` | «primary» конструктор; `_Message` сгенерирует Freezed |
| `required` / `?` / позиционные | обычные правила Dart |

**Несколько** вариантов (union) → `sealed class`, см. [§8](#8-union--sealed).

---

## 4. Что генерируется

| API | Описание |
| --- | --- |
| Поля + getters | immutable |
| `copyWith(...)` | клон с заменой полей; `null` сбрасывает nullable |
| `==` / `hashCode` | по значениям полей |
| `toString()` | удобный для логов / DevTools |
| `toJson()` | если объявлен `fromJson` |
| `List`/`Map`/`Set` | по умолчанию **unmodifiable** обёртки |

Импорт `package:flutter/foundation.dart` (или Flutter) улучшает отображение в DevTools — Freezed подхватит Diagnosticable.

---

## 5. Геттеры и методы: `Class._()`

Нельзя просто добавить метод в класс с одним factory — нужен **private empty** (или параметризованный) конструктор, чтобы сгенерированный класс **extends** ваш, а не только implements:

```dart
@freezed
abstract class Message with _$Message {
  const Message._();

  const factory Message({
    required String id,
    required String? text,
    // ...
  }) = _Message;

  bool get hasText => text != null && text!.isNotEmpty;
}
```

То же для shared-методов у `sealed` (как `Failure.displayMessage` в architecture).

`Class._()` также нужен для:

- non-constant defaults (`DateTime.now()`);
- `extends Super` + `super(...)`;
- asserts в generative-конструкторе (альтернатива `@Assert`).

---

## 6. `@Default`, `@Assert`, defaults

В redirecting factory **нельзя** писать `= 42` и `assert(...)` по правилам Dart → аннотации Freezed:

```dart
@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    required String phone,
    @Default('') String password,
    @Default(false) bool isSubmitting,
    Option<String> errorMessage,
  }) = _LoginState;
}
```

```dart
@Assert('name.isNotEmpty', 'name cannot be empty')
const factory Person({required String name}) = _Person;
```

`@Default(x)` при JSON сам добавит `@JsonKey(defaultValue: ...)`.

Неконстантный default — через `._()`:

```dart
@freezed
sealed class Response<T> with _$Response<T> {
  Response._({DateTime? time}) : time = time ?? DateTime.now();

  factory Response.data(T value, {DateTime? time}) = ResponseData;
  factory Response.error(Object error) = ResponseError;

  @override
  final DateTime time;
}
```

---

## 7. `copyWith` и deep copy

```dart
final next = state.copyWith(code: '1234', isSubmitting: true);

// nullable: явный null сбрасывает поле
person.copyWith(age: null);
```

Вложенные Freezed-объекты — **deep copy** без ручной вложенности:

```dart
// вместо:
company.copyWith(
  director: company.director.copyWith(
    assistant: company.director.assistant.copyWith(name: 'John'),
  ),
);

// так:
company.copyWith.director.assistant(name: 'John');
company.copyWith.director(name: 'Larry');
```

Если промежуточное поле nullable:

```dart
company.copyWith.director.assistant?.call(name: 'John');
```

У **union** `copyWith` видит только **общие** поля всех вариантов. Поля одного case — через pattern matching + `copyWith` на конкретном типе.

---

## 8. Union / `sealed`

Несколько factory → sum-type. В Freezed 3: **`sealed class`**.

```dart
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

| Имя справа от `=` | Класс варианта |
| --- | --- |
| `= NetworkFailure` | публичный тип `NetworkFailure` |
| `= _Message` | приватный (один case) |

**Общие поля** — параметры с одинаковым именем/типом во всех factory → доступны на базовом типе и в `copyWith`.

Персональные интерфейсы у одного case:

```dart
@Implements<GeographicArea>()
@With<Shop>()
factory Example.city(String name) = City;
```

**Eject** case (класс пишете сами в той же library):

```dart
factory Result.error(Object error) = ResultError; // свой ResultError extends Result
```

---

## 9. Pattern matching (вместо when/map)

В Freezed **3** методы `.when` / `.map` / `.maybeWhen` **не генерируются**. Используйте Dart patterns:

```dart
final text = switch (failure) {
  NetworkFailure(:final message) => message ?? 'offline',
  AuthFailure(:final reason) => reason.message,
  FirestoreFailure(:final code) => code,
  NotFoundFailure() => '404',
  UnexpectedFailure(:final error) => '$error',
};

if (failure case NetworkFailure(:final message?)) {
  showSnack(message ?? 'Нет сети');
}

// нужен весь объект варианта:
switch (model) {
  case First(:final a):
    return a;
  case Second value:
    return value.copyWith(c: true);
}
```

`sealed` делает `switch` **exhaustive** — новый factory сломает незакрытые switch (это желаемо).

---

## 10. JSON: `fromJson` / `toJson`

Только для **DTO** (Firestore и т.п.). Domain entity в проекте — **без** JSON.

```dart
@freezed
abstract class MessageDto with _$MessageDto {
  const factory MessageDto({
    required String id,
    required String senderId,
    required String type,
    String? text,
    @TimestampConverter() required DateTime createdAt,
    @JsonKey(name: 'chat_id') String? chatId,
  }) = _MessageDto;

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);
}
```

Нужно:

1. `part '….g.dart';`
2. `factory … fromJson(...) => _$…FromJson(json);` (**обязательно** `=>`, не блок `{ return …; }`)
3. пакеты `json_annotation` + `json_serializable`

Freezed дернёт json_serializable и добавит `toJson()`.

### Union + JSON

По умолчанию в JSON появляется runtime-ключ (часто `runtimeType`). Настройка:

```dart
@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.pascal)
sealed class MyResponse with _$MyResponse {
  const factory MyResponse.data(String value) = MyResponseData;

  @FreezedUnionValue('SpecialCase')
  const factory MyResponse.special(int code) = MyResponseSpecial;

  factory MyResponse.fromJson(Map<String, dynamic> json) =>
      _$MyResponseFromJson(json);
}
```

### Generics

```dart
@Freezed(genericArgumentFactories: true)
abstract class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse(T data) = _ApiResponse;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);
}
```

---

## 11. Коллекции, `@unfreezed`, classic class

### Коллекции

По умолчанию `@freezed` → `list.add` бросит (unmodifiable). Нужна мутация содержимого:

```dart
@Freezed(makeCollectionsUnmodifiable: false)
abstract class Example with _$Example {
  factory Example(List<int> list) = _Example;
}
```

В проекте предпочтительнее: `copyWith(items: [...state.items, newItem])`.

### `@unfreezed`

Мутабельные поля, **нет** value `==` / `hashCode`, нельзя `const`. В **flutter_echat** не использовать для entity / state / Failure.

### Classic class (mixed mode)

Пишете обычные поля сами — Freezed только `==` / `toString` / `copyWith`:

```dart
@freezed
class Person with _$Person {
  const Person({required this.name, required this.age});
  final String name;
  final int age;
}
```

Удобно, когда factory-синтаксис мешает (`super`, сложные defaults). Для стандартных моделей проекта — factory + `abstract`/`sealed`.

---

## 12. Конфиг `@Freezed` и `build.yaml`

На класс:

```dart
@Freezed(
  copyWith: true,
  equal: true,
  toStringOverride: true,
  toJson: true,
  fromJson: true,
  unionKey: 'type',
  makeCollectionsUnmodifiable: true,
)
```

На проект — `build.yaml`:

```yaml
targets:
  $default:
    builders:
      freezed:
        options:
          # copyWith: false
```

`@freezed` ≈ `@Freezed()` с дефолтами; `@unfreezed` — мутабельный вариант.

---

## 13. Где применять в проекте

| Объект | Freezed | JSON | Форма |
| --- | --- | --- | --- |
| Domain entity | да | нет | `@freezed abstract` |
| DTO (Firestore) | да | да | `@freezed abstract` + `fromJson` |
| UI state (форма, экран) | да | нет | `@freezed abstract` + `@Default` |
| Failure / union | да | нет | `@freezed sealed` |
| Простые метки | нет → `enum` | — | `MessageType`, `MessageStatus` |
| Repository | нет | — | `abstract` / `abstract interface` |

Маппинг DTO → entity — extension, не JSON у entity:

```dart
extension MessageDtoX on MessageDto {
  Message toEntity(String chatId) => Message(
        id: id,
        chatId: chatId,
        // ...
      );
}
```

Обновление UI state в Notifier:

```dart
state = state.copyWith(isSubmitting: true, errorMessage: none());
```

---

## 14. Частые ошибки

| Антипаттерн | Как надо |
| --- | --- |
| `@freezed class` без `abstract`/`sealed` (factory) | Freezed 3: `abstract` или `sealed` |
| Union как `abstract` | `sealed` + exhaustive `switch` |
| `.when` / `.map` | `switch` / `if-case` |
| Метод без `Class._()` | добавить `const Class._();` |
| `fromJson` блоком `{ return …; }` | только `=> _$XFromJson(json)` |
| JSON у domain entity | JSON только у DTO |
| `@unfreezed` для state | только `@freezed` |
| `list.add` на поле Freezed | `copyWith(list: [...list, x])` |
| Забыли `part` / не запустили codegen | `build_runner watch -d` |
| Default без `@Default` | `@Default(value)` |
| Путают Riverpod `async.when` и Freezed `.when` | `AsyncValue.when` остаётся; Freezed unions — `switch` |

---

## 15. Шпаргалка на одну страницу

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'x.freezed.dart';
// part 'x.g.dart'; // если JSON

// одна модель
@freezed
abstract class User with _$User {
  const User._(); // если нужны методы/геттеры

  const factory User({
    required String id,
    @Default('') String bio,
  }) = _User;

  bool get hasBio => bio.isNotEmpty;
}

// union
@freezed
sealed class Failure with _$Failure {
  const Failure._();
  const factory Failure.network([String? message]) = NetworkFailure;
  const factory Failure.notFound() = NotFoundFailure;

  String get displayMessage => switch (this) {
        NetworkFailure(:final message) => message ?? 'offline',
        NotFoundFailure() => '404',
      };
}

// DTO + JSON
@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    @JsonKey(name: 'full_name') required String name,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}

// использование
final u2 = user.copyWith(bio: 'hi');
final msg = switch (failure) {
  NetworkFailure(:final message) => message,
  NotFoundFailure() => null,
};
```

```bash
dart run build_runner watch -d
```

| Хочу | Пишу |
| --- | --- |
| Immutable model | `@freezed abstract class` |
| Union + exhaustive switch | `@freezed sealed class` |
| Default поля | `@Default(...)` |
| Методы / shared API | `const Class._();` |
| JSON | `fromJson` + `part '*.g.dart'` |
| Клон | `copyWith` / deep `copyWith.a.b(...)` |
| Разбор union | `switch` / `if-case` |
| Entity в E-Chat | Freezed, без JSON |
| DTO в E-Chat | Freezed + json_serializable |
| Failure | `@freezed sealed` |
