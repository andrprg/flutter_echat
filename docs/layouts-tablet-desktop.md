# Макеты tablet / desktop — E-Chat

Спецификация раскладок для планшета и десктопа поверх мобильного UI-кита
[Chatting App UI Kit | E-Chat (Figma)](https://www.figma.com/design/Do69JP5vfRzBNw3OO2jRHH/Chatting-App-UI-Kit-Design-_-E-Chat-_-Figma--Community-?node-id=21-122).

**Интерактивные макеты:** [mockups/echat-tablet-desktop.html](./mockups/echat-tablet-desktop.html)  
**Токены:** [echat_colors.dart](./echat_colors.dart), `lib/src/utils/constants/colors.dart`  
**Adaptive:** [architecture_echat.md §4](./architecture_echat.md#4-адаптивный-ui-phone--tablet--desktop)

---

## 1. Цель

Мобильный кит (393×852) покрывает phone. Этот документ фиксирует **расширение** тех же экранов, компонентов, цветов, шрифта Roboto и иконок на:

| Форм-фактор | Ширина (dp) | Ориентир фрейма |
| --- | ---: | --- |
| Tablet | 600 … 1023 | **768×1024** (portrait), **1024×768** (landscape → desktop) |
| Desktop | ≥ 1024 | **1440×900** |

Light и Dark — те же `ColorScheme` / семантические алиасы, что в Figma и `TColors`. Новые hex не вводить.

---

## 2. Design tokens (без изменений палитры)

### 2.1. Цвета

| Роль | Light | Dark |
| --- | --- | --- |
| Scaffold / surface | `#FFFFFF` | `#0D1217` (`neutral900Dark`) |
| On surface | `#2C2D3A` (`neutral900`) | `#FFFFFF` |
| On surface variant | `#8688A1` (`neutral400`) | `#9A9BB1` (`neutral300`) |
| Primary | `#1565C0` (`blue500`) | `#40C4FF` (`lightBlue500`) |
| Secondary / CTA / исходящий bubble | `#40C4FF` | `#40C4FF` / `#66D0FF` |
| Incoming bubble | `#F0F0F3` (`neutral50`) | `#393A4C` (`neutral800`) |
| Outline / divider | `#D0D1DB` / `#E7E7E7` | `#4A4B62` / `#393A4C` |
| Unread badge | `#1565C0` | `#40C4FF` |
| Online | `#13C296` | `#13C296` |
| Error | `#F44336` | `#F6695E` |

Градиенты (logo, primary CTA): `gradientBlue`, `gradientLightBlue` — как в Figma.

### 2.2. Типографика

Семейство: **Roboto** (как в мобильном ките).

| Стиль | Size / Weight | Где |
| --- | --- | --- |
| Headline L | 32 / Bold | Onboarding, пустые состояния |
| Headline M | 24 / SemiBold | Заголовки секций auth |
| Title L | 18 / SemiBold | Заголовок экрана, имя в chat app bar |
| Body L | 16 / Regular | Сообщения, пункты списка |
| Body M | 14 / Regular | Превью, вторичный текст, время |
| Label L | 16 / SemiBold | Текст primary-кнопок |

На tablet/desktop **не увеличивать** базовые кегли: плотность чуть выше за счёт меньших вертикальных padding у tiles (см. §4).

### 2.3. Иконки

Те же glyph из Figma Community (Material-подобные outlines): Chats, Groups, Profile, More, Search, Call, Video, Attach, Send, Back, Add, Settings.  
Размер в chrome: **24×24**; в `Button Md` / app bar — как на phone. Цвет: `onSurface` / `onSurfaceVariant` / `primary` для selected.

---

## 3. Chrome навигации

| | Phone (`<600`) | Tablet (`600–1023`) | Desktop (`≥1024`) |
| --- | --- | --- | --- |
| Оболочка | `TBottomNavBar` снизу | `TNavigationRail` слева, **сжатый** | `TNavigationRail` / sidebar, **расширенный** |
| Вкладки | Chats · Groups · Profile · More | те же 4 | те же 4 |
| Ширина chrome | full width bar | **72** dp (icon-only) | **240** dp (icon + label), collapsed → 72 |
| Logo | в списках / splash | над rail (компакт) | в шапке sidebar |

Правило: один `StatefulShellRoute`; chrome выбирает smart `nav_shell` по `appBreakpointProvider`. Dumb: `TBottomNavBar` / `TNavigationRail`.

### 3.1. Как `ChatsShellScreen` выбирает layout

Вкладка Chats: один smart-файл `features/chats/presentation/shell/chats_shell_screen.dart` (целевая структура). Он **не** ветвится на три копии фичи; выбирает композицию так:

1. `ref.watch(appBreakpointProvider)` → `phone` / `tablet` / `desktop` (пороги: &lt;600 / 600–1023 / ≥1024).
2. `pathParameters['id']` из go_router → есть ли выбранный чат.
3. `switch (breakpoint)`:
   - **phone** — один child: список (`/chats`) или переписка (`/chats/:id`);
   - **tablet / desktop** — `TwoPane(master: list, detail: thread | empty)`; список не уезжает при открытии чата.
4. Controllers и dumb-views (`ChatListView`, `ChatThreadView`) **общие** на все ширины; breakpoints только в shell.

Полный пример кода и таблица маршрутов — [architecture_echat.md §4.3](./architecture_echat.md#43-masterdetail-chats--groups) (подраздел «Как `ChatsShellScreen` выбирает phone / tablet / desktop»). Схема потока — [§4.6](./architecture_echat.md#46-практический-разбор-как-выбирается-верстка-на-примере-featurechats).

---

## 4. Ширины колонок (master–detail)

### 4.1. Tablet — `TwoPane`

```
┌──────┬────────────────┬─────────────────────────────┐
│ Rail │ Chat list      │ Thread                      │
│ 72   │ 280–320        │ flex (min ~360)             │
└──────┴────────────────┴─────────────────────────────┘
```

| Колонка | Ширина | Содержимое |
| --- | ---: | --- |
| Rail | 72 | 4 destinations |
| Master (list) | **300** (clamp 280–340) | поиск + `TConversationTile` |
| Detail (thread) | remaining | `TChatAppBar` + bubbles + `TMessageInput` |
| Info pane | — | **нет** (User Information — push / modal поверх) |

Empty detail (`/chats` без `:id`): иллюстрация + «Select a chat» по центру панели.

### 4.2. Desktop — `ThreePane` (опционально)

```
┌──────────┬────────────┬──────────────────┬────────────┐
│ Sidebar  │ Chat list  │ Thread           │ Chat info  │
│ 240      │ 320        │ flex             │ 320        │
└──────────┴────────────┴──────────────────┴────────────┘
```

| Колонка | Ширина | Содержимое |
| --- | ---: | --- |
| Sidebar | **240** (или 72 collapsed) | logo + labels destinations |
| Master | **320** (clamp 300–360) | список / поиск / FAB «+» |
| Detail | flex (min 420) | переписка |
| Info | **320** (0, если закрыта) | User / Group Information, Media tabs |

По умолчанию info **скрыта**; открывается из app bar thread (иконка info) → `ThreePane`, без ухода со списка.

### 4.3. Density

| Элемент | Phone | Tablet / Desktop |
| --- | ---: | ---: |
| Высота `TConversationTile` | ~72 | **64** |
| Горизонтальный padding списка | 16 | **16** (master), thread **24** |
| `TMessageInput` max width | full | full в колонке |
| Auth / Profile content | full | `MaxWidthBox` **480–560** по центру |
| Desktop max single-column | — | `TSizes.maxContentWidth` **720** |

---

## 5. Экраны по фичам

Компоненты — из [shared-widgets.md](./shared-widgets.md); меняется только композиция.

### 5.1. Chats / Groups (master–detail)

| Состояние | Tablet | Desktop |
| --- | --- | --- |
| Список без выбора | Rail + list + empty placeholder | Sidebar + list + empty (+ info off) |
| Выбран чат | Rail + list + thread | Sidebar + list + thread |
| Info / media | Modal или full overlay → **User Info** | Правая колонка `ThreePane` / панель max **480** |
| Search | В master (как phone Card Input) | То же |
| Add Friend / Create Group | Dialog / centered sheet max 480 | То же |
| Call / Video | Full-frame overlay (как phone) | Центрированная панель max **420×780** поверх dim shell; PiP — later |

Маршруты общие: `/chats`, `/chats/:id` (аналогично `/groups`).

### 5.2. Profile / More

Одна колонка: rail/sidebar + `MaxWidthBox` с контентом phone-экрана (карточки настроек, `TSettingsTile`, `TToggle`).  
Не растягивать tiles на всю ширину desktop.

### 5.3. Auth / Onboarding

| | Tablet | Desktop |
| --- | --- | --- |
| Layout | Центрированная карточка max **480** на фоне surface | Split опционально: слева brand/gradient + logo (≤40%), справа форма max **440** |
| Клавиатуры из Figma | Не показывать системные mock-keyboards | То же — нативный input |
| Verification / PIN | Те же `TCodeInput` / `TPinDots` | То же в карточке |

### 5.4. Модалки и sheets

Phone bottom sheet → на wide: **centered dialog** (radius 16, shadow2), max width 480, те же внутренние компоненты (`TAddMenuPopup`, overlays).

### 5.5. Звонки (по Figma: Call / Calling / Video Calling)

| Экран Figma | Содержимое | Tablet | Desktop |
| --- | --- | --- | --- |
| **Chats _ Call** | Тёмный фон, аватар, имя, номер, Decline (red) + Accept (green) | Full overlay | Modal overlay |
| **Chats _ Calling** | Blur-фон аватара, таймер `03:45`, Mute · Speaker · End | Full overlay | Modal overlay |
| **Chats _ Video Calling** | Camera fullscreen, Flash · Shutter (ring `#40C4FF`) · Flip | Full overlay | Modal overlay |

Цвета кнопок звонка: Accept `#00C853` (`success500`), Decline/End `#F44336` (`error500`), shutter ring `#40C4FF`.  
В HTML: кнопки **Call** / **Calling** / **Video Calling** в [mockups/echat-tablet-desktop.html](./mockups/echat-tablet-desktop.html).

---

## 6. Light / Dark — чеклист макетов

Для каждого ключевого фрейма нужны **две** темы:

1. Chats — empty detail  
2. Chats — conversation + typing / bubbles  
3. Chats — info pane open (**только desktop**)  
4. Groups — conversation  
5. Profile  
6. Auth — Login (centered / split)  
7. Add Friend dialog  
8. **Chats _ Call** (входящий)  
9. **Chats _ Calling** (активный + таймер)  
10. **Chats _ Video Calling** (Camera)  

Итого ориентир: **tablet 2 темы × ~9 экранов** + **desktop 2 темы × ~10 экранов**.  
Визуальный просмотр — HTML в `docs/mockups/`.

---

## 7. Соответствие коду

| Макет | Реализация |
| --- | --- |
| Breakpoints | `TBreakpoints` / `appBreakpointProvider` |
| Two / Three pane | `shared/layouts/two_pane.dart`, `three_pane.dart` |
| Shell chrome | `utils/router/nav_shell.dart` + `TNavigationRail` |
| Chats wide | `ChatsShellScreen` (§4.3 architecture) |
| Ширины колонок | `TSizes.railWidth`, `sidebarWidth`, `masterPaneWidth`, `infoPaneWidth` |

Не создавать папки `tablet/` / `desktop/` с копиями фич или подпапки `layouts/` для каждого экрана — используйте параметризацию dumb-компонентов и глобальные композиции (например, `TwoPane`).
