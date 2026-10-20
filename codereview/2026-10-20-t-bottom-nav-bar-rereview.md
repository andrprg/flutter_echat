# Code review (повторно): `TBottomNavBar`

Дата: 2026-10-20 (повторный проход)  
Файл: `lib/src/shared/widgets/t_bottom_nav_bar.dart`  
Связанные: `bottom_navigator_bar_theme.dart`, Widgetbook, §4.9  
Предыдущие: `…-expert.md`, `…-flutter.md`, `…-figma.md`

---

## Вердикт

**Approve with suggestions** (виджет); перед chrome — **major** a11y-регрессия и пустой `NavShell`.

Архитектура dumb, `ThemeExtension` и Figma-layout в порядке. §4.9 актуален. По сравнению с прошлым ревью: gap через `gapH4`; обёртка `Semantics` **удалена** — снова нет `selected` для screen reader.

---

## Дельта с прошлого ревью

| Тема | Было | Сейчас |
| --- | --- | --- |
| §4.9 / docs | устарели | **fixed** |
| Gap иконка→лейбл | `SizedBox(height: 4)` | `gapH4` из `sizes.dart` |
| Semantics + InkWell | дубль button | `Semantics` снят целиком |
| a11y `selected` | было | **регрессия** — нет |
| `NavShell` | пустой | без изменений |

---

## Что сделано хорошо

- Dumb API: `currentIndex` + `onDestinationSelected`, без Riverpod / `go_router`
- Токены: `TBottomNavigatorBarTheme.of`; light/dark в `TAppTheme.extensions`
- Кастомная плитка 76×70 + градиент; SVG pairs; `applyColorFilter: !selected`
- `assert` на диапазон индекса; `SafeArea(top: false)`; `gapH4`
- Widgetbook Interactive + 4 вкладки; §4.9 описывает кастом + extension

---

## Findings

### [major] Нет семантики выбранной вкладки (регрессия)
- Где: `_TBottomNavItem` — только `InkWell` (без `Semantics`)
- Что: TalkBack/VoiceOver не получат `selected`; кастомный бар хуже M3 `NavigationBar`
- Почему: раньше был `Semantics(button:, selected:, label:)`; снятие без замены откатывает a11y
- Направление:
  ```dart
  Semantics(
    button: true,
    selected: selected,
    label: destination.label,
    child: InkWell(
      excludeFromSemantics: true,
      ...
    ),
  )
  ```
- Статус: open (регрессия)

### [major] Бар не смонтирован в приложении
- Где: `nav_shell.dart` (пустой); shell-ветки в router не собраны
- Что: call-site только Widgetbook
- Статус: open (вне файла)

### [minor] Нет визуального feedback на тап
- Где: `overlayColor: …Colors.transparent`
- Что: ripple отключён; отклик — только смена selected
- Статус: open (уточнить по Figma)

### [minor] Тень бара одинакова в light/dark
- Где: `TBottomNavigatorBarTheme._barShadows`
- Что: на `neutral800` почти не видна
- Статус: open (дизайн)

### [info] Destinations зашиты в виджет
- Статус: accepted (shell chrome E-Chat)

### [info] Нет анимации смены selected
- Статус: accepted / nice-to-have

### [fixed] с прошлых проходов
- API без `go_router` в shared
- `ThemeExtension` вместо хардкода / M3 theme
- `assert` на `currentIndex`
- Визуал Figma
- Документация §4.9
- Gap через `gapH4` (вместо «голого» `SizedBox`)

---

## Чеклист

- [x] Dumb API и слои
- [x] `ThemeExtension` + чтение в виджете
- [x] Figma-layout (плитка, градиент, SVG)
- [x] §4.9 актуален
- [x] `assert` на индекс
- [ ] Вернуть `Semantics(selected: …)` + `excludeFromSemantics` у `InkWell`
- [ ] `NavShell` + `StatefulShellRoute`
- [ ] (опц.) tap feedback; dark shadow
