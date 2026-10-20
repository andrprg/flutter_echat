# Code review (заново): `TBottomNavBar`

Дата: 2026-10-20 (третий проход)  
Файл: `lib/src/shared/widgets/t_bottom_nav_bar.dart`  
Связанные: `bottom_navigator_bar_theme.dart`, Widgetbook, §4.9  
Предыдущие: `…-rereview.md`, `…-expert.md`, `…-figma.md`

---

## Вердикт

**Approve with suggestions.** Сам виджет готов к merge по архитектуре, теме, Figma и базовой a11y. Единственный **major** вне файла — пустой `NavShell`. Внутри бара остались только minor / info.

---

## Дельта с `…-rereview.md`

| Тема | Прошлый проход | Сейчас |
| --- | --- | --- |
| a11y `selected` | регрессия (нет Semantics) | **fixed** — `Semantics(button, selected, label)` |
| Дубль button InkWell | — | **fixed** — `excludeFromSemantics: true` |
| §4.9 | fixed | без изменений (актуален) |
| `NavShell` | open | open |

---

## Что сделано хорошо

- Dumb API: `currentIndex` + `onDestinationSelected`
- `TBottomNavigatorBarTheme.of` / `ThemeData.extensions`
- Кастомная плитка 76×70 + градиент; SVG pairs; `gapH4`
- `assert` на индекс; `SafeArea(top: false)`
- a11y: один узел с `selected` + `InkWell(excludeFromSemantics: true)`
- Widgetbook; §4.9 согласован с кодом

---

## Findings

### [major] Бар не смонтирован в приложении
- Где: `lib/src/utils/router/nav_shell.dart` (пустой)
- Что: call-site только Widgetbook; chrome §4.9 не завершён
- Статус: open (вне файла)

### [minor] Дочерняя семантика Text/Icon может дублировать label
- Где: `_TBottomNavItem` — `Semantics` без `excludeSemantics: true`
- Что: `InkWell(excludeFromSemantics: true)` убирает узел InkWell, но `Text` / `TIconWidget` всё ещё могут попасть в дерево под родителем → повтор «Чаты»
- Направление: `Semantics(..., excludeSemantics: true, child: InkWell(...))`
- Статус: open

### [minor] Нет визуального feedback на тап
- Где: `overlayColor: …Colors.transparent`
- Статус: open (уточнить по Figma)

### [minor] Тень бара одинакова в light/dark
- Где: `TBottomNavigatorBarTheme._barShadows`
- Статус: open (дизайн)

### [info] Destinations зашиты; нет анимации selected
- Статус: accepted

### [fixed]
- API без `go_router` в shared
- `ThemeExtension`, Figma-layout, `assert`, `gapH4`, §4.9
- `Semantics(selected: …)` + `excludeFromSemantics` у `InkWell` (регрессия a11y закрыта)

---

## Чеклист

- [x] Dumb API и слои
- [x] `ThemeExtension` + Figma-плитка
- [x] §4.9 актуален
- [x] `Semantics(selected: …)` + без дубля button у InkWell
- [ ] (желательно) `excludeSemantics: true` на внешнем `Semantics`
- [ ] `NavShell` + `StatefulShellRoute`
- [ ] (опц.) tap feedback; dark shadow
