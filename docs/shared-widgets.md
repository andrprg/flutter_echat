# Переиспользуемые виджеты E-Chat (Figma)

Документ составлен по макетам [Chatting App UI Kit Design | E-Chat](https://www.figma.com/design/Do69JP5vfRzBNw3OO2jRHH/Chatting-App-UI-Kit-Design-_-E-Chat-_-Figma--Community-).

Связанные материалы: [architecture_echat.md](./architecture_echat.md), [echat_colors.dart](./echat_colors.dart), [layouts-tablet-desktop.md](./layouts-tablet-desktop.md), [HTML-макеты tablet/desktop](./mockups/echat-tablet-desktop.html).

**Именование:** пользовательские виджеты — класс с префиксом `T` (`TChatButton`), файл `t_*.dart` (см. architecture §5 / правило `file-naming`).

---

## Методология

| Параметр | Значение |
| --- | --- |
| Канвас | `🌷 Design` (экраны приложения) |
| Экранов проанализировано | **176** (Light + Dark, все состояния) |
| Критерий «переиспользуемый» | Figma-компонент (INSTANCE или вложенный IMAGE-SVG) встречается **≥ 2 экранах** |
| Исключено | Внутренние части клавиатуры (`_Keys/*`), секционные заголовки («Login», «Chats»), витрина компонентов на канвасе `🌸 Component` |

**Примечание:** `Status Bar` встроен в шаблон экрана (393×852) и не фигурирует как отдельный INSTANCE в дереве — его стоит вынести в `shared/widgets/` как обязательную обёртку экрана, хотя он не попал в автоматический подсчёт.

---

## Сводная таблица (30 виджетов)

| # | Figma Component | Экранов | Предлагаемый Flutter-виджет |
| --- | --- | ---: | --- |
| 1 | **Button Md** | 50 | `TAppBar` / `TIconTitleBar` — средняя кнопка в шапке (назад, поиск, меню) |
| 2 | **Button** | 29 | `TChatButton` / `TPrimaryButton` — основная CTA (Get started, Continue, Save…) |
| 3 | **Button Icon** | 29 | `TIconButton` — круглая иконка (звонок, видео, редактирование) |
| 4 | **Avatar** | 22 | `TAvatar` — аватар пользователя / группы |
| 5 | **Card User Information** | 14 | `TChatAppBar` — шапка экрана переписки (аватар + имя + статус) |
| 6 | **Input Message** | 14 | `TMessageInput` — поле ввода сообщения в чате |
| 7 | **Keyboard - iPhone - Number** | 13 | `TNumericKeyboard` — цифровая клавиатура (PIN) |
| 8 | **Button Lg** | 10 | `TLargeButton` — широкая кнопка (Sign Up / Login flow) |
| 9 | **Input Phone Number** | 9 | `TPhoneInput` — ввод телефона с кодом страны |
| 10 | **Checkbox** | 8 | `TCheckbox` — чекбокс согласия с условиями |
| 11 | **Code Verify** | 8 | `TCodeInput` — поля ввода проверочного кода |
| 12 | **Button Sm** | 7 | `TSmallButton` — компактная кнопка (Add, Message, Invite) |
| 13 | **Card Setting** | 7 | `TSettingsTile` — строка настроек чата (иконка + заголовок + chevron) |
| 14 | **Toggle** | 7 | `TToggle` — переключатель (mute, hide chat…) |
| 15 | **Card Input** | 6 | `TSearchInput` / `TLabeledInput` — поле с иконкой и лейблом |
| 16 | **Home Indicator** | 6 | `THomeIndicator` — индикатор iOS внизу экрана |
| 17 | **Logo E-Chat** | 6 | `TLogo` — логотип приложения |
| 18 | **Record** | 6 | `TVoiceRecordOverlay` — оверлей записи голосового сообщения |
| 19 | **Image Introduce** | 5 | `TOnboardingIllustration` — иллюстрации onboarding |
| 20 | **Overlay** | 5 | `TModalOverlay` — затемнение под модалками / bottom sheet |
| 21 | **Card Friend** | 4 | `TContactTile` — карточка контакта в списке друзей |
| 22 | **Drop Button** | 4 | `TDropdownButton` — кнопка с выпадающим меню |
| 23 | **Navbar** | 4 | `TBottomNavBar` — нижняя навигация (Chats / Groups / Profile / More) |
| 24 | **Card Message** | 3 | `TConversationTile` — превью чата в списке |
| 25 | **Input Your Name** | 3 | `TNameInput` — поле имени при регистрации |
| 26 | **PIN Security** | 3 | `TPinDots` — индикатор введённых цифр PIN |
| 27 | **Tab** | 3 | `TSegmentedTabs` — вкладки Media / Links / Documents |
| 28 | **Input** | 2 | `TTextField` — базовое текстовое поле |
| 29 | **Keyboard - iPhone** | 2 | `TTextKeyboard` — полная QWERTY-клавиатура |
| 30 | **PopUp Add** | 2 | `TAddMenuPopup` — всплывающее меню «+» (новый чат / группа) |

---

## Группировка по назначению

### Кнопки и действия

| Виджет | Экранов | Типичные сценарии |
| --- | ---: | --- |
| Button Md | 50 | Шапки чатов, звонков, настроек, Help Center |
| Button | 29 | Onboarding, регистрация, подтверждение PIN/Face ID |
| Button Icon | 29 | Звонок, видео, камера, редактирование профиля |
| Button Lg | 10 | Sign Up / Login — основное действие формы |
| Button Sm | 7 | Add friend, Message, Invite в списках |
| Drop Button | 4 | Контекстные меню (Help Center, Profile) |
| PopUp Add | 2 | Меню быстрого добавления на главных экранах Chats |

### Поля ввода и формы

| Виджет | Экранов | Типичные сценарии |
| --- | ---: | --- |
| Input Message | 14 | Экран переписки (личный и групповой чат) |
| Input Phone Number | 9 | Login, Sign Up, Add Friend, Edit Profile |
| Code Verify | 8 | Ввод проверочных кодов при Login и Sign Up |
| Checkbox | 8 | Согласие с Terms of Service |
| Card Input | 6 | Поиск участников группы, Edit Profile |
| Input Your Name | 3 | Шаг «User Information» регистрации |
| Input | 2 | Поиск в групповом чате |
| PIN Security | 3 | Экраны PIN Security (Default / Scanning / Done) |

### Карточки и списки

| Виджет | Экранов | Типичные сценарии |
| --- | ---: | --- |
| Card User Information | 14 | App bar переписки |
| Card Setting | 7 | Настройки личного и группового чата |
| Card Friend | 4 | Add Friend, Create Group, Select Members |
| Card Message | 3 | Список чатов (Chats home) |
| Avatar | 22 | Везде, где отображается пользователь или группа |

### Навигация и вкладки

| Виджет | Экранов | Типичные сценарии |
| --- | ---: | --- |
| Navbar | 4 | Chats home, Add menu, Search, Profile Edit |
| Tab | 3 | User Information — Media / Links / Documents |

### Переключатели

| Виджет | Экранов | Типичные сценарии |
| --- | ---: | --- |
| Toggle | 7 | Mute notification, Hide chat, Custom settings |

### Системные и декоративные

| Виджет | Экранов | Типичные сценарии |
| --- | ---: | --- |
| Home Indicator | 6 | Экраны с клавиатурой и модалками |
| Logo E-Chat | 6 | Splash / Loading, Profile, Chats home |
| Image Introduce | 5 | Onboarding steps 1–4, Notifications intro |
| Overlay | 5 | Модальные окна, bottom sheets |
| Record | 6 | Запись голосового сообщения в чате |

### Клавиатуры

| Виджет | Экранов | Типичные сценарии |
| --- | ---: | --- |
| Keyboard - iPhone - Number | 13 | PIN, ввод телефона |
| Keyboard - iPhone | 2 | Ввод имени пользователя |

---

## Экраны по виджетам (топ-5 по охвату)

### Button Md (50 экранов)

Переписки, звонки, информация о чате/группе, настройки биометрии, Help Center:

- `Chats _ Conversation` (+ Attachment, Custom, Typing, 2, 3)
- `(Ver 2) Chats _ Conversation` (+ Attachment, Custom, Record, Typing, 2, 3)
- `Groups _ Conversation` (+ Custom), `(Ver 2) Groups _ Conversation` (+ Custom)
- `Chats _ Call`, `Chats _ Calling`, `Chats _ Video Calling`
- `Groups _ Call`, `Groups _ Calling` (1–3), `Groups _ Video Calling` (1–3)
- `Chats _ User Information` (+ Custom, Documents, Links, Media, Protected Chat, 2)
- `Chats _ Group Information` (+ Custom, 2)
- `Add Function _ Add Friend` (+ Searching), `Add Function _ Create Group`, `Add Function _ Added Members`
- `Setting _ Face ID` (+ Done, Scanning), `Setting _ Touch ID` (+ Done, Scanning)
- `Setting _ PIN Security` (+ Done, Scanning), `Help Center _ Detail`

### Button / Button Icon / Avatar (22–29 экранов)

Пересекаются с блоками: onboarding, auth, чаты, звонки, add-friend flow, settings.

### Input Message + Card User Information (14 экранов)

Все варианты экрана переписки (Light/Dark, личный и групповой чат, состояния attachment/typing/custom).

---

## Рекомендуемая структура `lib/src/shared/widgets/`

```
lib/src/shared/widgets/
├── buttons/
│   ├── t_chat_button.dart             # Button → TChatButton / TPrimaryButton
│   ├── t_large_button.dart            # Button Lg
│   ├── t_medium_button.dart           # Button Md
│   ├── t_small_button.dart            # Button Sm
│   ├── t_icon_button.dart             # Button Icon
│   └── t_dropdown_button.dart         # Drop Button
├── inputs/
│   ├── t_phone_input.dart             # Input Phone Number
│   ├── t_name_input.dart              # Input Your Name
│   ├── t_text_field.dart              # Input
│   ├── t_search_input.dart            # Card Input
│   ├── t_message_input.dart           # Input Message
│   ├── t_code_input.dart              # Code Verify
│   ├── t_checkbox.dart                # Checkbox
│   ├── t_toggle.dart                  # Toggle
│   └── t_pin_dots.dart                # PIN Security
├── cards/
│   ├── t_conversation_tile.dart       # Card Message
│   ├── t_contact_tile.dart            # Card Friend
│   ├── t_chat_app_bar.dart            # Card User Information
│   └── t_settings_tile.dart           # Card Setting
├── navigation/
│   ├── t_bottom_nav_bar.dart          # Navbar
│   └── t_segmented_tabs.dart          # Tab
├── media/
│   └── t_avatar.dart                  # Avatar
├── chrome/
│   ├── t_status_bar.dart              # Status Bar (из шаблона экрана)
│   ├── t_home_indicator.dart          # Home Indicator
│   ├── t_logo.dart                    # Logo E-Chat
│   └── t_modal_overlay.dart           # Overlay
├── chat/
│   ├── t_voice_record_overlay.dart    # Record
│   └── t_add_menu_popup.dart          # PopUp Add
└── onboarding/
    └── t_onboarding_illustration.dart # Image Introduce
```

---

## Виджеты на одном экране (не выносить в shared пока)

Следующие Figma-компоненты встречаются только на одном экране или в витрине — их можно реализовать локально в feature-модуле (тоже с префиксом `T`):

| Компонент | Где используется |
| --- | --- |
| Card Group Chat | Список групп |
| Card Group Chat Add Member | Информация о группе — список участников |
| Fingerprint | Экран Touch ID (иллюстрация) |
| Socials | Login — иконки соцсетей |
| View All | Единичные секции списков |
| Radio | Единичный выбор в формах |

---

## Приоритет реализации

1. **P0 — скелет приложения:** `Navbar`, `Button Md`, `Avatar`, `Card Message`, `TStatusBar`
2. **P0 — auth flow:** `Button Lg`, `Input Phone Number`, `Code Verify`, `Checkbox`, `Button`, `Logo E-Chat`
3. **P1 — чаты:** `Card User Information`, `Input Message`, `TConversationTile`, `Record`
4. **P1 — профиль и настройки:** `Card Setting`, `Toggle`, `Card Input`, `Tab`
5. **P2 — onboarding:** `Image Introduce`, `Button`, `THomeIndicator`

---

*Дата анализа: 28.08.2026. Источник: Figma file key `Do69JP5vfRzBNw3OO2jRHH`, канвас Design.*
