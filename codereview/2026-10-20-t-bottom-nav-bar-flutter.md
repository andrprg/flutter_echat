# Code review (Flutter): `TBottomNavBar`

Дата: 2026-10-20  
Контекст: экспертное ревью текущего `lib/src/shared/widgets/t_bottom_nav_bar.dart`  
Связанные логи: `2026-10-20-t-bottom-nav-bar.md`, `2026-10-20-t-bottom-navigator-bar.md`, `2026-10-20-t-bottom-nav-bar-figma.md`

---

## Вердикт

**Approve with suggestions.** Dumb-контракт и кастомный Figma-layout в порядке; прежние blocker’ы (go_router в shared, неверные иконки) закрыты. Перед merge chrome — a11y, расхождение с темой/§4.9 и пустой `NavShell`.

---

## Что сделано хорошо

- API dumb: `currentIndex` + `onDestinationSelected`, без Riverpod / `go_router` / Firebase
- Именование `TBottomNavBar` / `t_bottom_nav_bar.dart` по `file-naming`
- Кастомная плитка 76×70 + `TColors.gradientLightBlue` вместо M3 indicator
- Пары outline/bold SVG; у selected `applyColorFilter: false`
- `Material` + `InkWell` для hit-test; `SafeArea(top: false)`
- Приватные `_NavDestination` / `_TBottomNavItem`; dartdoc на русском
- Widgetbook: Interactive + по вкладкам

---

## Findings

### [major] Цвета бара мимо `Theme` / мёртвый `NavigationBarTheme`
- Где: `t_bottom_nav_bar.dart`; `bottom_navigator_bar_theme.dart`; `docs/architecture_echat.md` §4.9 (~733)
- Что: фон, inactive, градиент, лейбл — хардкод `TColors.*`; `ThemeData.navigationBarTheme` виджет не читает
- Почему: §4.9 обещает «цвета из Theme, смена light/dark без правок виджета»; сейчас тема — fallback для неиспользуемого M3 `NavigationBar`
- Статус: **fixed** — `TBottomNavigatorBarTheme` как `ThemeExtension`; токены в `TAppTheme.extensions`; бар читает через `TBottomNavigatorBarTheme.of(context)`; §4.9 обновлён

### [major] Нет семантики выбранной вкладки (a11y)
- Где: `_TBottomNavItem` / `InkWell`
- Что: нет `Semantics(button: true, selected: selected, label: …)` (или аналога M3 `NavigationBar`)
- Почему: TalkBack/VoiceOver не объявят «выбрано»; кастомный бар хуже штатного по доступности
- Статус: **fixed** — `Semantics(button: true, selected: …, label: …)` вокруг `InkWell`

### [major] Бар не смонтирован в приложении
- Где: `lib/src/utils/router/nav_shell.dart` (пустой); `app_router.dart` без shell-веток
- Что: call-site только Widgetbook
- Почему: chrome §4.9 не завершён — виджет не участвует в навигации
- Статус: open (интеграция, вне файла)

### [minor] Нет защиты от невалидного `currentIndex`
- Где: `TBottomNavBar.currentIndex`
- Что: при `index` вне `0..3` ни одна вкладка не selected, без assert/ошибки
- Статус: **fixed** — `assert` в `build`
- Направление: `assert(currentIndex >= 0 && currentIndex < _destinations.length)`

### [minor] Отключён Material ripple
- Где: `overlayColor: WidgetStateProperty.all(Colors.transparent)`
- Что: нет визуального feedback на тап (кроме смены selected)
- Почему: ок, если так в Figma; иначе — слабый UX на inactive
- Статус: open (уточнить по макету)

### [minor] Документация §4.9 устарела
- Где: `docs/architecture_echat.md` (~731–856)
- Что: всё ещё `BottomNavigationBar` / старый `navigationBarTheme`; код — кастом + `ThemeExtension`
- Статус: **fixed** — §4.9 обновлён под `TBottomNavigatorBarTheme` / кастомный `TBottomNavBar`

### [minor] Тень одинакова в light/dark
- Где: `_barShadow`
- Что: `rgba(13,10,44,0.06)` на `neutral800` почти незаметна
- Статус: open (дизайн-решение)

### [info] Destinations зашиты в виджет
- Что: лейблы/иконки не пропсы — нормально для shell chrome E-Chat; не универсальный navbar
- Статус: accepted

### [fixed] (из прошлых ревью)
- API без `StatefulNavigationShell` / `go_router`
- Иконки по вкладкам + `selectedIcon` (SVG)
- Имя `TBottomNavBar` / `t_bottom_nav_bar.dart`
- Визуал Figma (см. `…-figma.md`)

---

## Чеклист

- [x] Dumb API: `currentIndex` + `onDestinationSelected`
- [x] SVG pairs + градиентная плитка
- [x] Semantics / a11y selected
- [x] Тема: `ThemeExtension` + чтение в виджете
- [x] `assert` на `currentIndex`
- [ ] `NavShell` + `StatefulShellRoute` (отдельная задача)
- [x] Обновить §4.9 под кастомный бар / `ThemeExtension`
