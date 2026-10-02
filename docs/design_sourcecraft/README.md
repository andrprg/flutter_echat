# E-Chat · Макеты Tablet & Desktop — `design_sourcecraft`

Интерактивные HTML-макеты desktop (1440×900) и tablet (768×1024) поверх мобильного UI-кита
[Chatting App UI Kit | E-Chat (Figma)](https://www.figma.com/design/Do69JP5vfRzBNw3OO2jRHH/Chatting-App-UI-Kit-Design-_-E-Chat-_-Figma--Community-?node-id=21-122).

Спецификация раскладок: [`../layouts-tablet-desktop.md`](../layouts-tablet-desktop.md) · токены: [`../echat_colors.dart`](../echat_colors.dart)

---

## Файлы

| Файл | Назначение |
| --- | --- |
| [`index.html`](./index.html) | **Главный просмотрщик макетов.** 33 экрана × форм-факторы × Light/Dark (264 комбинации). Переключение: чипы секций, стрелки `←/→`, клавиатура, сегменты Device / Theme. |
| [`tokens.css`](./tokens.css) | Дизайн-токены и компоненты (темы Light/Dark, rail/sidebar, master–detail, info-pane, auth split/card, онбординг, диалоги, звонки). |
| [`references.html`](./references.html) | Референс-борд: мобильные скриншоты Figma (исходник для расширения). |
| [`README.md`](./README.md) | Этот документ. |

Открытие: двойной клик по [`index.html`](./index.html) (без сервера). Самопроверка: `index.html?selftest=1` → в консоли `SELFTEST done — pass: 264 fail: 0`.

---

## Покрытие экранов Figma

> 66 состояний экранов × 2 форм-фактора × 2 темы = **264 макета**. В скобках — состояния.

### Onboarding
- Loading (Start / Middle / Done)
- Introduce (Step 1–4)

### Auth
- Login (Empty / Typing / Filled)
- Login OTP (Empty / Filled / Error / Resent)
- Sign Up (Empty / Filled)
- Sign Up OTP (Empty / Filled / Error / Resent)
- Sign Up · User Information (Empty / Filled)

### Chats
- Chats — список + пустой detail
- Conversation (базовая переписка)
- Conversation · Typing
- Conversation · Custom Color (Coral `#FF6347`)
- Chats · Search (результаты пусты)
- Chats · Add menu (диалог Add Friend / Create Group)
- User Information (Info / Report+Block / Media / Links / Documents / Protected Chat)
- Group Information (Info / Report+Leave + список участников)

### Groups
- Groups — список
- Group Conversation (обычный / кастомный цвет Indigo)

### Add
- Add Friend (выбор / поиск)
- Create Group (+ added members)

### Profile / More
- Profile (view / edit-диалог)
- More (Language, Dark Mode, Mute, Invite, Security, Help, Legal, Log out)
- Invite Friends (ссылка + share)
- Security (list / Change PIN)
- Setting · Notification
- Setting · Face ID / Touch ID / PIN (setup / scanning / done)
- Help Center (list / detail)
- Privacy Policy / Terms of Service

### Calls
- Chats · Call (входящий: Decline / Accept)
- Chats · Calling (таймер `03:45`, Mute · Speaker · End)
- Chats · Video Calling (Camera, PiP, Flash · Shutter · Flip)

---

## Правила раскладки (как в спецификации)

| Форм-фактор | Chrome | Master | Detail | Info |
| --- | --- | ---: | ---: | ---: |
| Tablet 768 | `TNavigationRail` **72** (иконки) | 300 | flex | нет колонки → overlay-панель 320 справа |
| Desktop 1440 | sidebar **240** (иконки + подписи) | 320 | flex (min 420) | колонка **320** (ThreePane) |

- Авторизация/онбординг: tablet — центрированная карточка 480 на фоне surface; desktop — **split**: слева brand/gradient (40%), справа форма 440.
- Profile / More / Help / Legal — одна колонка с `MaxWidthBox` 560 по центру (tiles не растягиваются).
- Модалки и sheets (Add Friend, Create Group, Edit profile) — центрированный dialog max 480, radius 16, `shadow2`.
- Звонки: tablet — full overlay; desktop — центрированная панель max 420×780 поверх dim shell.
- Colors/типографика/иконки — те же токены, что в Figma и `TColors` (`#1565C0`, `#40C4FF`, Roboto, Material-подобные outline-глифы). Новые hex не вводятся.
- Density: высота `TConversationTile` 64, padding thread 24, базовые кегли не увеличиваются.

---

## Структура `index.html`

Просмотрщик построен на JS-шаблонах: каждый экран — функция `render({device, theme, state})` в реестре `SCREENS`, собранная из общих компонентов (`chrome`, `masterList`, `threadHtml`, `composer`, `infoPane`, `authFrame`, `singleScreen`, `callScreens`). Это соответствует подходу «одна фича, breakpoint-композиция» из [`architecture_echat.md`](../architecture_echat.md): ничего не копируется под tablet/desktop — меняется только композиция.

Соответствие коду: `TBreakpoints` / `appBreakpointProvider` → `TwoPane`/`ThreePane` → `TNavigationRail` / sidebar → `TSizes.railWidth|sidebarWidth|masterPaneWidth|infoPaneWidth`.