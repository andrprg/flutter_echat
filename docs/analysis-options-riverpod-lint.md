# Настройка `analysis_options.yaml` и riverpod_lint

Инструкция для проекта **flutter_echat**: подключение статического анализа Riverpod 3, правил `riverpod_lint` и интеграции с `flutter_lints`.

Связанные документы: [architecture.md](./architecture.md), [roadmap.md](./roadmap.md).

---

## Содержание

1. [Зачем это нужно](#1-зачем-это-нужно)
2. [Важно: custom_lint больше не нужен](#2-важно-custom_lint-больше-не-нужен)
3. [Зависимости в pubspec.yaml](#3-зависимости-в-pubspecyaml)
4. [Базовая настройка analysis_options.yaml](#4-базовая-настройка-analysis_optionsyaml)
5. [Рекомендуемый конфиг для flutter_echat](#5-рекомендуемый-конфиг-для-flutter_echat)
6. [Включение и отключение правил](#6-включение-и-отключение-правил)
7. [Список правил riverpod_lint](#7-список-правил-riverpod_lint)
8. [Assists в IDE](#8-assists-в-ide)
9. [Проверка в терминале и CI](#9-проверка-в-терминале-и-ci)
10. [Частые проблемы](#10-частые-проблемы)
11. [Чеклист](#11-чеклист)

---

## 1. Зачем это нужно

`riverpod_lint` — плагин анализатора Dart для проектов на Riverpod. Он:

- предупреждает о типичных ошибках (нет `ProviderScope`, неверные `dependencies`, `ref` в `dispose` и т.д.);
- подсказывает quick fix и рефакторинги (обернуть в `ConsumerWidget`, конвертировать `@riverpod` functional ↔ class);
- работает в IDE и в `dart analyze` / `flutter analyze`.

Для **flutter_echat** (стек: Riverpod 3 + `@riverpod` + `riverpod_generator`) это обязательная часть фазы 0 в [roadmap.md](./roadmap.md).

---

## 2. Важно: custom_lint больше не нужен

Начиная с **riverpod_lint 3.1+**, плагин реализован через **`analysis_server_plugin`**, а не через `custom_lint`.

| Было (устарело) | Стало (актуально) |
| --- | --- |
| `dev_dependencies: custom_lint` | не требуется |
| `analyzer: plugins: - custom_lint` | `plugins: riverpod_lint: <version>` на верхнем уровне файла |
| отдельная команда `dart run custom_lint` | достаточно `dart analyze` |

Если в старых заметках или в разделе 10.3 [architecture.md](./architecture.md) указан `custom_lint` — ориентируйтесь на этот документ.

---

## 3. Зависимости в pubspec.yaml

Добавьте пакеты, если их ещё нет (версии — ориентир под Riverpod 3):

```yaml
dependencies:
  flutter_riverpod: ^3.0.0
  riverpod_annotation: ^3.0.0

dev_dependencies:
  flutter_lints: ^6.0.0
  riverpod_generator: ^3.0.0
  riverpod_lint: ^3.1.8
  build_runner: ^2.4.0
```

После изменений:

```bash
flutter pub get
```

`riverpod_lint` должен быть в **dev_dependencies** — плагин подтягивает его из кэша pub, но пакет должен быть объявлен в проекте.

---

## 4. Базовая настройка analysis_options.yaml

Минимальный рабочий вариант (файл в корне рядом с `pubspec.yaml`):

```yaml
include: package:flutter_lints/flutter.yaml

plugins:
  riverpod_lint: 3.1.8
```

Ключевые моменты:

- секция `plugins` — **на верхнем уровне** файла (не внутри `analyzer:`);
- укажите **конкретную версию** или constraint, совместимую с `riverpod_lint` в `pubspec.yaml` (например `^3.1.8` или `3.1.8`);
- `include: package:flutter_lints/flutter.yaml` сохраняет стандартные правила Flutter.

После правки **перезапустите Dart Analysis Server** в IDE:

- VS Code / Cursor: `Dart: Restart Analysis Server`
- Android Studio: **File → Invalidate Caches** или перезапуск IDE

Плагин загружается только при старте analysis server.

---

## 5. Рекомендуемый конфиг для flutter_echat

Полный пример с исключением сгенерированных файлов и строгим анализатором:

```yaml
include: package:flutter_lints/flutter.yaml

plugins:
  riverpod_lint: 3.1.8

analyzer:
  exclude:
    - ".dart_tool/**"
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    missing_required_param: error
    missing_return: error

linter:
  rules:
    prefer_single_quotes: true
    require_trailing_commas: true
    avoid_print: true
```

Почему так:

| Настройка | Назначение |
| --- | --- |
| `exclude` для `*.g.dart`, `*.freezed.dart` | меньше шума от codegen; логику проверяем в исходниках |
| `strict-*` | раннее обнаружение неявных `dynamic` и слабой типизации |
| `prefer_single_quotes`, `require_trailing_commas` | единый стиль с остальным кодом |
| `avoid_print` | в проде — `debugPrint` / логгер |

Скопируйте содержимое в корневой [`analysis_options.yaml`](../analysis_options.yaml) при выполнении задачи из roadmap.

---

## 6. Включение и отключение правил

Правила плагина настраиваются в секции `diagnostics` (формат [analyzer plugins](https://dart.dev/tools/analyzer-plugins)):

```yaml
plugins:
  riverpod_lint:
    version: 3.1.8
    diagnostics:
      # явно включить (если правило по умолчанию выключено)
      missing_provider_scope: true
      # отключить конкретное правило
      provider_dependencies: false
```

Краткий синтаксис `riverpod_lint: 3.1.8` включает набор правил по умолчанию. Расширенный объект с `version` + `diagnostics` нужен, когда хотите точечно отключить правило для всего проекта.

Подавление для одной строки или файла (как у обычных lints):

```dart
// ignore: provider_parameters
ref.watch(myProvider(InlineObject()));

// ignore_for_file: avoid_public_notifier_properties
```

---

## 7. Список правил riverpod_lint

Краткая таблица (актуально для riverpod_lint 3.1.x). Подробности и примеры — на [pub.dev/packages/riverpod_lint](https://pub.dev/packages/riverpod_lint).

| ID правила | Только generator | Суть |
| --- | --- | --- |
| `missing_provider_scope` | нет | `runApp` должен оборачивать дерево в `ProviderScope` |
| `provider_dependencies` | да | корректный список `dependencies` у scoped-провайдеров |
| `scoped_providers_should_specify_dependencies` | да | не-scoped провайдеры не переопределять во вложенном `ProviderScope` |
| `avoid_build_context_in_providers` | да | не передавать `BuildContext` в провайдеры/методы notifier |
| `provider_parameters` | нет | аргументы family должны иметь стабильный `==` |
| `avoid_public_notifier_properties` | нет | публичное состояние только через `.state` |
| `unsupported_provider_value` | да | не возвращать `StateNotifier`/`ChangeNotifier` без `Raw<>` |
| `functional_ref` | да | у functional `@riverpod` первый параметр — `Ref ref` |
| `notifier_extends` | да | класс должен `extends _$ClassName` |
| `avoid_ref_inside_state_dispose` | нет | не использовать `ref` в `dispose` |
| `avoid_keep_alive_dependency_inside_auto_dispose` | да | `keepAlive` не должен зависеть от auto-dispose |
| `notifier_build` | да | у class-notifier обязателен метод `build` |
| `riverpod_syntax_error` | да | синтаксические ошибки `riverpod_generator` |
| `async_value_nullable_pattern` | нет | корректный pattern matching для nullable `AsyncValue` |
| `protected_notifier_properties` | нет | не читать `.state`/`.future` чужого notifier |

Правила с пометкой **generator** срабатывают при использовании `@riverpod` и `riverpod_generator` — это основной сценарий **flutter_echat**.

---

## 8. Assists в IDE

При установленном плагине в контекстном меню (Quick Fix / Refactor) доступны, например:

- обернуть виджет в `Consumer` / `ProviderScope`;
- преобразовать `StatelessWidget` → `ConsumerWidget` / `ConsumerStatefulWidget`;
- конвертировать functional `@riverpod` ↔ class variant.

Если assists не видны — проверьте, что analysis server перезапущен и в `pubspec.yaml` есть `riverpod_lint`.

---

## 9. Проверка в терминале и CI

Локально:

```bash
flutter pub get
dart analyze
# или
flutter analyze
```

В CI (пример шага):

```yaml
- run: flutter pub get
- run: dart analyze --fatal-infos
```

`--fatal-infos` опционально: превращает info-уровень в ошибку сборки.

Убедитесь, что codegen актуален перед анализом, если меняли аннотации:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 10. Частые проблемы

### Плагин не загружается / нет подсказок riverpod_lint

1. `riverpod_lint` в `dev_dependencies` и `flutter pub get` выполнен.
2. В `analysis_options.yaml` секция `plugins` на верхнем уровне.
3. Версия в `plugins` совместима с версией в `pubspec.yaml`.
4. Перезапущен Dart Analysis Server.
5. Нет конфликтующего старого блока `analyzer: plugins: - custom_lint`.

### Много предупреждений в `*.g.dart` / `*.freezed.dart`

Добавьте `analyzer.exclude` (см. [раздел 5](#5-рекомендуемый-конфиг-для-flutter_echat)).

### `provider_dependencies` мешает на раннем этапе

Временно отключите в `diagnostics` или постепенно добавляйте `dependencies` / `@Dependencies` по мере введения scoped-провайдеров — не отключайте правило глобально без причины.

### Конфликт версий analyzer

`riverpod_lint` привязан к семейству пакета `analyzer`. При ошибках разрешения зависимостей зафиксируйте версии `riverpod_lint` и `flutter_lints` из [pub.dev](https://pub.dev/packages/riverpod_lint/install), затем `flutter pub upgrade`.

---

## 11. Чеклист

- [ ] `riverpod_lint` и `riverpod_generator` в `dev_dependencies`
- [ ] `plugins: riverpod_lint: <version>` в `analysis_options.yaml`
- [ ] **нет** `custom_lint` (если проект новый)
- [ ] `include: package:flutter_lints/flutter.yaml`
- [ ] `analyzer.exclude` для `*.g.dart` и `*.freezed.dart`
- [ ] `flutter pub get`
- [ ] Перезапуск analysis server
- [ ] `dart analyze` без неожиданных ошибок
- [ ] В `main.dart`: `runApp(ProviderScope(child: ...))`

---

## Ссылки

- [riverpod_lint на pub.dev](https://pub.dev/packages/riverpod_lint)
- [Analyzer plugins (Dart)](https://dart.dev/tools/analyzer-plugins)
- [Архитектура E-Chat — Riverpod 3](./architecture.md#4-riverpod-3)
