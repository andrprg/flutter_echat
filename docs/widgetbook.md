# Widgetbook — песочница dumb-виджетов

Отдельное Flutter-приложение в каталоге [`widgetbook/`](../widgetbook/) для просмотра и отладки shared-виджетов (`TButtonWidget`, `TAvatarWidget`, …) без запуска основного E-Chat.

Связано: [shared-widgets.md](./shared-widgets.md), [architecture_echat.md](./architecture_echat.md) (§3 smart/dumb).

---

## Структура

```
widgetbook/
├── pubspec.yaml          # path-зависимость на flutter_echat
├── lib/
│   ├── main.dart         # @App, темы TAppTheme, addons
│   ├── main.directories.g.dart  # codegen — не править вручную
│   └── components/       # @UseCase для виджетов
└── README.md             # краткая шпаргалка → этот документ
```

В песочницу кладём **только dumb**-виджеты (props + callbacks). Smart с Riverpod — только с заглушками `ProviderScope`, по возможности избегаем.

---

## Запуск

Первый раз (или после клонирования):

```bash
cd widgetbook
flutter pub get
dart run build_runner build
flutter run -d chrome
```

Другие устройства: `-d windows`, `-d <id эмулятора>` (`flutter devices`).

В `dev_dependencies` пакета нужен `vector_graphics_compiler`: при сборке Flutter трансформирует SVG из path-зависимости `flutter_echat`. Без него будет `Could not find package vector_graphics_compiler`.

---

## Обновление после правок виджета

Изменили код в `lib/src/shared/widgets/` (например `t_button_widget.dart`):

| Ситуация | Действие |
| --- | --- |
| Widgetbook уже запущен | В терминале `flutter run`: **`r`** (hot reload) или **`R`** (hot restart) |
| Hot reload не подхватил | **`R`**, либо остановить и снова `flutter run -d chrome` |
| Меняли только реализацию виджета | **`build_runner` не нужен** |

Path-зависимость `flutter_echat: path: ../` подтягивает исходники приложения автоматически.

---

## Обновление после правок use case

Изменили или добавили файл в `widgetbook/lib/components/` (`@UseCase`):

```bash
cd widgetbook
dart run build_runner build
```

Для постоянной пересборки:

```bash
dart run build_runner watch
```

Затем hot restart (`R`) или перезапуск `flutter run`.

---

## Добавить новый виджет

1. Создайте `widgetbook/lib/components/<имя>.dart`.
2. Импортируйте dumb-виджет из `package:flutter_echat/src/shared/widgets/...`.
3. Опишите функции с `@UseCase(name: '...', type: TMyWidget)`.
4. Выполните `dart run build_runner build` — use case появится в дереве слева.

Пример knobs:

```dart
@widgetbook.UseCase(name: 'Interactive', type: TButtonWidget)
Widget buildTButtonInteractive(BuildContext context) {
  return TButtonWidget(
    label: context.knobs.string(label: 'label', initialValue: 'Войти'),
    isLoading: context.knobs.boolean(label: 'isLoading'),
    onTap: () {},
  );
}
```

Темы Light/Dark и viewport’ы настраиваются в `widgetbook/lib/main.dart` (`MaterialThemeAddon`, `ViewportAddon`).

---

## Когда что запускать (кратко)

| Что изменили | Команда / клавиша |
| --- | --- |
| Виджет в `lib/src/...` | `r` / `R` в сессии Widgetbook |
| `@UseCase` / новый файл в `components/` | `dart run build_runner build` → `R` |
| Зависимости `widgetbook/pubspec.yaml` | `flutter pub get` → `flutter run` |
| Первый запуск | `pub get` → `build_runner build` → `flutter run` |
