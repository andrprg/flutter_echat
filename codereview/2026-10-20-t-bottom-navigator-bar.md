# Code review: `TBottomNavBar` (повторно)

Дата: 2026-10-20 (повторное ревью)  
Контекст: `t_bottom_nav_bar.dart`, `bottom_navigator_bar_theme.dart`, `theme.dart`, §4.9, `nav_shell.dart`, `app_router.dart`.

---

## Вердикт

**Request changes.** Тема согласована с M3 `NavigationBar` — ок. Главный blocker: dumb-бар всё ещё зависит от `StatefulNavigationShell` / `go_router`. Chrome (`NavShell`, `StatefulShellRoute`) не реализован — бар не монтируется.

---

## Что сделано хорошо

- `TBottomNavigatorBarTheme` → `NavigationBarThemeData`; `TAppTheme` → `navigationBarTheme` — **исправлено** (прежний blocker).
- Виджет — M3 `NavigationBar`, согласован с темой.
- `StatelessWidget`, без Riverpod; 4 пункта в порядке Chats | Groups | Profile | More.
- Подписи на русском; `const` у `destinations`.

---

## Findings

### [blocker] `StatefulNavigationShell` в shared dumb — нарушение слоёв
- Где: `t_bottom_nav_bar.dart:2,10,16` — `import go_router`, `final StatefulNavigationShell navigationShell`, `selectedIndex: navigationShell.currentIndex`
- Что: dumb знает тип shell; callback `onDestinationSelected` уже вынесен, но API всё ещё тянет `go_router`.
- Почему: §4.9 / `layer-presentation` / `go-router`: только `currentIndex` + `onDestinationSelected`; `goBranch` — в smart `NavShell`.
- Статус: open
- Направление:
  ```dart
  TBottomNavBar({
    required this.currentIndex,
    required this.onDestinationSelected,
  })
  ```

### [major] Иконки не соответствуют вкладкам
- Где: `t_bottom_nav_bar.dart:19-22`
- Что: «Чаты» → `Icons.home`; «Группы» → `Icons.settings`; «Еще» → `Icons.more_vert`.
- Статус: open
- Направление: `chat_bubble_outline` / `groups` / `person` / `more_horiz` (+ `selectedIcon` по макету).

### [major] Имя файла/класса расходится с §4.9
- Где: было `TBottomNavigatorBar` / `t_bottom_navigator_bar.dart`
- Что: архитектура — `TBottomNavBar` / `t_bottom_nav_bar.dart`.
- Статус: fixed
- Исправление: переименовано в `TBottomNavBar` / `t_bottom_nav_bar.dart`.

### [major] `nav_shell.dart` пуст
- Где: `lib/src/utils/router/nav_shell.dart`
- Что: нет `Scaffold(bottomNavigationBar: …)`, `goBranch(..., initialLocation: i == index)`, bar vs rail по breakpoint.
- Статус: open

### [major] `app_router.dart` без shell-веток
- Где: `lib/src/utils/router/app_router.dart`
- Что: нет `StatefulShellRoute.indexedStack` + 4 веток; `NavShell` не подключён; `EChatApp` ещё на `MaterialApp(home: …)`.
- Статус: open

### [minor] Документация §4.9 устарела по теме
- Где: `docs/architecture_echat.md` (~685–731, 889)
- Что: всё ещё `BottomNavigationBarThemeData` / `bottomNavigationBarTheme`; код уже на `NavigationBarThemeData` / `navigationBarTheme`.
- Статус: open

### [minor] Нет `selectedIcon`
- Где: destinations только с `icon:`
- Статус: open

### [minor] Нет dartdoc контракта хоста
- Где: class `TBottomNavBar`
- Статус: open

### [minor] Тема без `surfaceTintColor`
- Где: `bottom_navigator_bar_theme.dart`
- Что: у M3 `NavigationBar` возможен tint поверх белого фона; задать `surfaceTintColor: Colors.transparent` при необходимости.
- Статус: open

### [info] Виджет нигде не импортируется
- Где: grep — нет call-site `TBottomNavBar`
- Статус: open (следствие пустого `NavShell`)

### [fixed] Тема vs виджет
- Было: `BottomNavigationBarThemeData` + `bottomNavigationBarTheme` при `NavigationBar`.
- Стало: `NavigationBarThemeData` + `ThemeData.navigationBarTheme`.
- Статус: fixed

---

## Чеклист перед merge

- [ ] Dumb API: `currentIndex` + `onDestinationSelected`, без `go_router`
- [x] Тема: `NavigationBarThemeData` + `navigationBarTheme`
- [ ] Иконки по макету (+ опц. `selectedIcon`)
- [x] Имя: `TBottomNavBar` / `t_bottom_nav_bar.dart`
- [ ] `NavShell` + `goBranch(..., initialLocation: …)`
- [ ] `StatefulShellRoute` + 4 ветки; `MaterialApp.router`
- [ ] Обновить §4.9 под `NavigationBar` / `navigationBarTheme`
- [ ] (опц.) `surfaceTintColor`, dartdoc, Widgetbook
