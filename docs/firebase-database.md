# Структура базы данных Firebase — E-Chat

Документ описывает схему данных Flutter-приложения чата по UI-киту
[Chatting App UI Kit Design | E-Chat](https://www.figma.com/design/Do69JP5vfRzBNw3OO2jRHH/Chatting-App-UI-Kit-Design-_-E-Chat-_-Figma--Community-).

> **Настройка.** Пошаговое подключение Firebase к проекту: [firebase-setup.md](./firebase-setup.md).  
> **Flutter.** Подключение SDK к приложению: [firebase-flutter-connect.md](./firebase-flutter-connect.md).  
> **События.** Как смотреть записи, логи Functions и Analytics: [firebase-events.md](./firebase-events.md).  
> **Архитектура и план:** [architecture.md](./architecture.md) · [roadmap.md](./roadmap.md).

> **Источник.** Схема сверена с файлом Figma [`node-id=21-122`](https://www.figma.com/design/Do69JP5vfRzBNw3OO2jRHH/Chatting-App-UI-Kit-Design-_-E-Chat-_-Figma--Community-?node-id=21-122) (канвас **🌷 Design**): **89 экранов Light Mode** + **89 экранов Dark Mode**. В макете **нет** отдельной вкладки Contacts и **нет** Stories — контакты через «Add Friend», звонки из экрана чата.

---

## 1. Сервисы Firebase

| Сервис | Назначение |
| --- | --- |
| **Authentication** | Вход и регистрация (экраны Login / Register, Remember me) |
| **Cloud Firestore** | Пользователи, чаты, сообщения, звонки, контакты, уведомления, настройки |
| **Realtime Database** | Online/lastSeen и индикатор «печатает» (экран `(Ver 2) Chats _ Conversation _ Typing`) |
| **Cloud Storage** | Аватары, медиа чатов, голосовые записи, документы, кастомные фоны |
| **Cloud Messaging (FCM)** | Push: сообщения, входящие звонки, разрешение Notification |
| **Cloud Functions** | lastMessage, unreadCount, Protected Chat, скрытие чатов, fan-out уведомлений |

Firestore выбран как основная БД: документы хорошо ложатся на экраны списка чатов, профиля и истории звонков. Realtime Database — только для эфемерных сигналов (presence/typing), чтобы не жечь лимиты Firestore.

---

## 2. Карта экранов Figma → Firebase

Нижняя навигация: **Chats** | **Groups** | **Profile** | **More**.

| Раздел Figma (фреймы) | Хранение |
| --- | --- |
| **Loading** (_Start, _Middle, _Done) | Локально; версия приложения в `pubspec` |
| **Introduce _ Step 1–4** (Group Chatting, Video/Voice Calls, Message Encryption, Cross-Platform) | Локально (`onboardingCompleted`) |
| **Login / Sign Up** (_Empty, _Typing, _Filled*) | Firebase Auth + `users` |
| **Sign Up _ User Information** (имя + аватар) | `users` |
| **Set Face ID / Touch ID / PIN Security** | Флаги в `users`; секреты локально |
| **Setting _ Notification** | `userSettings.notificationsEnabled` + OS permission |
| **Chats** (список, Search, Click Add) | `chats`, `members` |
| **Add Function** (Add Friend, Create Group, Add members) | `contacts`, `chats` (`type: group`) |
| **Chats _ Conversation** (Attachment, Record, Typing, Custom) | `messages`, RTDB `/typing` |
| **Chats _ Call / Calling / Video Calling** | `calls` |
| **Chats _ User/Group Information** | `users`, `chats`, `members` |
| Media, Links & Documents | Запрос к `messages` (`type` in image/video/file/link) |
| Mute / Custom Notification, Protected Chat, Hide Chat/History | `members` |
| Custom Color / Custom Background Chat | `members.customColor`, `members.customBackgroundUrl` |
| Add To Group, Report, Block | `chats`, `reports`, `blocks` |
| **Groups** (_Conversation, _Call, _Video Calling) | `chats`, `messages`, `calls` |
| **Profile** (_Edit, Logout) | `users`, `userSettings` |
| **More** (Language, Dark Mode, Sound) | `userSettings` |
| Other Apps, Invite Friends, Security, Help Center | `userSettings`; Help/Terms/Privacy — CMS или assets |
| **Notification** (in-app центр) | `notifications` |
| Smart Replies, Chat Bots, Game Onlines, … (**COMING SOON**) | Не в MVP; см. §13 |

---

## 3. Экраны UI → сущности (сводка)

| Группа экранов | Коллекции |
| --- | --- |
| Splash, Onboarding, Introduce | — (локально) |
| Login, Sign Up, User Information | Auth + `users` |
| Face ID, Touch ID, PIN, Notification permission | `users`, `userSettings` |
| Chats, Groups (списки и переписка) | `chats`, `members`, `messages` |
| Звонки из чата | `calls` |
| Add Friend, Invite Friends | `contacts` |
| User / Group Information | `users`, `chats`, `members` |
| Profile, Edit Profile, More settings | `users`, `userSettings` |
| Block, Report | `blocks`, `reports` |
| Notification list | `notifications` |

---

## 4. Дерево коллекций Firestore

```
users/{userId}
  devices/{deviceId}

userSettings/{userId}

contacts/{ownerId_peerId}

blocks/{blockerId_blockedId}

chats/{chatId}
  members/{userId}
  messages/{messageId}
    reactions/{userId}

calls/{callId}
  participants/{userId}

notifications/{notificationId}

# опционально, не в текущем Figma-макете:
# stories/{storyId}/views/{viewerId}

reports/{reportId}
```

Идентификаторы:

- `userId` — UID из Firebase Auth.
- Личный чат: `chatId = [uidA, uidB].sort().join('_')`.
- Группа, звонок, сторис, сообщение — авто-id Firestore (`autoId`).
- Контакт / блок: составной ключ `ownerId_peerId`, чтобы документ был уникален и дёшев в чтении.

---

## 5. Коллекции и поля

### 5.1. `users/{userId}`

Профиль. Экраны: Sign Up _ User Information, Profile, Profile _ Edit, Chats _ User Information (Rating + ID с кнопкой Copy).

| Поле | Тип | Обязательное | Описание |
| --- | --- | --- | --- |
| `id` | `string` | да | Дублирует document id (= Auth UID) |
| `displayName` | `string` | да | Имя на экранах чата и профиля |
| `username` | `string` | нет | Уникальный @username для поиска |
| `usernameLower` | `string` | нет | `username` в нижнем регистре (поиск) |
| `email` | `string \| null` | нет | Email, если вход по почте |
| `phone` | `string \| null` | нет | E.164, например `+442012345629` |
| `phoneCountryCode` | `string` | да | Код страны из селектора (+44, +7…) |
| `eChatPublicId` | `string` | да | Публичный ID для копирования (экран User Information) |
| `photoUrl` | `string \| null` | нет | URL аватара в Storage |
| `coverUrl` | `string \| null` | нет | Обложка профиля |
| `about` | `string` | нет | Статус / «About», по умолчанию `"Hey there! I am using E-Chat"` |
| `dateOfBirth` | `timestamp \| null` | нет | Дата рождения |
| `gender` | `string \| null` | нет | `male` \| `female` \| `other` \| `unspecified` |
| `country` | `string \| null` | нет | Страна |
| `searchTokens` | `array<string>` | да | Префиксы имени/телефона/username для поиска контактов |
| `isOnline` | `boolean` | да | Кэш присутствия (истина — в RTDB) |
| `lastSeenAt` | `timestamp` | да | «был(а) в сети» в шапке чата |
| `showLastSeen` | `boolean` | да | Приватность last seen, по умолчанию `true` |
| `showOnline` | `boolean` | да | Приватность online, по умолчанию `true` |
| `showReadReceipts` | `boolean` | да | Галочки прочтения, по умолчанию `true` |
| `allowCallsFrom` | `string` | да | `everyone` \| `contacts` \| `nobody` |
| `pinEnabled` | `boolean` | да | Setting _ PIN Security |
| `faceIdEnabled` | `boolean` | да | Setting _ Face ID |
| `touchIdEnabled` | `boolean` | да | Setting _ Touch ID / Fingerprint Security |
| `isBanned` | `boolean` | да | Блокировка аккаунта админом |
| `createdAt` | `timestamp` | да | Дата регистрации |
| `updatedAt` | `timestamp` | да | Последнее изменение профиля |

Пример:

```json
{
  "id": "u_abc123",
  "displayName": "Andrew Ainsley",
  "username": "andrew_ainsley",
  "usernameLower": "andrew_ainsley",
  "email": "andrew@example.com",
  "phone": "+442012345629",
  "phoneCountryCode": "+44",
  "eChatPublicId": "ECHAT-8F3A2C",
  "photoUrl": "https://firebasestorage.googleapis.com/.../avatars/u_abc123.jpg",
  "coverUrl": null,
  "about": "Designer ✨",
  "dateOfBirth": "1995-08-12T00:00:00Z",
  "gender": "male",
  "country": "US",
  "searchTokens": ["a", "an", "and", "andrew", "+12025550123"],
  "isOnline": true,
  "lastSeenAt": "2026-08-28T08:41:00Z",
  "showLastSeen": true,
  "showOnline": true,
  "showReadReceipts": true,
  "allowCallsFrom": "everyone",
  "pinEnabled": true,
  "faceIdEnabled": false,
  "touchIdEnabled": false,
  "isBanned": false,
  "createdAt": "2026-01-10T12:00:00Z",
  "updatedAt": "2026-08-28T08:41:00Z"
}
```

#### Подколлекция `users/{userId}/devices/{deviceId}`

FCM-токены. Экран уведомлений, входящий звонок.

| Поле | Тип | Описание |
| --- | --- | --- |
| `fcmToken` | `string` | Токен устройства |
| `platform` | `string` | `android` \| `ios` \| `web` |
| `appVersion` | `string` | Версия клиента |
| `updatedAt` | `timestamp` | Последнее обновление токена |

---

### 5.2. `userSettings/{userId}`

Экраны **More** (Language, Dark Mode, Sound), **Setting _ Notification**, **Security**.

| Поле | Тип | По умолчанию | Описание |
| --- | --- | --- | --- |
| `theme` | `string` | `system` | `light` \| `dark` \| `system` |
| `language` | `string` | `en` | Код языка UI (`en`, `ru`, …) |
| `notificationsEnabled` | `boolean` | `true` | Мастер-переключатель пушей |
| `messageNotifications` | `boolean` | `true` | Пуш о сообщениях |
| `groupNotifications` | `boolean` | `true` | Пуш о группах |
| `callNotifications` | `boolean` | `true` | Пуш о звонках |
| `storyNotifications` | `boolean` | `true` | Зарезервировано (нет в макете) |
| `notificationSound` | `string` | `default` | Идентификатор звука |
| `notificationPreview` | `boolean` | `true` | Показывать текст в пуше |
| `enterIsSend` | `boolean` | `false` | Enter = отправить |
| `mediaAutoDownloadWifi` | `boolean` | `true` | Автозагрузка медиа по Wi-Fi |
| `mediaAutoDownloadMobile` | `boolean` | `false` | Автозагрузка по мобильной сети |
| `chatWallpaperUrl` | `string \| null` | `null` | Фон чата |
| `fontScale` | `number` | `1.0` | Масштаб шрифта |
| `updatedAt` | `timestamp` | — | Время изменения |

PIN и биометрия **не** хранятся открытым текстом: флаг в `users`, сам PIN — локально (secure storage) или через Firebase App Check + Cloud Function. Пароль аккаунта — только Firebase Auth.

---

### 5.3. `contacts/{ownerId_peerId}`

Add Friend, Add Function _ Add Friend _ Searching, Invite Friends.

| Поле | Тип | Описание |
| --- | --- | --- |
| `ownerId` | `string` | Кто добавил |
| `peerId` | `string` | Пользователь E-Chat |
| `alias` | `string \| null` | Локальное имя контакта |
| `phone` | `string \| null` | Номер из книжки телефона |
| `source` | `string` | `app` \| `phonebook` \| `invite` |
| `isFavorite` | `boolean` | Избранный контакт |
| `createdAt` | `timestamp` | Когда добавлен |

Запросы:

- контакты пользователя: `where('ownerId', '==', me)`.
- избранные: дополнительно `where('isFavorite', '==', true)`.

Пользователи, которых ещё нет в E-Chat (invite по SMS), в Firestore не пишем — только локальный/системный шаринг.

---

### 5.4. `blocks/{blockerId_blockedId}`

Экран **Chats _ User Information** → Block.

| Поле | Тип | Описание |
| --- | --- | --- |
| `blockerId` | `string` | Кто заблокировал |
| `blockedId` | `string` | Кого |
| `createdAt` | `timestamp` | Когда |

Правила: заблокированный не может писать в личный чат и звонить.

---

### 5.5. `chats/{chatId}`

Вкладки **Chats** и **Groups**. Список: аватар, имя, last message, время, unread badge.

| Поле | Тип | Описание |
| --- | --- | --- |
| `id` | `string` | Document id |
| `type` | `string` | `direct` \| `group` |
| `participantIds` | `array<string>` | Все участники (для `array-contains` в инбоксе) |
| `title` | `string \| null` | Имя группы; для direct — `null` (имя берём из собеседника) |
| `photoUrl` | `string \| null` | Аватар группы |
| `description` | `string \| null` | Описание группы |
| `createdBy` | `string` | Создатель |
| `inviteLink` | `string \| null` | Ссылка-приглашение в группу |
| `onlyAdminsCanPost` | `boolean` | Режим «только админы пишут» |
| `onlyAdminsCanEditInfo` | `boolean` | Только админы меняют название/фото |
| `lastMessage` | `map \| null` | Снимок последнего сообщения (см. ниже) |
| `lastMessageAt` | `timestamp` | Сортировка списка чатов |
| `createdAt` | `timestamp` | Создание чата |
| `updatedAt` | `timestamp` | Любое изменение метаданных |
| `isDeleted` | `boolean` | Мягкое удаление группы |
| `isProtected` | `boolean` | Protected Chat (шифрование; флаг на уровне чата) |
| `memberCount` | `number` | Кол-во участников (группа; UI «3 members») |

`lastMessage` (денормализация для списка чатов без чтения подколлекции):

| Поле | Тип | Описание |
| --- | --- | --- |
| `id` | `string` | Id сообщения |
| `senderId` | `string` | Автор |
| `type` | `string` | См. типы сообщений |
| `text` | `string \| null` | Превью текста / подпись |
| `preview` | `string` | Готовая строка для UI: `"Photo"`, `"Voice message"`, `"You: Hello"` |

#### Подколлекция `chats/{chatId}/members/{userId}`

Персональные настройки из **User/Group Information**: Mute, Hide Chat, Custom Color/BG и т.д.

| Поле | Тип | Описание |
| --- | --- | --- |
| `userId` | `string` | Участник |
| `role` | `string` | `owner` \| `admin` \| `member` |
| `nickname` | `string \| null` | Ник в группе |
| `joinedAt` | `timestamp` | Вступил |
| `leftAt` | `timestamp \| null` | Вышел |
| `isActive` | `boolean` | Сейчас в чате |
| `unreadCount` | `number` | Бейдж (5, 12, 1…) на списке Chats |
| `lastReadMessageId` | `string \| null` | Курсор прочтения |
| `lastReadAt` | `timestamp \| null` | Когда прочитал |
| `isPinned` | `boolean` | Закреплён |
| `pinnedAt` | `timestamp \| null` | Порядок пинов |
| `isMuted` | `boolean` | Mute Notification |
| `mutedUntil` | `timestamp \| null` | Mute на время |
| `customNotificationSound` | `string \| null` | Custom Notification |
| `isHidden` | `boolean` | Hide Chat |
| `hideHistoryAt` | `timestamp \| null` | Hide Chat History — скрыть сообщения до даты |
| `isArchived` | `boolean` | В архиве |
| `isCleared` | `boolean` | «Очистить чат» только у себя |
| `clearedAt` | `timestamp \| null` | Сообщения старше даты скрыты |
| `customColor` | `string \| null` | Custom Color Chat (hex) |
| `customBackgroundUrl` | `string \| null` | Custom Background Chat |
| `wallpaperUrl` | `string \| null` | Фон (alias для customBackgroundUrl) |
| `draft` | `string \| null` | Черновик ввода |
| `notificationPreset` | `string` | `all` \| `mentions` \| `none` |

Инбокс пользователя:

```
chats.where('participantIds', arrayContains: me)
     .orderBy('lastMessageAt', descending: true)
```

Pin/archive фильтруются по `members/{me}` уже на клиенте или через Cloud Function → отдельную коллекцию `userChats/{userId}/items/{chatId}` (см. §7, опция для масштаба).

---

### 5.6. `chats/{chatId}/messages/{messageId}`

Лента чата. Экраны **Chats _ Conversation**, _Attachment, _Record (голосовое), emoji/GIF из composer.

| Поле | Тип | Описание |
| --- | --- | --- |
| `id` | `string` | Document id |
| `chatId` | `string` | Родительский чат |
| `senderId` | `string` | Автор; для system — `"system"` |
| `type` | `string` | `text` \| `image` \| `video` \| `audio` \| `voice` \| `file` \| `sticker` \| `gif` \| `location` \| `contact` \| `storyReply` \| `system` |
| `text` | `string \| null` | Текст или подпись к медиа |
| `mentions` | `array<string>` | UID упомянутых в группе |
| `media` | `map \| null` | Вложение (см. ниже) |
| `replyTo` | `map \| null` | Ответ на сообщение |
| `forwardedFrom` | `map \| null` | Переслано из |
| `storyId` | `string \| null` | Ответ на сторис |
| `status` | `string` | `sending` \| `sent` \| `delivered` \| `read` \| `failed` |
| `deliveredTo` | `map<string, timestamp>` | Кому доставлено |
| `readBy` | `map<string, timestamp>` | Кто прочитал (галочки / info) |
| `isEdited` | `boolean` | Сообщение правили |
| `editedAt` | `timestamp \| null` | Когда правили |
| `isDeleted` | `boolean` | Удалено |
| `deletedFor` | `array<string>` | `delete for me` — список UID |
| `deletedAt` | `timestamp \| null` | Delete for everyone |
| `starredBy` | `array<string>` | Избранные сообщения |
| `expiresAt` | `timestamp \| null` | Исчезающие сообщения |
| `clientNonce` | `string` | Идемпотентность optimistic UI |
| `createdAt` | `timestamp` | Сортировка ленты |
| `updatedAt` | `timestamp` | Последнее изменение |

`media`:

| Поле | Тип | Описание |
| --- | --- | --- |
| `url` | `string` | Публичный/signed URL Storage |
| `storagePath` | `string` | Путь в бакете |
| `mimeType` | `string` | `image/jpeg`, `audio/m4a`, … |
| `fileName` | `string \| null` | Имя файла |
| `sizeBytes` | `number` | Размер |
| `width` | `number \| null` | Ширина изображения/видео |
| `height` | `number \| null` | Высота |
| `durationMs` | `number \| null` | Длительность voice/video |
| `waveform` | `array<number> \| null` | Пики для волны голосового |
| `thumbnailUrl` | `string \| null` | Превью видео |
| `blurHash` | `string \| null` | Плейсхолдер картинки |

`replyTo` / `forwardedFrom` — снимок, чтобы UI не ходил за оригиналом:

```json
{
  "messageId": "m1",
  "senderId": "u_xyz",
  "senderName": "Jenny",
  "type": "text",
  "text": "See you at 7"
}
```

`location`:

```json
{
  "lat": 55.751244,
  "lng": 37.618423,
  "name": "Red Square",
  "address": "Moscow, Russia"
}
```

`contact` (шаринг контакта):

```json
{
  "userId": "u_opt",
  "displayName": "Tom Holland",
  "phone": "+12025550199",
  "photoUrl": "..."
}
```

`system` (`text` или `systemPayload`):

```json
{
  "action": "member_added",
  "actorId": "u_abc",
  "targetIds": ["u_new"]
}
```

Действия system: `chat_created`, `member_added`, `member_removed`, `member_left`, `title_changed`, `photo_changed`, `role_changed`, `call_started`, `call_ended`.

Лента:

```
messages.orderBy('createdAt', descending: true).limit(40)
```

Фильтр «очищенного» чата: `createdAt > members/{me}.clearedAt`.

#### `chats/{chatId}/messages/{messageId}/reactions/{userId}`

Эмодзи-реакции на пузырьке.

| Поле | Тип | Описание |
| --- | --- | --- |
| `userId` | `string` | Кто поставил |
| `emoji` | `string` | `❤️`, `👍`, `😂`, … |
| `createdAt` | `timestamp` | Когда |

Один пользователь — одна реакция на сообщение (document id = `userId`). Сводка для UI кэшируется Cloud Function в `messages.reactionCounts: { "❤️": 3 }` при необходимости.

---

### 5.7. `calls/{callId}`

Экраны **Chats _ Call / Calling / Video Calling**, **Groups _ Call / Video Calling**.

| Поле | Тип | Описание |
| --- | --- | --- |
| `id` | `string` | Document id |
| `type` | `string` | `audio` \| `video` |
| `mode` | `string` | `direct` \| `group` |
| `chatId` | `string \| null` | Связанный чат |
| `callerId` | `string` | Кто начал |
| `participantIds` | `array<string>` | Все участники (для истории звонков) |
| `status` | `string` | `ringing` \| `accepted` \| `declined` \| `missed` \| `ended` \| `failed` \| `busy` |
| `startedAt` | `timestamp` | Старт вызова |
| `connectedAt` | `timestamp \| null` | Когда взяли трубку |
| `endedAt` | `timestamp \| null` | Завершение |
| `durationSec` | `number` | Длительность разговора |
| `endReason` | `string \| null` | `hangup` \| `timeout` \| `network` \| `busy` |
| `agoraChannel` / `livekitRoom` | `string \| null` | Id комнаты WebRTC-провайдера |
| `createdAt` | `timestamp` | Создание записи |

#### `calls/{callId}/participants/{userId}`

| Поле | Тип | Описание |
| --- | --- | --- |
| `userId` | `string` | Участник |
| `role` | `string` | `caller` \| `callee` |
| `status` | `string` | `invited` \| `ringing` \| `joined` \| `declined` \| `missed` \| `left` |
| `joinedAt` | `timestamp \| null` | Вошёл в звонок |
| `leftAt` | `timestamp \| null` | Вышел |
| `isMuted` | `boolean` | Микрофон выкл. |
| `isCameraOn` | `boolean` | Камера |
| `isSpeakerOn` | `boolean` | Динамик |

История звонков:

```
calls.where('participantIds', arrayContains: me)
     .orderBy('createdAt', descending: true)
```

Сигналинг ringing лучше вести через FCM + короткий документ `calls` (клиент слушает свой входящий). Медиапоток — Agora / LiveKit / WebRTC, не Firestore.

---

### 5.8. `stories/{storyId}` _(опционально — нет в текущем Figma)_

Кружки сторис над списком чатов, просмотр, создание.

| Поле | Тип | Описание |
| --- | --- | --- |
| `id` | `string` | Document id |
| `authorId` | `string` | Автор |
| `type` | `string` | `image` \| `video` \| `text` |
| `mediaUrl` | `string \| null` | Файл в Storage |
| `storagePath` | `string \| null` | Путь в бакете |
| `thumbnailUrl` | `string \| null` | Превью видео |
| `text` | `string \| null` | Текст поверх / text-story |
| `backgroundColor` | `string \| null` | Цвет фона text-story |
| `durationSec` | `number` | 5 для фото, длина видео |
| `privacy` | `string` | `all_contacts` \| `close_friends` \| `except` |
| `allowedUserIds` | `array<string>` | Если privacy ограничен |
| `excludedUserIds` | `array<string>` | Hide from |
| `viewCount` | `number` | Счётчик просмотров |
| `expiresAt` | `timestamp` | `createdAt + 24h` |
| `createdAt` | `timestamp` | Публикация |

Лента: `where('expiresAt', '>', now).where('authorId', 'in', contactIds)` — у Firestore `in` ≤ 30, поэтому ленту сторис удобнее собирать Cloud Function в `userFeed/{userId}/stories/{storyId}` или читать сторис контактов пачками.

#### `stories/{storyId}/views/{viewerId}`

| Поле | Тип | Описание |
| --- | --- | --- |
| `viewerId` | `string` | Кто посмотрел |
| `viewedAt` | `timestamp` | Когда |

---

### 5.9. `notifications/{notificationId}`

Экран Notifications (in-app список). Push идёт отдельно через FCM.

| Поле | Тип | Описание |
| --- | --- | --- |
| `id` | `string` | Document id |
| `userId` | `string` | Получатель |
| `type` | `string` | `message` \| `group_invite` \| `call_missed` \| `story` \| `contact_joined` \| `mention` |
| `title` | `string` | Заголовок |
| `body` | `string` | Текст |
| `imageUrl` | `string \| null` | Аватар/превью |
| `refType` | `string \| null` | `chat` \| `call` \| `story` \| `user` |
| `refId` | `string \| null` | Id сущности для навигации |
| `isRead` | `boolean` | Прочитано в центре уведомлений |
| `createdAt` | `timestamp` | Сортировка |

Запрос: `where('userId', '==', me).orderBy('createdAt', descending: true)`.

---

### 5.10. `reports/{reportId}`

Жалоба с экрана профиля / чата.

| Поле | Тип | Описание |
| --- | --- | --- |
| `reporterId` | `string` | Кто пожаловался |
| `targetType` | `string` | `user` \| `message` \| `story` \| `group` |
| `targetId` | `string` | Id цели |
| `reason` | `string` | `spam` \| `abuse` \| `nudity` \| `other` |
| `comment` | `string \| null` | Комментарий |
| `status` | `string` | `open` \| `reviewed` \| `dismissed` |
| `createdAt` | `timestamp` | Когда |

---

## 6. Realtime Database (присутствие и typing)

Пути:

```
/status/{userId}
  state: "online" | "offline"
  lastSeenAt: <server timestamp>
  platform: "android"

/typing/{chatId}/{userId}
  isTyping: true
  updatedAt: <server timestamp>
```

Клиент пишет `online` при `onDisconnect` → `offline`. Шапка чата и список контактов читают `status`. Индикатор «печатает…» — `typing/{chatId}`. Документы живут секунды, в Firestore их дублировать не нужно (кроме редкого кэша `users.isOnline` для офлайн-списков).

---

## 7. Cloud Storage

```
avatars/{userId}/{fileName}
covers/{userId}/{fileName}
chats/{chatId}/images/{messageId}.jpg
chats/{chatId}/videos/{messageId}.mp4
chats/{chatId}/thumbs/{messageId}.jpg
chats/{chatId}/voice/{messageId}.m4a
chats/{chatId}/files/{messageId}_{fileName}
stories/{userId}/{storyId}.jpg
wallpapers/{userId}/{fileName}
chatBackgrounds/{userId}/{chatId}/{fileName}
```

Правила: читать медиа чата может только `chatMembers`; сторис — автор и разрешённые зрители; аватар — любой авторизованный (или публичный read).

---

## 8. Индексы Firestore

Составные индексы, которые понадобятся сразу:

| Коллекция | Поля |
| --- | --- |
| `chats` | `participantIds` (array-contains) + `lastMessageAt` DESC |
| `chats/{id}/messages` | `createdAt` DESC |
| `chats/{id}/messages` | `starredBy` (array-contains) + `createdAt` DESC |
| `calls` | `participantIds` (array-contains) + `createdAt` DESC |
| `stories` | `authorId` + `expiresAt` DESC |
| `notifications` | `userId` + `createdAt` DESC |
| `contacts` | `ownerId` + `isFavorite` + `createdAt` DESC |
| `users` | `usernameLower` ASC |
| `users` | `phone` ASC |

Файл для деплоя: `firestore.indexes.json` (создаётся при подключении Firebase CLI).

---

## 9. Правила безопасности (конспект)

Полные rules — отдельный файл при подключении проекта. Принципы:

1. Все операции только для `request.auth != null`.
2. `users/{id}` — писать может только владелец; публичные поля профиля читать авторизованным (с учётом privacy).
3. `chats` — create direct: оба id в `participantIds`, один из них = `auth.uid`. Group: создатель в `participantIds`.
4. `messages` — create, если документ `members/{auth.uid}` существует и `isActive == true`.
5. Update сообщения — только автор и только `text` / `isEdited`; delete for everyone — автор или admin группы.
6. `calls` — участник из `participantIds`.
7. `blocks` — create/delete только `blockerId == auth.uid`.
8. Запретить клиенту менять `unreadCount`, `lastMessage` напрямую — Cloud Functions.

---

## 10. Cloud Functions (рекомендуемые)

| Триггер | Действие |
| --- | --- |
| `messages` onCreate | Обновить `chats.lastMessage`, `lastMessageAt`; инкремент `members.*.unreadCount`; FCM всем кроме отправителя и muted |
| `messages` onCreate | Проверить `blocks`, не доставить сообщение |
| `messages` onUpdate (readBy) | Выставить `status: read` |
| `calls` onCreate (`ringing`) | FCM data-push «входящий звонок» |
| `users` onCreate | Создать `userSettings`, `eChatPublicId`, searchTokens |
| `Auth` user delete | Каскадная очистка профиля и устройств |

Как проверить, что триггер сработал: [firebase-events.md §3](./firebase-events.md#3-логи-cloud-functions) и сценарий «отправка сообщения» в [§9](./firebase-events.md#9-сценарии-e-chat).

---

## 11. Масштабирование инбокса (когда чатов много)

Пока пользователей мало, хватает:

```
chats.where('participantIds', arrayContains: me).orderBy('lastMessageAt')
```

Когда у человека сотни чатов и нужны pin/archive на сервере, добавить fan-out:

```
userChats/{userId}/items/{chatId}
  chatId, type, title, photoUrl,
  lastMessage, lastMessageAt,
  unreadCount, isPinned, isMuted, isArchived, isDeleted
```

Пишет только Cloud Function при каждом сообщении. Клиент Home читает одну коллекцию без join. Имеет смысл вводить после MVP.

---

## 12. Что не хранить в Firebase

| Данные | Где |
| --- | --- |
| Loading / Introduce / Onboarding пройден | `SharedPreferences` |
| Remember me | `SharedPreferences` |
| PIN / Face ID / Touch ID (секреты) | `flutter_secure_storage` / LocalAuth |
| Help Center, Terms, Privacy Policy, About App | Статический контент / Remote Config |
| Черновики (опционально дубль) | Локально + поле `members.draft` |
| Кэш медиа | Локальный диск (например `cached_network_image`) |
| WebRTC ICE/SDP | Провайдер звонков (Agora/LiveKit), не Firestore |

---

## 13. Минимальный набор для первой версии (по Figma)

Чтобы закрыть основной flow макета:

1. Auth: Login / Register
2. `users` (имя, аватар, phone, eChatPublicId) + `userSettings`
3. `chats` + `members` + `messages` (Chats + Groups)
4. `contacts` (Add Friend)
5. `calls` (аудио/видео из чата)
6. Storage + RTDB `status` / `typing`
7. `notifications`, `blocks`, `reports`

Следующим этапом: Protected Chat (E2E), Custom Color/BG, функции **COMING SOON** (Smart Replies, Chat Bots, Game Onlines, Live Translation, Scheduled Messages, Anonymous Chat Rooms, Community, Dating, AR Chat).

---

## 14. Функции COMING SOON (не в MVP)

В макете **More** перечислены расширения без готовых экранов (метка COMING SOON). Для них схему Firebase можно добавить позже:

| Функция Figma | Возможная коллекция |
| --- | --- |
| Smart Replies | `messageSuggestions/{chatId}` или on-device ML |
| Chat Bots | `bots/{botId}`, `chats` с `type: bot` |
| Game Onlines | `games/{gameId}`, `gameSessions` |
| Live Translation | поле `translatedText` в `messages` |
| Scheduled Messages | `scheduledMessages/{id}` |
| Anonymous Chat Rooms | `rooms/{roomId}` |
| Community / Marketplace | отдельные коллекции `communities`, `posts` |
| Dating | профиль `users.datingProfile` |
| AR Chat | `messages.media.arPayload` |

---

## Связанные документы

- [firebase-setup.md](./firebase-setup.md) — rules, Functions, Auth
- [firebase-registration.md](./firebase-registration.md) — реализация Sign Up
- [firebase-events.md](./firebase-events.md) — как смотреть записи, логи, Analytics
- [firebase-flutter-connect.md](./firebase-flutter-connect.md) — подключение SDK
- [architecture_echat.md](./architecture_echat.md) · [roadmap.md](./roadmap.md)
