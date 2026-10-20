# Code review (заново): `TBottomNavBar`

Дата: 2026-10-20 (четвёртый проход)  
Файл: `lib/src/shared/widgets/t_bottom_nav_bar.dart`  
Связанные: `bottom_navigator_bar_theme.dart`, Widgetbook, §4.9  
Предыдущие: `…-rereview-2.md`, `…-rereview.md`, `…-expert.md`

---

## Вердикт

**Approve.** Виджет в хорошем состоянии: dumb-контракт, тема, Figma-layout, a11y-паттерн. Блокеров внутри файла нет. Единственный **major** — интеграция: `nav_shell.dart` пустой (вне скоупа виджета).

---

## Дельта с `…-rereview-2.md`

| Тема | Было | Сейчас |
| --- | --- | --- |
| `excludeSemantics` на `Semantics` | open | **fixed** (`excludeSemantics: true`) |
| Нет ripple (`overlayColor: transparent`) | open | **fixed** — `overlayColor` снят, снова Material splash |
| a11y `selected` + без дубля InkWell | fixed | без регрессий |
| Тень light = dark | open | open |
| `NavShell` | open | open |

---

## Что сделано хорошо

- Dumb API без Riverpod / `go_router`
- `TBottomNavigatorBarTheme.of` + registration в `TAppTheme.extensions`
- Кастомная плитка 76×70, SVG pairs, `gapH4`, `assert` на индекс
- a11y: `Semantics(button, selected, label, excludeSemantics: true)` + `InkWell(excludeFromSemantics: true)`
- Default InkWell ripple (есть `Material` ancestor)
- §4.9 и Widgetbook актуальны

---

## Findings

### [major] Бар не смонтирован в приложении
- Где: `lib/src/utils/router/nav_shell.dart` (пустой)
- Что: call-site только Widgetbook; chrome §4.9 не завершён
- Статус: open (вне файла)

### [minor] Тень бара одинакова в light/dark
- Где: `TBottomNavigatorBarTheme` — light/dark → `_barShadows`
- Что: `rgba(13,10,44,0.06)` на `neutral800` почти не видна
- Статус: open (дизайн-решение / сверка с Figma dark)

### [info] Destinations зашиты; нет анимации selected
- Статус: accepted

### [fixed] в этом / прошлых проходах
- ThemeExtension, Figma-layout, §4.9, `assert`, `gapH4`
- `Semantics(selected)` + `excludeSemantics` + `excludeFromSemantics`
- Ripple: убран принудительный transparent overlay

---

## Чеклист

- [x] Dumb API и слои
- [x] `ThemeExtension` + Figma-плитка
- [x] §4.9 актуален
- [x] a11y: selected + без дубля Text/InkWell
- [x] Material ripple (default)
- [ ] `NavShell` + `StatefulShellRoute`
- [ ] (опц.) отдельная тень для dark
