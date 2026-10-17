# Widgetbook (E-Chat)

Песочница для dumb-виджетов без запуска основного приложения.

Полная инструкция (запуск, hot reload, codegen, новый use case):
**[docs/widgetbook.md](../docs/widgetbook.md)**

```bash
cd widgetbook
flutter pub get
dart run build_runner build
flutter run -d chrome
```

Правка виджета в `lib/src/...` → в терминале `r` / `R`.  
Правка `@UseCase` → снова `dart run build_runner build`.
