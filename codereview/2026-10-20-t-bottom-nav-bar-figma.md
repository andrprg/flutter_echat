# Сверка с Figma: `TBottomNavBar`

Дата: 2026-10-20  
Макет: [Navbar `58:2793`](https://www.figma.com/design/Do69JP5vfRzBNw3OO2jRHH/Chatting-App-UI-Kit-Design-_-E-Chat-_-Figma--Community-?node-id=58-2793)  
Код: `lib/src/shared/widgets/t_bottom_nav_bar.dart` + `bottom_navigator_bar_theme.dart`

---

## Вердикт

**Соответствует макету** после замены M3 `NavigationBar` на кастомный layout: плитка 76×70 с `gradientLightBlue`, outline/bold SVG, radius/тень бара.

---

## Findings (дизайн vs код)

### [blocker] Активная вкладка — градиент недоступен через тему
- Где: был `NavigationBar` + `indicatorColor`
- Макет: прямоугольник ~76×70 с `Gradient Light Blue`
- Статус: **fixed** — кастомный `DecoratedBox` + `TColors.gradientLightBlue` в `t_bottom_nav_bar.dart`

### [major] Контейнер бара (размер, радиус, тень)
- Макет: высота 100, `borderRadius: 12`, shadow `0px -4px 20px rgba(13, 10, 44, 0.06)`
- Статус: **fixed** — в виджете бара

### [major] Цвета inactive / dark background
- Статус: **fixed** — `neutral300` / `neutral800`

### [major] Outline ↔ Bold при selected
- Статус: **fixed** — пары `chat`/`chat_selected`, …; у selected `applyColorFilter: false`

### [minor] Типографика лейбла
- Статус: **fixed** — Medium 12, height 14/12

### [minor] Орфография «Ещё»
- Статус: **fixed**

---

## Чеклист до соответствия макету

- [x] Кастомный layout вместо M3 indicator (градиентная плитка 76×70)
- [x] Active: белый icon + label на `gradientLightBlue`
- [x] Inactive: `neutral300`; dark bar: `neutral800`
- [x] Тень и radius 12 как в Figma
- [x] Bold SVG для selected
- [x] Label 12 Medium; «Ещё» с ё
