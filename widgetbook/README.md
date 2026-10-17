# Widgetbook (E-Chat)

Песочница для dumb-виджетов (`TButton`, `TAvatar`, …) без запуска основного приложения.

## Запуск

```bash
cd widgetbook
dart run build_runner build
flutter run -d chrome
```

В `dev_dependencies` нужен `vector_graphics_compiler`: при сборке Flutter трансформирует SVG из path-зависимости `flutter_echat`.

После добавления или изменения `@UseCase` снова запустите codegen (или `watch`):

```bash
dart run build_runner watch -d
```

## Добавить виджет

1. Создайте файл в `lib/components/` с функциями `@UseCase`.
2. Импортируйте только dumb-виджеты из `package:flutter_echat/...`.
3. Выполните `build_runner` — use case появится в дереве слева.
