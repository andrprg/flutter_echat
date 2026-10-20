# Code review: `TBottomNavBar`

Дата: 2026-10-20  
Контекст: ревью файла `lib/src/shared/widgets/t_bottom_nav_bar.dart` (фокус на dumb-виджете; интеграция — для полноты).  
Связанный лог: `codereview/2026-10-20-t-bottom-navigator-bar.md`.

---

## Вердикт

**Request changes.** Виджет формально M3/`StatelessWidget`/без Riverpod, но API всё ещё тянет `go_router` (`StatefulNavigationShell`) — это blocker для dumb/`shared`. Плюс иконки не соответствуют вкладкам.

---

## Что сделано хорошо

- Класс/файл: `TBottomNavBar` / `t_bottom_nav_bar.dart` — по `file-naming` и §4.9.
- Material 3 `NavigationBar` — согласован с `ThemeData.navigationBarTheme`.
- Без Riverpod / Firebase; навигация наружу через callback.
- 4 пункта в нужном порядке (Чаты · Группы · Профиль · Еще); `const` у `destinations`.
- Подписи на русском.

---

## Findings (по файлу)

### [blocker] Зависимость dumb от `StatefulNavigationShell` / `go_router`
- Где: `t_bottom_nav_bar.dart:2,10–11,16`
- Что: `import go_router`, поле `navigationShell`, `selectedIndex: navigationShell.currentIndex`.
- Почему: `layer-presentation` / §4.9: shared dumb принимает только `currentIndex` + `onDestinationSelected`; тип shell и `goBranch` — в smart `NavShell`.
- Статус: open
- Направление:
  ```dart
  const TBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  ```

### [major] Иконки не соответствуют вкладкам
- Где: `t_bottom_nav_bar.dart:19–22`
- Что: «Чаты» → `Icons.home`; «Группы» → `Icons.settings`; «Еще» → `Icons.more_vert` (обычно overflow/меню).
- Почему: UX-ошибка; расхождение с макетом/семантикой вкладок.
- Статус: open
- Направление: например `chat_bubble_outline` / `groups` / `person` / `more_horiz` (+ `selectedIcon` по Figma).

### [minor] Нет `selectedIcon`
- Где: destinations только с `icon:`
- Что: нет filled/outlined пары для selected state.
- Статус: open

### [minor] Нет dartdoc контракта хоста
- Где: class `TBottomNavBar`
- Что: не зафиксировано, что хост обязан держать порядок индексов = веткам shell (0…3).
- Статус: open

---

## Findings (интеграция, вне файла — блокеры для merge chrome)

### [major] `nav_shell.dart` пуст — бар не монтируется
- Где: `lib/src/utils/router/nav_shell.dart`
- Статус: open

### [major] `app_router.dart` без `StatefulShellRoute` + 4 веток
- Где: `lib/src/utils/router/app_router.dart`
- Статус: open

### [info] Нет call-site `TBottomNavBar`
- Статус: open (следствие пустого shell)

### [minor] §4.9 в docs всё ещё местами про `BottomNavigationBarThemeData`
- Где: `docs/architecture_echat.md`
- Статус: open

---

## Чеклист перед merge виджета

- [ ] API: `currentIndex` + `onDestinationSelected`, без `go_router`
- [ ] Иконки по смыслу вкладок (+ опц. `selectedIcon`)
- [ ] (опц.) dartdoc: порядок индексов = ветки shell
- [ ] Подключение из smart `NavShell` (отдельная задача)
