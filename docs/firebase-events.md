# Отслеживание событий Firebase — E-Chat

Как смотреть, что происходит в Firebase во время разработки и в production: записи в базу, Auth, Cloud Functions, realtime-подписки в приложении, аналитика.

В Firebase **нет одной кнопки «все события»**. Инструмент выбирают по типу события.

> **Настройка сервисов:** [firebase-setup.md](./firebase-setup.md)  
> **Схема данных:** [firebase-database.md](./firebase-database.md)  
> **Подключение Flutter:** [firebase-flutter-connect.md](./firebase-flutter-connect.md)  
> **Архитектура:** [architecture.md](./architecture.md)

---

## Содержание

1. [Карта: что где смотреть](#1-карта-что-где-смотреть)
2. [Живые данные в Console](#2-живые-данные-в-console)
3. [Логи Cloud Functions](#3-логи-cloud-functions)
4. [Подписки из Flutter](#4-подписки-из-flutter)
5. [Firebase Analytics](#5-firebase-analytics)
6. [Crashlytics](#6-crashlytics)
7. [Аудит (Cloud Audit Logs)](#7-аудит-cloud-audit-logs)
8. [Эмулятор](#8-эмулятор)
9. [Сценарии E-Chat](#9-сценарии-e-chat)
10. [Практика для команды](#10-практика-для-команды)
11. [Типичные ошибки](#11-типичные-ошибки)

---

## 1. Карта: что где смотреть

| Тип события | Где смотреть | Когда нужно |
| --- | --- | --- |
| Документ создан / изменён / удалён | **Firestore → Data** | Отладка чатов, профилей, сообщений |
| Пользователь зарегистрировался, OTP | **Authentication → Users** | Login / Register |
| Online, last seen, «печатает» | **Realtime Database → Data** | Presence / typing |
| Загрузка аватара, медиа | **Storage** | Файлы и URL в `users.photoUrl` |
| `lastMessage`, `unreadCount`, FCM | **Functions → Logs** | Серверная логика после сообщения |
| Пользователь открыл чат, отправил сообщение | **Analytics → Events** / **DebugView** | Воронки, продукт (не отладка БД) |
| Падение приложения | **Crashlytics** | Стабильность |
| Кто именно записал документ | **Google Cloud → Audit Logs** | Расследования, не повседневная разработка |

---

## 2. Живые данные в Console

Откройте [Firebase Console](https://console.firebase.google.com/) → проект E-Chat.

После действия в приложении документ должен появиться **сразу**. Это основной способ отладки MVP.

### 2.1. Firestore

**Firestore Database → Data**

| Действие в приложении | Что проверить |
| --- | --- |
| Регистрация | `users/{uid}`, `userSettings/{uid}` |
| Создание личного чата | `chats/{sorted(uidA_uidB)}`, `members/{uid}` |
| Отправка сообщения | `chats/{chatId}/messages/{messageId}` |
| Обновление превью чата | `chats/{chatId}.lastMessage`, `lastMessageAt` (после Cloud Function) |
| Звонок | `calls/{callId}` |
| Add Friend | `contacts/{uid}/items/{peerId}` |

Вкладка **Usage** показывает объём чтений/записей — полезно, если неожиданно растёт счёт.

Фильтры в Console ограничены: сложные запросы (`participantIds array-contains` + `orderBy`) удобнее проверять из приложения или эмулятора.

### 2.2. Authentication

**Authentication → Users**

- появился пользователь после OTP;
- `uid` совпадает с `users/{uid}` в Firestore;
- провайдер — Phone.

**Authentication → Settings → Authorized domains** — если Phone Auth или web-сборка падают на домене.

### 2.3. Realtime Database

**Realtime Database → Data**

| Путь | Смысл |
| --- | --- |
| `/status/{uid}` | `online`, `lastSeen` |
| `/typing/{chatId}/{uid}` | индикатор «печатает» |

Значения должны меняться при открытии/закрытии приложения и при наборе текста. Если узел пустой — клиент не пишет в RTDB или rules отклоняют запись.

### 2.4. Storage

**Storage → Files**

После загрузки аватара: объект в бакете и URL в `users.photoUrl`. При `PERMISSION_DENIED` смотрите `storage.rules` в [firebase-setup.md](./firebase-setup.md).

---

## 3. Логи Cloud Functions

По схеме E-Chat клиент **не** пишет `unreadCount` и `lastMessage` напрямую — это делают функции. Если сообщение есть в `messages`, а превью чата не обновилось, смотрите логи функции, а не только Firestore.

Триггеры из [firebase-database.md §10](./firebase-database.md#10-cloud-functions-рекомендуемые) и [firebase-setup.md §12](./firebase-setup.md#12-cloud-functions):

| Функция | Триггер | Что должно быть в логе |
| --- | --- | --- |
| `createUserSettings` / `onUserCreated` | Auth create / `users/{uid}` | создан `userSettings` |
| `onChatMessageCreated` | `chats/{chatId}/messages/{messageId}` onCreate | обновлены `lastMessage`, `unreadCount`; FCM |
| `onCallCreated` | `calls/{id}` onCreate | FCM «входящий звонок» |

### 3.1. Console

**Build → Functions → Logs** (или **Functions** → конкретная функция → **Logs**).

Ищите по имени функции, `chatId`, `uid`, уровню `Error`.

### 3.2. CLI

```bash
firebase functions:log
```

Только одна функция:

```bash
firebase functions:log --only onChatMessageCreated
```

Следить в реальном времени:

```bash
firebase functions:log --only onChatMessageCreated -n 50
```

### 3.3. Google Cloud Logging

**Google Cloud Console → Logging → Logs Explorer**, фильтр:

```
resource.type="cloud_function"
```

Или для Functions 2nd gen:

```
resource.type="cloud_run_revision"
```

Пример: ошибки конкретной функции за последний час:

```
resource.type="cloud_function"
resource.labels.function_name="onChatMessageCreated"
severity>=ERROR
```

В лог функции пишите `chatId` / `messageId` — без них разбирать fan-out неудобно.

---

## 4. Подписки из Flutter

Клиент не «мониторит Firebase целиком», а **подписывается на коллекции**. По [architecture.md](./architecture.md) это живёт в **DataSource**, не в виджете. UI получает `Stream` через Repository (`Stream<Either<Failure, T>>`).

### 4.1. Firestore `snapshots()`

```dart
FirebaseFirestore.instance
    .collection('chats')
    .doc(chatId)
    .collection('messages')
    .orderBy('createdAt')
    .snapshots()
    .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            // новое сообщение
            break;
          case DocumentChangeType.modified:
            // edit, readBy, status
            break;
          case DocumentChangeType.removed:
            // удаление
            break;
        }
      }
    });
```

Список чатов:

```dart
FirebaseFirestore.instance
    .collection('chats')
    .where('participantIds', arrayContains: uid)
    .orderBy('lastMessageAt', descending: true)
    .snapshots();
```

Для этого запроса нужен составной индекс — см. [firebase-setup.md](./firebase-setup.md).

### 4.2. Realtime Database

```dart
FirebaseDatabase.instance.ref('status/$uid').onValue.listen((event) {
  final online = event.snapshot.child('online').value == true;
});
```

Typing: `/typing/{chatId}/{uid}`.

### 4.3. Auth

```dart
FirebaseAuth.instance.authStateChanges().listen((user) {
  // null — выход; User — сессия
});
```

### 4.4. Правила слоя data

1. Прямых вызовов Firestore/RTDB из `presentation` нет.
2. Исключения Firebase ловятся только в DataSource и мапятся в `Failure`.
3. `listen` без отмены подписки даёт утечки. В Riverpod отмена — через `ref.onDispose` у провайдера стрима.

---

## 5. Firebase Analytics

Это **не** «что случилось в базе», а **что сделал пользователь**: открыл чат, отправил сообщение, начал звонок.

В [roadmap.md](./roadmap.md) Analytics — опционально (фаза 7). Для отладки Firestore/Functions не нужен.

### 5.1. Подключение

Пакет: `firebase_analytics`. Google Analytics включают при создании проекта Firebase (или позже в Console).

```dart
await FirebaseAnalytics.instance.logEvent(
  name: 'message_sent',
  parameters: {
    'chat_type': 'direct', // direct | group
  },
);
```

Имена: `snake_case`, до 40 символов. Не кладите в параметры телефоны, uid, текст сообщений.

Рекомендуемые события E-Chat (когда подключите Analytics):

| Событие | Когда |
| --- | --- |
| `sign_up` / `login` | успешный OTP |
| `message_sent` | исходящее сообщение |
| `chat_opened` | вход в conversation |
| `call_started` | исходящий звонок |
| `friend_added` | Add Friend |

### 5.2. Где смотреть

| Экран Console | Задержка |
| --- | --- |
| **Analytics → DebugView** | секунды (только debug-устройства) |
| **Analytics → Events** | обычно несколько часов |

DebugView — для проверки, что событие уходит. Events — для воронок в production.

### 5.3. Debug-режим

**Android** (package из проекта: `com.example.flutter_echat`):

```bash
adb shell setprop debug.firebase.analytics.app com.example.flutter_echat
```

Снять:

```bash
adb shell setprop debug.firebase.analytics.app .none.
```

**iOS:** в схеме Xcode → Run → Arguments Passed On Launch:

```
-FIRDebugEnabled
```

После этого события появляются в **Analytics → DebugView**.

---

## 6. Crashlytics

Отдельно от Analytics: **падения** и non-fatal, не бизнес-события.

Пакет: `firebase_crashlytics`. Отчёты: Console → **Crashlytics**.

Для отладки «сообщение не записалось в Firestore» Crashlytics не помогает — смотрите Firestore Data и Functions Logs.

---

## 7. Аудит (Cloud Audit Logs)

Журнал «кто записал документ» (сервисный аккаунт функции vs клиент).

**Google Cloud → IAM & Admin → Audit Logs** → включить Data Access для Cloud Firestore.

Особенности:

- платно и шумно на объёме чата;
- для повседневной разработки не включают;
- имеет смысл при расследовании «кто изменил `unreadCount` в обход rules».

---

## 8. Эмулятор

Локально, без затрагивания production.

```bash
firebase emulators:start
```

UI обычно: [http://localhost:4000](http://localhost:4000) — Firestore, Auth, Functions, RTDB, Storage, логи функций.

Flutter указывает на эмулятор через `useFirestoreEmulator`, `useAuthEmulator` и т.д. (только debug). Схема та же: действие в приложении → документ в Emulator UI → лог функции во вкладке Logs.

---

## 9. Сценарии E-Chat

### 9.1. Отправка сообщения 1:1

1. В приложении отправить текст.
2. **Firestore → Data** → `chats/{chatId}/messages/{id}` — документ есть, `senderId`, `text`, `createdAt`.
3. **Functions → Logs** → `onChatMessageCreated` без ошибки.
4. Документ `chats/{chatId}`: обновлены `lastMessage`, `lastMessageAt`.
5. У получателя вырос `members/{peerUid}.unreadCount` (если функция это пишет).
6. Получатель: push (FCM) или новое сообщение в `snapshots()`.

Если шаг 2 есть, а 4 нет — функция не задеплоена, упала или rules/путь триггера не совпадают.

### 9.2. Регистрация по телефону

1. **Authentication → Users** — новый пользователь, Phone.
2. Firestore: `users/{uid}`, `userSettings/{uid}`.
3. Лог `createUserSettings` / `onUserCreated`, если настройки создаёт функция.

### 9.3. Online / typing

1. Открыть чат — `/status/{uid}.online == true`.
2. Свернуть приложение — `online == false`, обновился `lastSeen`.
3. Печать — `/typing/{chatId}/{uid}` появляется и исчезает.

### 9.4. Входящий звонок

1. `calls/{id}` со статусом `ringing`.
2. Лог `onCallCreated`.
3. На устройстве получателя — data-push FCM.

---

## 10. Практика для команды

| Этап | Чем пользоваться |
| --- | --- |
| MVP, отладка чатов и auth | Firestore Data + Auth Users + RTDB Data |
| `lastMessage` / `unreadCount` / FCM | Functions Logs |
| Экраны в реальном времени | `snapshots()` / `onValue` в DataSource |
| Локальная разработка без квоты | Emulator UI (`localhost:4000`) |
| Воронки продукта (фаза 7) | Analytics + DebugView |
| Падения | Crashlytics |
| «Кто изменил документ» | Audit Logs (редко) |

Не подключайте Analytics, чтобы понять, почему не создался документ. Сначала Console Data и логи функции.

---

## 11. Типичные ошибки

| Симптом | Что проверить |
| --- | --- |
| В приложении сообщение есть, в Console нет | Другой Firebase project; смотрите `firebase_options.dart` |
| Документ в `messages` есть, `lastMessage` пустой | Functions Logs; деплой; путь триггера `chats/{chatId}/messages/{messageId}` |
| `PERMISSION_DENIED` | [firestore.rules](./firebase-setup.md); пользователь авторизован |
| `snapshots()` молчит | Индекс; `arrayContains` + `orderBy`; rules на read |
| Analytics пустой в Events | Задержка часов; для проверки — DebugView |
| DebugView пустой | Не включён debug на устройстве (`adb setprop` / `-FIRDebugEnabled`) |
| Functions Logs пустые | Функция не задеплоена; Spark plan без Blaze; событие не попало в путь триггера |
| RTDB не меняется | Rules `/status`, `/typing`; клиент пишет не тот путь |

---

## Связанные документы

- [firebase-setup.md](./firebase-setup.md) — Auth, Firestore, Functions, чеклист проверки
- [firebase-database.md](./firebase-database.md) — коллекции, триггеры Functions
- [firebase-flutter-connect.md](./firebase-flutter-connect.md) — инициализация SDK
- [architecture.md](./architecture.md) — DataSource, стримы, без Firebase в UI
- [roadmap.md](./roadmap.md) — Analytics / Crashlytics в фазе 7

Официально:

- [Firestore listen](https://firebase.google.com/docs/firestore/query-data/listen)
- [Cloud Functions logging](https://firebase.google.com/docs/functions/writing-and-viewing-logs)
- [Analytics DebugView](https://firebase.google.com/docs/analytics/debugview)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
