# Code review (Flutter-эксперт): `TBottomNavBar`

Дата: 2026-10-20  
Файл: `lib/src/shared/widgets/t_bottom_nav_bar.dart`  
Связанные: `bottom_navigator_bar_theme.dart`, Widgetbook, §4.9  
Предыдущие логи: `…-flutter.md`, `…-figma.md`, `…-navigator-bar.md`

---

## Вердикт

**Approve with suggestions.** Dumb-контракт, тема через `ThemeExtension` и Figma-layout в порядке. Блокеров в самом виджете нет; перед продакшен-chrome — интеграция в `NavShell`, правка §4.9 и мелкие a11y/UX замечания ниже.

---

## Что сделано хорошо

- Слои: dumb shared-виджет — только props (`currentIndex`, `onDestinationSelected`), без Riverpod / `go_router` / Firebase
- Именование: `TBottomNavBar` / `t_bottom_nav_bar.dart`, префикс `T`
- Токены через `TBottomNavigatorBarTheme.of` (`ThemeData.extensions`), не хардкод `TColors` в build
- Кастомная плитка 76×70 + градиент вместо M3 `NavigationBar` indicator
- Пары outline / `*_selected` SVG; у active `applyColorFilter: false`
- `assert` на диапазон `currentIndex`; `Semantics(selected: …)`; `SafeArea(top: false)`
- Приватные `_NavDestination` / `_TBottomNavItem`; dartdoc на русском
- Widgetbook: Interactive + 4 вкладки

---

## Findings

### [major] Бар не смонтирован в приложении
- Где: `lib/src/utils/router/nav_shell.dart` (пустой); `app_router.dart` без shell-веток
- Что: call-site только Widgetbook — chrome §4.9 не завершён
- Почему: виджет не участвует в навигации; нельзя проверить `goBranch` / phone vs rail
- Статус: open (вне файла виджета)

### [minor] Дублирование семантики у пункта
- Где: `_TBottomNavItem` — `Semantics` вокруг `InkWell`
- Что: `InkWell` сам создаёт button-семантику; родительский `Semantics(button: true)` даёт вложенный узел
- Почему: TalkBack/VoiceOver могут дважды объявлять кнопку или путать focus
- Направление: `InkWell(excludeFromSemantics: true, …)` либо оставить семантику только у одного из двух
- Статус: open

### [minor] Нет визуального feedback на тап
- Где: `overlayColor: WidgetStateProperty.all(Colors.transparent)`
- Что: ripple/highlight отключены; смена вкладки — единственный отклик
- Почему: ок, если так в Figma; иначе слабый UX на inactive
- Статус: open (уточнить по макету)

### [minor] Gap иконка→лейбл вне темы
- Где: `_TBottomNavItem` — `SizedBox(height: 4)`
- Что: единственный визуальный отступ, не в `TBottomNavigatorBarTheme`
- Почему: light/dark и будущие правки Figma потребуют правки виджета
- Направление: `iconLabelGap` (или аналог) в `ThemeExtension`
- Статус: open

### [minor] Документация §4.9 устарела
- Где: `docs/architecture_echat.md` (~731–856)
- Что: всё ещё `bottomNavigationBarTheme` / Material `BottomNavigationBar`; код — кастом + `TBottomNavigatorBarTheme` extension
- Статус: **fixed** — §4.9 и каталог `shared-widgets` обновлены под `ThemeExtension` / кастомный бар

### [minor] Тень бара одинакова в light/dark
- Где: `TBottomNavigatorBarTheme._barShadows`
- Что: `rgba(13,10,44,0.06)` на `neutral800` почти не видна
- Статус: open (дизайн-решение)

### [info] Нет анимации смены selected
- Где: ветка `selected ? DecoratedBox : SizedBox`
- Что: мгновенное появление/исчезновение градиентной плитки
- Почему: не блокер; при желании — `AnimatedContainer` / implicit animation
- Статус: accepted / nice-to-have

### [info] Destinations зашиты в виджет
- Что: лейблы/иконки не пропсы — нормально для shell chrome E-Chat
- Статус: accepted

### [fixed] (из прошлых ревью этого же файла)
- API без `StatefulNavigationShell` / `go_router` в shared
- Иконки по вкладкам + selected SVG
- `ThemeExtension` вместо хардкода цветов / мёртвого M3 `NavigationBarTheme`
- `Semantics(selected: …)`
- `assert` на `currentIndex`
- Визуал Figma (см. `…-figma.md`)

---

## Чеклист

- [x] Dumb API и слои presentation
- [x] Тема: `ThemeExtension` + чтение в виджете
- [x] Figma: плитка, градиент, SVG pairs, radius/тень
- [x] `assert` + базовый Semantics
- [ ] `excludeFromSemantics` у `InkWell` (или эквивалент)
- [ ] `NavShell` + `StatefulShellRoute`
- [x] Обновить §4.9 под кастомный бар / extension
- [ ] (опц.) gap в теме; tap feedback; dark shadow
