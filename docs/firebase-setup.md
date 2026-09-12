# Настройка Firebase для E-Chat

Пошаговая инструкция по настройке сервисов Firebase для **flutter_echat** в соответствии со [структурой базы данных](./firebase-database.md).

> **Подключение Flutter.** Если Firebase ещё не связан с приложением, начните с [firebase-flutter-connect.md](./firebase-flutter-connect.md).  
> **События.** Как отслеживать записи в Firestore, логи Functions и Analytics: [firebase-events.md](./firebase-events.md).

---

## Содержание

1. [Что нужно включить](#1-что-нужно-включить)
2. [Создание проекта в Console](#2-создание-проекта-в-console)
3. [Инструменты на компьютере](#3-инструменты-на-компьютере)
4. [Подключение Flutter-приложения](#4-подключение-flutter-приложения)
5. [Зависимости Dart](#5-зависимости-dart)
6. [Инициализация в коде](#6-инициализация-в-коде)
7. [Authentication (телефон + OTP)](#7-authentication-телефон--otp)
8. [Cloud Firestore](#8-cloud-firestore)
9. [Realtime Database](#9-realtime-database)
10. [Cloud Storage](#10-cloud-storage)
11. [Cloud Messaging (FCM)](#11-cloud-messaging-fcm)
12. [Cloud Functions](#12-cloud-functions)
13. [Проверка после настройки](#13-проверка-после-настройки)
14. [Типичные ошибки](#14-типичные-ошибки)
15. [Отслеживание событий](#15-отслеживание-событий)

---

## 1. Что нужно включить

| Сервис Firebase | Зачем (по схеме E-Chat) |
| --- | --- |
| **Authentication** | Login / Register по номеру телефона и OTP |
| **Cloud Firestore** | `users`, `chats`, `messages`, `calls`, `contacts`, … |
| **Realtime Database** | Online / last seen, индикатор «печатает» |
| **Cloud Storage** | Аватары, фото, видео, голосовые, файлы, фоны чатов |
| **Cloud Messaging** | Push-уведомления (сообщения, звонки) |
| **Cloud Functions** | `lastMessage`, `unreadCount`, FCM, профиль при регистрации |

Billing (Blaze plan) понадобится для **Cloud Functions** и исходящих SMS OTP в production. Для разработки OTP можно тестировать через [тестовые номера](https://firebase.google.com/docs/auth/android/phone-auth#test-with-whitelisted-phone-numbers) на бесплатном плане Spark.

---

## 2. Создание проекта в Console

1. Откройте [Firebase Console](https://console.firebase.google.com/).
2. **Add project** → имя, например `echat-flutter`.
3. При желании включите Google Analytics (не обязательно для MVP).
4. После создания проекта добавьте приложения:

| Платформа | Package / Bundle ID |
| --- | --- |
| Android | `com.example.flutter_echat` (см. `android/app/build.gradle.kts`) |
| iOS | `com.example.flutterEchat` (замените на свой при публикации) |
| Web | опционально |

5. Скачайте конфиги (их позже создаст FlutterFire CLI автоматически):
   - Android: `google-services.json`
   - iOS: `GoogleService-Info.plist`

> **Важно.** Файлы с ключами не коммитьте в публичный репозиторий, если проект открытый. Добавьте их в `.gitignore` или используйте CI-секреты.

---

## 3. Инструменты на компьютере

Установите CLI и войдите в Google-аккаунт:

```bash
# Node.js LTS нужен для Firebase CLI
npm install -g firebase-tools

# FlutterFire CLI
dart pub global activate flutterfire_cli

# Проверка
firebase --version
flutterfire --version
```

Войдите в Firebase:

```bash
firebase login
```

В корне проекта `flutter_echat`:

```bash
cd d:\MyPrograms\flutter_echat
firebase login
```

---

## 4. Подключение Flutter-приложения

Из корня репозитория выполните:

```bash
flutterfire configure
```

CLI спросит:

- Firebase project — выберите созданный `echat-flutter`
- Platforms — отметьте **android**, **ios** (и **web**, если нужен)

Будут созданы/обновлены:

- `lib/firebase_options.dart` — ключи для `Firebase.initializeApp`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `firebase.json` — конфиг деплоя rules и functions

Добавьте плагин Google Services в Android. В `android/settings.gradle.kts` (если ещё нет):

```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

В `android/app/build.gradle.kts`:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}
```

Для **phone auth** на Android поднимите `minSdk` минимум до **23** в `android/app/build.gradle.kts`:

```kotlin
defaultConfig {
    minSdk = 23
    // ...
}
```

---

## 5. Зависимости Dart

Добавьте в `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.13.0
  firebase_auth: ^5.5.2
  cloud_firestore: ^5.6.6
  firebase_database: ^11.3.4
  firebase_storage: ^12.4.4
  firebase_messaging: ^15.2.4
```

Установка:

```bash
flutter pub get
```

Дополнительно для MVP (локальные настройки из макета):

```yaml
  shared_preferences: ^2.5.3
  flutter_secure_storage: ^9.2.4
```

---

## 6. Инициализация в коде

`lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

Рекомендуемая структура папок (по мере разработки):

```
lib/
  firebase/
    firestore_paths.dart      # константы коллекций
    auth_service.dart
    chat_repository.dart
  models/
  features/
```

Пример констант путей (`lib/firebase/firestore_paths.dart`):

```dart
abstract final class FirestorePaths {
  static const users = 'users';
  static const userSettings = 'userSettings';
  static const contacts = 'contacts';
  static const blocks = 'blocks';
  static const chats = 'chats';
  static const calls = 'calls';
  static const notifications = 'notifications';
  static const reports = 'reports';

  static String chatMembers(String chatId) => 'chats/$chatId/members';
  static String chatMessages(String chatId) => 'chats/$chatId/messages';
  static String userDevices(String userId) => 'users/$userId/devices';

  /// Личный чат: отсортированные UID через '_'
  static String directChatId(String uidA, String uidB) {
    final ids = [uidA, uidB]..sort();
    return ids.join('_');
  }
}
```

---

## 7. Authentication (телефон + OTP)

### 7.1. Console

1. **Build → Authentication → Sign-in method**
2. Включите **Phone**
3. Для тестов: **Phone numbers for testing** — добавьте номер и фиксированный код (например `+44 7911 123456` / `123456`)

### 7.2. Android — SHA-1 / SHA-256

Phone Auth на Android требует отпечатки сертификата:

```bash
cd android
./gradlew signingReport
```

Скопируйте **SHA-1** и **SHA-256** debug (и release для prod) в  
**Project settings → Your apps → Android → Add fingerprint**.

### 7.3. iOS

1. В Xcode включите **Push Notifications** capability (нужно для silent push при верификации номера).
2. Загрузите **APNs key** в Firebase: **Project settings → Cloud Messaging → Apple app configuration**.

### 7.4. Поток в приложении (соответствие экранам Figma)

```
Login _ Empty / Sign Up _ Empty
    → verifyPhoneNumber(phone)
Login _ OTP * / Sign Up _ OTP *
    → signInWithCredential(PhoneAuthProvider.credential)
Sign Up _ User Information
    → создать документ users/{uid} + userSettings/{uid}
Set Face ID / Touch ID / PIN
    → только локально + флаги faceIdEnabled, pinEnabled в users
```

Пример отправки OTP:

```dart
await FirebaseAuth.instance.verifyPhoneNumber(
  phoneNumber: '$phoneCountryCode$nationalNumber',
  verificationCompleted: (credential) async {
    await FirebaseAuth.instance.signInWithCredential(credential);
  },
  verificationFailed: (e) {
    // UI: Code Invalid
  },
  codeSent: (verificationId, forceResendingToken) {
    // UI: Enter OTP Code, Resend Code
  },
  codeAutoRetrievalTimeout: (verificationId) {},
);
```

После первого входа создайте профиль (поля — см. [firebase-database.md §5.1](./firebase-database.md#51-usersuserid)):

```dart
await FirebaseFirestore.instance.collection('users').doc(uid).set({
  'id': uid,
  'displayName': name,
  'phone': fullPhone,
  'phoneCountryCode': countryCode,
  'eChatPublicId': 'ECHAT-${uid.substring(0, 6).toUpperCase()}',
  'photoUrl': null,
  'about': 'Hey there! I am using E-Chat',
  'searchTokens': [],
  'isOnline': false,
  'lastSeenAt': FieldValue.serverTimestamp(),
  'showLastSeen': true,
  'showOnline': true,
  'showReadReceipts': true,
  'allowCallsFrom': 'everyone',
  'pinEnabled': false,
  'faceIdEnabled': false,
  'touchIdEnabled': false,
  'isBanned': false,
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
});
```

Документ `userSettings/{uid}` лучше создавать **Cloud Function** при регистрации (см. §12), либо с клиента с теми же дефолтами, что в [§5.2](./firebase-database.md#52-usersettingsuserid).

---

## 8. Cloud Firestore

### 8.1. Создание базы

1. **Build → Firestore Database → Create database**
2. Режим: **Production** (rules зададите ниже)
3. Регион: выберите ближайший пользователям (например `europe-west1`).  
   **Realtime Database** и **Firestore** могут быть в разных регионах, но для latency лучше один регион.

### 8.2. Структура коллекций

Соответствует [§4 firebase-database.md](./firebase-database.md#4-дерево-коллекций-firestore).  
Firestore **не требует** предварительного создания коллекций — они появятся при первой записи.

| Коллекция | Когда создаётся |
| --- | --- |
| `users` | После Sign Up _ User Information |
| `userSettings` | При регистрации (Function или клиент) |
| `chats` + `members` | Первое сообщение / Create Group |
| `messages` | Отправка сообщения в чате |
| `contacts` | Add Friend |
| `calls` | Начало звонка |
| `blocks`, `reports` | Block / Report в User Information |
| `notifications` | Cloud Function при событиях |

### 8.3. Правила безопасности

Создайте в корне проекта папку `firebase/` и файл `firestore.rules`:

```
firebase/
  firestore.rules
  firestore.indexes.json
  database.rules.json
  storage.rules
```

`firebase/firestore.rules` (стартовая версия под E-Chat):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    function isChatMember(chatId) {
      return isSignedIn()
        && exists(/databases/$(database)/documents/chats/$(chatId)/members/$(request.auth.uid))
        && get(/databases/$(database)/documents/chats/$(chatId)/members/$(request.auth.uid)).data.isActive == true;
    }

    match /users/{userId} {
      allow read: if isSignedIn();
      allow create, update: if isOwner(userId);
      allow delete: if isOwner(userId);

      match /devices/{deviceId} {
        allow read, write: if isOwner(userId);
      }
    }

    match /userSettings/{userId} {
      allow read, write: if isOwner(userId);
    }

    match /contacts/{contactId} {
      allow read, write: if isSignedIn()
        && resource == null
          ? request.resource.data.ownerId == request.auth.uid
          : resource.data.ownerId == request.auth.uid;
    }

    match /blocks/{blockId} {
      allow read: if isSignedIn()
        && (resource.data.blockerId == request.auth.uid
            || resource.data.blockedId == request.auth.uid);
      allow create: if isSignedIn()
        && request.resource.data.blockerId == request.auth.uid;
      allow delete: if isSignedIn()
        && resource.data.blockerId == request.auth.uid;
    }

    match /chats/{chatId} {
      allow read: if isSignedIn()
        && request.auth.uid in resource.data.participantIds;
      allow create: if isSignedIn()
        && request.auth.uid in request.resource.data.participantIds;
      // lastMessage / unreadCount — только через Cloud Functions
      allow update: if isSignedIn()
        && request.auth.uid in resource.data.participantIds
        && !request.resource.data.diff(resource.data).affectedKeys()
            .hasAny(['lastMessage', 'lastMessageAt']);

      match /members/{memberId} {
        allow read: if isChatMember(chatId);
        allow create: if isSignedIn(); // ужесточите: только admin/owner группы
        allow update: if isOwner(memberId)
          && !request.resource.data.diff(resource.data).affectedKeys()
              .hasAny(['unreadCount']);
      }

      match /messages/{messageId} {
        allow read: if isChatMember(chatId);
        allow create: if isChatMember(chatId)
          && request.resource.data.senderId == request.auth.uid;
        allow update: if isChatMember(chatId)
          && (resource.data.senderId == request.auth.uid
              || request.resource.data.diff(resource.data).affectedKeys()
                  .hasOnly(['readBy', 'deliveredTo', 'status']));
        allow delete: if isChatMember(chatId)
          && resource.data.senderId == request.auth.uid;
      }
    }

    match /calls/{callId} {
      allow read, write: if isSignedIn()
        && request.auth.uid in request.resource.data.participantIds;
    }

    match /notifications/{notificationId} {
      allow read, update: if isSignedIn()
        && resource.data.userId == request.auth.uid;
      allow create: if false; // только Cloud Functions
    }

    match /reports/{reportId} {
      allow create: if isSignedIn()
        && request.resource.data.reporterId == request.auth.uid;
      allow read: if false;
    }
  }
}
```

Деплой правил:

```bash
firebase deploy --only firestore:rules
```

### 8.4. Индексы

`firebase/firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "chats",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "participantIds", "arrayConfig": "CONTAINS" },
        { "fieldPath": "lastMessageAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "messages",
      "queryScope": "COLLECTION_GROUP",
      "fields": [
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "calls",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "participantIds", "arrayConfig": "CONTAINS" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "notifications",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "contacts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ownerId", "order": "ASCENDING" },
        { "fieldPath": "isFavorite", "order": "DESCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "usernameLower", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "phone", "order": "ASCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

Деплой:

```bash
firebase deploy --only firestore:indexes
```

> При первом запросе без индекса Firestore покажет ссылку для автосоздания — можно создать и через Console.

### 8.5. Типовые запросы приложения

**Список чатов (Chats / Groups):**

```dart
FirebaseFirestore.instance
    .collection('chats')
    .where('participantIds', arrayContains: uid)
    .orderBy('lastMessageAt', descending: true);
```

**Лента сообщений:**

```dart
FirebaseFirestore.instance
    .collection('chats')
    .doc(chatId)
    .collection('messages')
    .orderBy('createdAt', descending: true)
    .limit(40);
```

**Media, Links & Documents** — фильтр по `type`:

```dart
.where('type', whereIn: ['image', 'video', 'file', 'link'])
```

**Add Friend (поиск по телефону):**

```dart
FirebaseFirestore.instance
    .collection('users')
    .where('phone', isEqualTo: normalizedPhone)
    .limit(1);
```

---

## 9. Realtime Database

### 9.1. Создание

1. **Build → Realtime Database → Create Database**
2. Режим: **Locked** (rules ниже)
3. Регион — по возможности тот же, что Firestore

### 9.2. Правила

`firebase/database.rules.json`:

```json
{
  "rules": {
    "status": {
      "$userId": {
        ".read": "auth != null",
        ".write": "auth != null && auth.uid == $userId"
      }
    },
    "typing": {
      "$chatId": {
        "$userId": {
          ".read": "auth != null",
          ".write": "auth != null && auth.uid == $userId"
        }
      }
    }
  }
}
```

Деплой:

```bash
firebase deploy --only database
```

### 9.3. Использование в Flutter

```dart
import 'package:firebase_database/firebase_database.dart';

final statusRef = FirebaseDatabase.instance.ref('status/$uid');

// Online
await statusRef.set({
  'state': 'online',
  'lastSeenAt': ServerValue.timestamp,
  'platform': 'android',
});
await statusRef.onDisconnect().set({
  'state': 'offline',
  'lastSeenAt': ServerValue.timestamp,
});

// Typing
final typingRef = FirebaseDatabase.instance.ref('typing/$chatId/$uid');
await typingRef.set({
  'isTyping': true,
  'updatedAt': ServerValue.timestamp,
});
// Сбросить через 3–5 сек или onDispose
await typingRef.remove();
```

Периодически синхронизируйте `users.isOnline` / `users.lastSeenAt` в Firestore (клиентом или Function), если нужен офлайн-список без подписки на RTDB для каждого контакта.

---

## 10. Cloud Storage

### 10.1. Включение

**Build → Storage → Get started** → выберите регион.

### 10.2. Структура путей

См. [firebase-database.md §7](./firebase-database.md#7-cloud-storage):

```
avatars/{userId}/avatar.jpg
chats/{chatId}/images/{messageId}.jpg
chats/{chatId}/voice/{messageId}.m4a
chatBackgrounds/{userId}/{chatId}/bg.jpg
```

### 10.3. Правила

`firebase/storage.rules`:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    function isSignedIn() {
      return request.auth != null;
    }

    match /avatars/{userId}/{fileName} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && request.auth.uid == userId
        && request.resource.size < 5 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }

    match /chats/{chatId}/{type}/{fileName} {
      allow read, write: if isSignedIn();
      // Ужесточите: проверка membership через Firestore custom claim или metadata
    }

    match /chatBackgrounds/{userId}/{chatId}/{fileName} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && request.auth.uid == userId;
    }
  }
}
```

Деплой:

```bash
firebase deploy --only storage
```

### 10.4. Загрузка аватара (Sign Up _ User Information)

```dart
final ref = FirebaseStorage.instance
    .ref('avatars/$uid/avatar.jpg');
await ref.putFile(file);
final url = await ref.getDownloadURL();
await FirebaseFirestore.instance.collection('users').doc(uid).update({
  'photoUrl': url,
  'updatedAt': FieldValue.serverTimestamp(),
});
```

---

## 11. Cloud Messaging (FCM)

### 11.1. Console

FCM включается автоматически с проектом. Для iOS загрузите APNs key (см. §7.3).

### 11.2. Android

В `android/app/src/main/AndroidManifest.xml` внутри `<application>`:

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="echat_messages" />
```

Создайте канал уведомлений в Kotlin/Java или через `flutter_local_notifications` — для экрана **Setting _ Notification**.

### 11.3. Flutter — токен устройства

Сохраняйте FCM-токен в `users/{uid}/devices/{deviceId}` (см. схему):

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

final token = await FirebaseMessaging.instance.getToken();
if (token != null && uid != null) {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('devices')
      .doc(token.substring(0, 32))
      .set({
    'fcmToken': token,
    'platform': 'android',
    'appVersion': '2.1.0',
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  // обновить devices/{deviceId}
});
```

Push о новых сообщениях и звонках отправляйте из **Cloud Functions** (клиент не должен писать в `notifications` — см. rules).

---

## 12. Cloud Functions

### 12.1. Инициализация

```bash
firebase init functions
```

- Language: **TypeScript** (рекомендуется) или JavaScript
- ESLint: по желанию
- Install dependencies: Yes

Папка: `functions/`.

### 12.2. Минимальный набор функций

| Функция | Триггер | Задача |
| --- | --- | --- |
| `onUserCreated` | Auth `onCreate` | `userSettings`, `eChatPublicId`, searchTokens |
| `onMessageCreated` | Firestore `chats/{id}/messages/{id}` onCreate | `lastMessage`, `unreadCount`, FCM |
| `onCallCreated` | `calls/{id}` onCreate | FCM «входящий звонок» |

Пример `functions/src/index.ts` (упрощённо):

```typescript
import * as admin from 'firebase-admin';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { beforeUserCreated } from 'firebase-functions/v2/identity';

admin.initializeApp();

export const createUserSettings = beforeUserCreated(async (event) => {
  const uid = event.data.uid;
  const db = admin.firestore();
  await db.collection('userSettings').doc(uid).set({
    theme: 'system',
    language: 'en',
    notificationsEnabled: true,
    messageNotifications: true,
    groupNotifications: true,
    callNotifications: true,
    notificationSound: 'default',
    notificationPreview: true,
    enterIsSend: false,
    mediaAutoDownloadWifi: true,
    mediaAutoDownloadMobile: false,
    fontScale: 1.0,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
});

export const onChatMessageCreated = onDocumentCreated(
  'chats/{chatId}/messages/{messageId}',
  async (event) => {
    const message = event.data?.data();
    const chatId = event.params.chatId;
    if (!message) return;

    const chatRef = admin.firestore().collection('chats').doc(chatId);
    await chatRef.update({
      lastMessage: {
        id: event.params.messageId,
        senderId: message.senderId,
        type: message.type,
        text: message.text ?? null,
        preview: message.text ?? message.type,
      },
      lastMessageAt: message.createdAt,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // TODO: increment unreadCount для members, отправить FCM
  },
);
```

Деплой:

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

> Для `beforeUserCreated` нужен Blaze plan и включённый **Identity Platform** / блокирующие функции Auth — альтернатива: триггер `onCreate` документа `users/{uid}` с клиента.

---

## 13. Проверка после настройки

Чеклист:

- [ ] `flutter run` — приложение стартует без ошибки `Firebase.initializeApp`
- [ ] Phone Auth: тестовый номер → OTP → пользователь в **Authentication**
- [ ] После регистрации есть документы `users/{uid}` и `userSettings/{uid}`
- [ ] Создание личного чата: `chatId = sorted(uids).join('_')`
- [ ] Отправка сообщения → документ в `messages`, обновление `chats.lastMessage`
- [ ] RTDB: `/status/{uid}` меняется online/offline
- [ ] Storage: загрузка аватара → URL в `users.photoUrl`
- [ ] FCM: токен в `users/{uid}/devices/...`
- [ ] Rules: неавторизованный клиент не читает чужие чаты

Быстрая проверка Firestore из Console: **Firestore → Data** — должны появиться коллекции после действий в приложении.

Как смотреть каждое действие (сообщение, OTP, typing, логи функций) — [firebase-events.md](./firebase-events.md).

---

## 14. Типичные ошибки

| Симптом | Решение |
| --- | --- |
| `API key not valid` | Перезапустите `flutterfire configure`, проверьте `google-services.json` |
| Phone Auth `invalid-app-credential` | Добавьте SHA-1/SHA-256 в Firebase Console |
| `PERMISSION_DENIED` в Firestore | Проверьте `firestore.rules`, авторизован ли пользователь |
| Запрос чатов без индекса | Выполните `firebase deploy --only firestore:indexes` |
| iOS OTP не приходит | APNs key, Push capability, реальное устройство (не все симуляторы) |
| `unreadCount` не обновляется | Реализуйте Cloud Function; клиент не может писать поле (rules) |
| Storage upload denied | Проверьте `storage.rules` и размер/тип файла |

---

## 15. Отслеживание событий

После настройки сервисов проверка идёт не только чеклистом выше. Полный разбор: Console (Firestore / Auth / RTDB / Storage), логи Cloud Functions, `snapshots()` в DataSource, Analytics, эмулятор — [firebase-events.md](./firebase-events.md).

---

## Связанные документы

- [Структура базы данных E-Chat](./firebase-database.md) — поля коллекций, индексы, MVP
- [Отслеживание событий Firebase](./firebase-events.md) — Console, Functions Logs, Analytics
- [Подключение Flutter](./firebase-flutter-connect.md) — `flutterfire configure`, `main.dart`
- [FlutterFire documentation](https://firebase.google.com/docs/flutter/setup)
- [Phone Auth Flutter](https://firebase.google.com/docs/auth/flutter/phone-auth)

---

## Рекомендуемый порядок работ

1. `flutterfire configure` + зависимости + `main.dart`
2. Phone Auth + создание `users` / `userSettings`
3. Firestore rules + indexes
4. Чаты и сообщения (MVP Chats / Groups)
5. RTDB presence + typing
6. Storage для медиа
7. FCM + Cloud Functions
8. Calls, blocks, reports

После шага 4 уже можно собирать экраны **Chats** и **Chats _ Conversation** из Figma на реальных данных.
