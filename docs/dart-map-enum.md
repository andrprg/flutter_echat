# Шпаргалка: `Map` и `enum`

Краткая справка по словарям и перечислениям Dart для **flutter_echat**. Связанные документы: [architecture.md](./architecture.md), [dart-classes.md](./dart-classes.md), [dart-freezed.md](./dart-freezed.md), [dart-fpdart.md](./dart-fpdart.md).

Официально: [Map](https://api.dart.dev/dart-core/Map-class.html), [Enums](https://dart.dev/language/enums), [Collections](https://dart.dev/language/collections).

---

## Содержание

1. [Map — основы](#1-map--основы)
2. [Создание Map](#2-создание-map)
3. [Чтение и запись](#3-чтение-и-запись)
4. [Итерация и преобразования](#4-итерация-и-преобразования)
5. [Типы Map (порядок и равенство)](#5-типы-map-порядок-и-равенство)
6. [Map и JSON / Firestore](#6-map-и-json--firestore)
7. [enum — основы](#7-enum--основы)
8. [Enhanced enum](#8-enhanced-enum)
9. [Switch и имена](#9-switch-и-имена)
10. [enum vs sealed / Map](#10-enum-vs-sealed--map)
11. [В этом проекте](#11-в-этом-проекте)
12. [Частые ошибки](#12-частые-ошибки)
13. [Шпаргалка на одну страницу](#13-шпаргалка-на-одну-страницу)

---

## 1. Map — основы

`Map<K, V>` — набор пар **ключ → значение**. У каждого ключа ровно одно значение. Ключи уникальны по `==` / `hashCode` (или по identity — см. ниже).

```dart
final ages = <String, int>{
  'Alice': 30,
  'Bob': 25,
};

print(ages['Alice']); // 30
print(ages['Zoe']);   // null
```

| Свойство | Смысл |
| --- | --- |
| `length` | число пар |
| `isEmpty` / `isNotEmpty` | пуст ли |
| `keys` | Iterable ключей |
| `values` | Iterable значений |
| `entries` | Iterable `MapEntry<K, V>` |

В domain / presentation проекта **не** держите сырой `Map<String, dynamic>` — только в DTO / DataSource на границе JSON.

---

## 2. Создание Map

```dart
// литерал (LinkedHashMap — порядок вставки)
final m = <String, int>{'a': 1, 'b': 2};
final empty = <String, int>{};

// spread / if / for в литерале
final merged = {
  ...m,
  if (includeC) 'c': 3,
  for (final e in list) e.id: e.name,
};

Map<String, int>();                    // пустой LinkedHashMap
Map.of(m);                             // копия, те же типы
Map.from(other);                       // копия, ключи/значения могут быть dynamic→cast
Map.fromEntries(entries);
Map.fromIterable(items, key: (e) => e.id, value: (e) => e.name);
Map.fromIterables(keys, values);       // длины должны совпадать
Map.unmodifiable(m);                   // нельзя менять
Map.identity();                        // сравнение ключей по identity
```

| Конструктор | Когда |
| --- | --- |
| `{}` / `Map()` | обычный словарь, порядок вставки |
| `Map.of` | типобезопасная копия |
| `Map.from` | из «чужого» Map (осторожно с типами) |
| `Map.unmodifiable` | заморозить снимок |
| `Map.identity` | ключи сравниваются через `identical` |

---

## 3. Чтение и запись

```dart
m['a'];              // V? — нет ключа → null (даже если V non-null!)
m['a'] = 10;         // записать / перезаписать
m.containsKey('a');
m.containsValue(10);

m.putIfAbsent('x', () => compute()); // добавить, только если ключа нет; вернёт значение
m.update('a', (v) => v + 1, ifAbsent: () => 0);
m.updateAll((k, v) => v * 2);

m.addAll(other);
m.addEntries([MapEntry('z', 9)]);
m.remove('a');                       // V? удалённое значение
m.removeWhere((k, v) => v < 0);
m.clear();
```

**Важно:** `operator []` всегда возвращает `V?`. Для non-null `V` отсутствие ключа ≠ «значение null в map» — отличить нельзя одним `[]`. Проверяйте `containsKey` или используйте nullable `V`.

```dart
final v = m['a'];
if (v != null) { /* есть значение */ }

// или
if (m.containsKey('a')) {
  final v = m['a']!; // ключ есть; для V non-null ок
}
```

Null-aware:

```dart
m['a'] ??= 0;
final x = m['a'] ?? 0;
```

---

## 4. Итерация и преобразования

```dart
for (final e in m.entries) {
  print('${e.key} → ${e.value}');
}

m.forEach((key, value) { ... });

final next = m.map((k, v) => MapEntry(k.toUpperCase(), v * 2));

final keys = m.keys.where((k) => k.startsWith('a'));
final vals = m.values.toList();
```

Нельзя **структурно менять** map (добавлять/удалять ключи) во время `forEach` / итерации по `keys`/`values`/`entries` — будет ошибка или неопределённое поведение. Собирайте список ключей заранее или стройте новый Map.

Collection-if / spread удобны для immutable-обновлений (в духе Freezed state):

```dart
state = state.copyWith(
  drafts: {
    ...state.drafts,
    chatId: text,
  },
);

// удалить ключ
state = state.copyWith(
  drafts: {
    for (final e in state.drafts.entries)
      if (e.key != chatId) e.key: e.value,
  },
);
```

У Freezed `@freezed` коллекции по умолчанию **unmodifiable** — мутировать `.add` нельзя, только `copyWith` с новым Map.

---

## 5. Типы Map (порядок и равенство)

| Реализация | Порядок | Ключи |
| --- | --- | --- |
| `LinkedHashMap` (дефолт `{}`) | порядок вставки | `==` / `hashCode` |
| `HashMap` | не гарантирован | `==` / `hashCode` |
| `SplayTreeMap` | отсортированные ключи | `Comparable` / comparator |
| `Map.identity` / `LinkedHashMap.identity` | вставка | `identical` |

```dart
import 'dart:collection';

final sorted = SplayTreeMap<String, int>.from(m);
final identity = Map<Object, int>.identity();
```

Для ключей-объектов реализуйте корректные `==` и `hashCode` (Freezed делает это сам). Не меняйте поля, участвующие в `hashCode`, пока объект — ключ в Map.

---

## 6. Map и JSON / Firestore

На границе сериализации типичный тип — `Map<String, dynamic>`:

```dart
factory MessageDto.fromJson(Map<String, dynamic> json) =>
    _$MessageDtoFromJson(json);

final map = dto.toJson(); // Map<String, dynamic>
await doc.set(map);
```

Чтение «сырого» документа:

```dart
final data = snap.data(); // Map<String, dynamic>?
final text = data?['text'] as String?;
```

Правила проекта:

| Слой | Map |
| --- | --- |
| DataSource / DTO JSON | да, `Map<String, dynamic>` |
| Domain entity | нет — Freezed / поля |
| Presentation | нет — Freezed state; не таскать dynamic Map в UI |

Касты безопаснее через json_serializable / конвертеры, не россыпью `as` по всему коду.

---

## 7. enum — основы

`enum` — фиксированный набор **именованных констант**. Switch по enum **exhaustive** (как у `sealed`).

```dart
enum MessageType { text, image, video, audio, voice, file, system }

enum MessageStatus { sending, sent, delivered, read, failed }
```

```dart
final t = MessageType.text;
t == MessageType.text;     // true
t.index;                   // 0 — позиция в объявлении
t.name;                    // 'text'
MessageType.values;        // List<MessageType> всех значений
```

Сравнение — по identity констант (`==` переопределять нельзя).

---

## 8. Enhanced enum

Enum может иметь поля, методы, `implements`, mixins — с ограничениями:

- поля только `final`;
- generative-конструкторы только `const`;
- все значения перечислены **в начале**;
- нельзя объявить свой член `values`;
- нельзя override `index`, `==`, `hashCode`;
- factory может вернуть только один из известных инстансов.

```dart
enum MessageStatus {
  sending(label: 'Отправка'),
  sent(label: 'Отправлено'),
  delivered(label: 'Доставлено'),
  read(label: 'Прочитано'),
  failed(label: 'Ошибка');

  const MessageStatus({required this.label});

  final String label;

  bool get isTerminal => this == read || this == failed;
}
```

```dart
enum Vehicle implements Comparable<Vehicle> {
  car(tires: 4),
  bus(tires: 6),
  bike(tires: 2);

  const Vehicle({required this.tires});
  final int tires;

  @override
  int compareTo(Vehicle other) => tires - other.tires;
}
```

---

## 9. Switch и имена

```dart
String label(MessageStatus s) => switch (s) {
      MessageStatus.sending => '…',
      MessageStatus.sent => '✓',
      MessageStatus.delivered => '✓✓',
      MessageStatus.read => '✓✓ (read)',
      MessageStatus.failed => '!',
    };
```

Новый член enum → все exhaustive `switch` нужно обновить (breaking, и это хорошо).

### Имя ↔ значение (JSON / Firestore string)

```dart
// enum → строка
final raw = MessageType.image.name; // 'image'

// строка → enum (точное имя)
final type = MessageType.values.byName('image');

// безопасный разбор
MessageType? tryParse(String raw) {
  for (final v in MessageType.values) {
    if (v.name == raw) return v;
  }
  return null;
}

// или:
MessageType.values.asNameMap()[raw]; // Map<String, MessageType>
```

В architecture DTO хранит `type` как `String`, entity — как enum:

```dart
type: MessageType.values.byName(type), // из DTO string
```

`byName` бросает, если имени нет — на границе DataSource ловите / мапьте в `Failure` или default.

По индексу (хрупко при перестановке!):

```dart
MessageStatus.values[0]; // sending
```

Для wire-формата предпочитайте `.name` / `byName`, не `index`.

---

## 10. enum vs sealed / Map

| Нужно | Выбор |
| --- | --- |
| Фиксированные метки без разных полей (или с общими полями) | `enum` / enhanced enum |
| Варианты с **разной** структурой (`network(msg)` vs `notFound()`) | `@freezed sealed` |
| Произвольные ключи / JSON-объект | `Map` (только на границе) |
| Lookup «строка → значение» для enum | `values.asNameMap()` / `byName` |
| Lookup произвольных id → entity | `Map<String, Chat>` в state / кеше |

```dart
// метки
enum MessageType { text, image, video }

// ошибки с разными полями — не enum
@freezed
sealed class Failure with _$Failure { ... }
```

---

## 11. В этом проекте

```dart
// domain
enum MessageType { text, image, video, audio, voice, file, system }
enum MessageStatus { sending, sent, delivered, read, failed }

// DTO: type как String в JSON
type: MessageType.values.byName(type),

// UI switch / when по статусу
switch (message.status) { ... }
```

| Место | Практика |
| --- | --- |
| Тип сообщения / статус | `enum` |
| Failure | sealed Freezed, не Map кодов |
| Firestore document | `Map` ↔ DTO `fromJson`/`toJson` |
| Кеш id→модель в Notifier | `Map<String, T>` внутри Freezed state ок, обновлять через `copyWith` |
| Domain/UI | без `Map<String, dynamic>` |

---

## 12. Частые ошибки

| Антипаттерн | Как надо |
| --- | --- |
| `m['k']` и ждут non-null без проверки | `containsKey` / `??` / `!` осознанно |
| Мутация Map во время `forEach` | новый Map или копия ключей |
| `Map.from` без понимания типов | `Map.of` / явные касты на границе |
| `dynamic` Map в entity | Freezed fields |
| `index` в API/Firestore | `.name` / `byName` |
| `byName` без try на грязных данных | `asNameMap()[raw]` / try/catch → Failure |
| enum для Failure с payload | `sealed` Freezed |
| `list.add` / `map[k]=` у поля Freezed | `copyWith` с новым литералом |
| Переставили значения enum и сломали index в БД | никогда не персистить `index` |

---

## 13. Шпаргалка на одну страницу

```dart
// Map
final m = <String, int>{'a': 1};
m['b'] = 2;
m['a'];                    // int?
m.putIfAbsent('c', () => 3);
m.update('a', (v) => v + 1);
final n = {for (final e in m.entries) e.key: e.value * 2};
final frozen = Map.unmodifiable(m);

// JSON
Map<String, dynamic> json = dto.toJson();
final id = json['id'] as String?;

// enum
enum MessageType { text, image, video }
MessageType.text.name;                 // 'text'
MessageType.values.byName('image');
MessageType.values.asNameMap();

String label(MessageType t) => switch (t) {
      MessageType.text => 'Текст',
      MessageType.image => 'Фото',
      MessageType.video => 'Видео',
    };

// enhanced
enum Status {
  ok(code: 0),
  err(code: 1);
  const Status({required this.code});
  final int code;
}
```

| Хочу | Пишу |
| --- | --- |
| Ключ → значение | `Map<K, V>` / `{...}` |
| Не менять | `Map.unmodifiable` / Freezed copyWith |
| JSON document | `Map<String, dynamic>` только в DTO |
| Фиксированные варианты | `enum` |
| Enum ↔ строка | `.name` / `values.byName` / `asNameMap` |
| Exhaustive UI | `switch (enumValue)` |
| Разные поля у вариантов | `sealed` Freezed, не enum |
| Сообщение / статус в E-Chat | `MessageType` / `MessageStatus` |
