# Переиспользуемые виджеты E-Chat (Figma)

Документ составлен по макетам [Chatting App UI Kit Design | E-Chat](https://www.figma.com/design/Do69JP5vfRzBNw3OO2jRHH/Chatting-App-UI-Kit-Design-_-E-Chat-_-Figma--Community-).

Связанные материалы: [architecture.md](./architecture.md), [echat_colors.dart](./echat_colors.dart).

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
| 1 | **Button Md** | 50 | `EChatAppBar` / `EChatIconTitleBar` — средняя кнопка в шапке (назад, поиск, меню) |
| 2 | **Button** | 29 | `EChatPrimaryButton` — основная CTA (Get started, Continue, Save…) |
| 3 | **Button Icon** | 29 | `EChatIconButton` — круглая иконка (звонок, видео, редактирование) |
| 4 | **Avatar** | 22 | `EChatAvatar` — аватар пользователя / группы |
| 5 | **Card User Information** | 14 | `EChatChatAppBar` — шапка экрана переписки (аватар + имя + статус) |
| 6 | **Input Message** | 14 | `EChatMessageInput` — поле ввода сообщения в чате |
| 7 | **Keyboard - iPhone - Number** | 13 | `EChatNumericKeyboard` — цифровая клавиатура (OTP, PIN) |
| 8 | **Button Lg** | 10 | `EChatLargeButton` — широкая кнопка (Sign Up / Login flow) |
| 9 | **Input Phone Number** | 9 | `EChatPhoneInput` — ввод телефона с кодом страны |
| 10 | **Checkbox** | 8 | `EChatCheckbox` — чекбокс согласия с условиями |
| 11 | **Code Verify** | 8 | `EChatOtpInput` — поля ввода OTP-кода |
| 12 | **Button Sm** | 7 | `EChatSmallButton` — компактная кнопка (Add, Message, Invite) |
| 13 | **Card Setting** | 7 | `EChatSettingsTile` — строка настроек чата (иконка + заголовок + chevron) |
| 14 | **Toggle** | 7 | `EChatToggle` — переключатель (mute, hide chat…) |
| 15 | **Card Input** | 6 | `EChatSearchInput` / `EChatLabeledInput` — поле с иконкой и лейблом |
| 16 | **Home Indicator** | 6 | `EChatHomeIndicator` — индикатор iOS внизу экрана |
| 17 | **Logo E-Chat** | 6 | `EChatLogo` — логотип приложения |
| 18 | **Record** | 6 | `EChatVoiceRecordOverlay` — оверлей записи голосового сообщения |
| 19 | **Image Introduce** | 5 | `EChatOnboardingIllustration` — иллюстрации onboarding |
| 20 | **Overlay** | 5 | `EChatModalOverlay` — затемнение под модалками / bottom sheet |
| 21 | **Card Friend** | 4 | `EChatContactTile` — карточка контакта в списке друзей |
| 22 | **Drop Button** | 4 | `EChatDropdownButton` — кнопка с выпадающим меню |
| 23 | **Navbar** | 4 | `EChatBottomNavBar` — нижняя навигация (Chats / Groups / Profile / More) |
| 24 | **Card Message** | 3 | `EChatConversationTile` — превью чата в списке |
| 25 | **Input Your Name** | 3 | `EChatNameInput` — поле имени при регистрации |
| 26 | **PIN Security** | 3 | `EChatPinDots` — индикатор введённых цифр PIN |
| 27 | **Tab** | 3 | `EChatSegmentedTabs` — вкладки Media / Links / Documents |
| 28 | **Input** | 2 | `EChatTextField` — базовое текстовое поле |
| 29 | **Keyboard - iPhone** | 2 | `EChatTextKeyboard` — полная QWERTY-клавиатура |
| 30 | **PopUp Add** | 2 | `EChatAddMenuPopup` — всплывающее меню «+» (новый чат / группа) |

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
| Code Verify | 8 | OTP при Login и Sign Up |
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
| Keyboard - iPhone - Number | 13 | OTP, PIN, ввод телефона |
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

## Рекомендуемая структура `lib/shared/widgets/`

```
lib/shared/widgets/
├── buttons/
│   ├── echat_primary_button.dart      # Button
│   ├── echat_large_button.dart        # Button Lg
│   ├── echat_medium_button.dart       # Button Md
│   ├── echat_small_button.dart        # Button Sm
│   ├── echat_icon_button.dart         # Button Icon
│   └── echat_dropdown_button.dart     # Drop Button
├── inputs/
│   ├── echat_phone_input.dart         # Input Phone Number
│   ├── echat_name_input.dart          # Input Your Name
│   ├── echat_text_field.dart          # Input
│   ├── echat_search_input.dart        # Card Input
│   ├── echat_message_input.dart       # Input Message
│   ├── echat_otp_input.dart           # Code Verify
│   ├── echat_checkbox.dart            # Checkbox
│   ├── echat_toggle.dart              # Toggle
│   └── echat_pin_dots.dart            # PIN Security
├── cards/
│   ├── echat_conversation_tile.dart   # Card Message
│   ├── echat_contact_tile.dart        # Card Friend
│   ├── echat_chat_app_bar.dart        # Card User Information
│   └── echat_settings_tile.dart       # Card Setting
├── navigation/
│   ├── echat_bottom_nav_bar.dart      # Navbar
│   └── echat_segmented_tabs.dart      # Tab
├── media/
│   └── echat_avatar.dart              # Avatar
├── chrome/
│   ├── echat_status_bar.dart          # Status Bar (из шаблона экрана)
│   ├── echat_home_indicator.dart      # Home Indicator
│   ├── echat_logo.dart                # Logo E-Chat
│   └── echat_modal_overlay.dart       # Overlay
├── chat/
│   ├── echat_voice_record_overlay.dart # Record
│   └── echat_add_menu_popup.dart      # PopUp Add
└── onboarding/
    └── echat_onboarding_illustration.dart # Image Introduce
```

---

## Виджеты на одном экране (не выносить в shared пока)

Следующие Figma-компоненты встречаются только на одном экране или в витрине — их можно реализовать локально в feature-модуле:

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

1. **P0 — скелет приложения:** `Navbar`, `Button Md`, `Avatar`, `Card Message`, `EChatStatusBar`
2. **P0 — auth flow:** `Button Lg`, `Input Phone Number`, `Code Verify`, `Checkbox`, `Button`, `Logo E-Chat`
3. **P1 — чаты:** `Card User Information`, `Input Message`, `EChatConversationTile`, `Record`
4. **P1 — профиль и настройки:** `Card Setting`, `Toggle`, `Card Input`, `Tab`
5. **P2 — onboarding:** `Image Introduce`, `Button`, `EChatHomeIndicator`

---

*Дата анализа: 28.08.2026. Источник: Figma file key `Do69JP5vfRzBNw3OO2jRHH`, канвас Design.*
