# Регистрация в Firebase (E-Chat)

Пошаговая реализация **Sign Up** по макету Figma: профиль в Firestore. Соответствует слоям [architecture_echat.md](./architecture_echat.md) и схеме [firebase-database.md](./firebase-database.md).

> **Предусловия.** Проект уже подключён ([firebase-flutter-connect.md](./firebase-flutter-connect.md)), в Console включён Auth ([firebase-setup.md §7](./firebase-setup.md#7-authentication)).

---

## Содержание

1. [Что делает регистрация](#1-что-делает-регистрация)
2. [Поток экранов → Firebase](#2-поток-экранов--firebase)
3. [Настройка Console](#3-настройка-console)
4. [Domain](#4-domain)
5. [Data — AuthRemoteDataSource](#5-data--authremotedatasource)
6. [Data — профиль users / userSettings](#6-data--профиль-users--usersettings)
7. [Repository](#7-repository)
8. [Presentation](#8-presentation)
9. [Auth guard (go_router)](#9-auth-guard-go_router)
10. [Cloud Function (опционально)](#10-cloud-function-опционально)
11. [Проверка](#11-проверка)
12. [Типичные ошибки](#12-типичные-ошибки)

---

## 1. Что делает регистрация

| Шаг | Firebase | Результат |
| --- | --- | --- |
| Register | `createUserWithEmailAndPassword` | Пользователь в **Authentication → Users** |
| User Information | Firestore `users/{uid}` | Профиль (имя, email, eChatPublicId, …) |
| Дефолты настроек | Firestore `userSettings/{uid}` | Тема, уведомления (клиент или Function) |

SDK Auth / Firestore вызываются **только** в DataSource (`features/auth/data/`), не в `presentation/`.

---

## 2. Поток экранов → Firebase

```
/register  (Name, Email, Password, Terms)
    → AuthRepository.register(email, password)
    → Firebase Auth: currentUser != null
    → если профиля нет → /signup/profile
    → если профиль есть → /chats (или shell)

/signup/profile  (User Information: имя, аватар)
    → UserRepository.createProfile(...)
    → Firestore: users/{uid}
    → userSettings/{uid} (клиент или Cloud Function)
    → /security  или Home
```

Login использует тот же Auth; отличие Register — после регистрации обязателен экран профиля, если документа `users/{uid}` ещё нет.

---

## 3. Настройка Console

1. **Authentication → Sign-in method** — включить Email/Password.
2. Firestore создан; rules разрешают `users/{uid}` write только своему `auth.uid` (см. setup §8.3).


---

## 4. Domain

Файлы: `features/auth/domain/`.

### 4.1. Entities

```dart
// phone_auth_session.dart
@freezed
abstract class PhoneAuthSession with _$PhoneAuthSession {
  const factory PhoneAuthSession({
    required String verificationId,
    int? forceResendingToken,
  }) = _PhoneAuthSession;
}
```

```dart
// auth_user.dart
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String uid,
    String? phoneNumber,
  }) = _AuthUser;
}
```

### 4.2. AuthRepository (interface)

```dart
// auth_repository.dart
abstract class AuthRepository {
  /// Регистрация.
  Future<Either<Failure, AuthUser>> register({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthUser>> login({
    required String email,
    required String password,
  });

  Stream<Option<AuthUser>> watchAuthState();

  Future<Either<Failure, Unit>> signOut();
}
```

Ошибки — только `Failure` (например `Failure.auth(...)`), не `String`. Маппинг `FirebaseAuthException.code` → `AuthFailureReason` в data-слое.

---

## 5. Data — AuthRemoteDataSource

Файл: `features/auth/data/datasources/auth_remote_datasource.dart`.

`verifyPhoneNumber` асинхронный с несколькими колбэками — удобно обернуть в `Completer` / `TaskEither`:

```dart
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._auth);

  final FirebaseAuth _auth;

  Future<UserCredential> register(String email, String password) async {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> login(String email, String password) async {
    return _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
```

В repository обернуть в `TaskEither.tryCatch` и смапить исключения:

| `FirebaseAuthException.code` | UI / Failure |
| --- | --- |
| `wrong-password` | Неверный пароль |
| `user-not-found` | Пользователь не найден |
| `network-request-failed` | Нет сети |

Эмулятор Auth (опционально, debug):

```dart
await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
```

---

## 6. Data — профиль users / userSettings

Файл: `features/auth/data/datasources/user_remote_datasource.dart` (или отдельный feature `profile`).

После регистрации пользователь уже авторизован (`auth.uid`). Создание профиля — экран **User Information**, не кнопка Register:

```dart
Future<void> createUserProfile({
  required String uid,
  required String displayName,
  required String phoneE164,
  required String phoneCountryCode,
  String? photoUrl,
}) async {
  final publicId =
      'ECHAT-${uid.substring(0, 6).toUpperCase()}';

  await FirebaseFirestore.instance.collection('users').doc(uid).set({
    'id': uid,
    'displayName': displayName,
    'phone': phoneE164,
    'phoneCountryCode': phoneCountryCode,
    'eChatPublicId': publicId,
    'photoUrl': photoUrl,
    'about': 'Hey there! I am using E-Chat',
    'searchTokens': _buildSearchTokens(displayName, phoneE164),
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
}
```

Поля — [firebase-database.md §5.1](./firebase-database.md#51-usersuserid).

`userSettings/{uid}` — дефолты из [§5.2](./firebase-database.md#52-usersettingsuserid). Предпочтительно Cloud Function при создании Auth-пользователя ([firebase-setup.md §12](./firebase-setup.md#12-cloud-functions)); на MVP допустимо `set` с клиента сразу после `users/{uid}`.

Проверка «профиль уже есть» для redirect:

```dart
Future<bool> profileExists(String uid) async {
  final snap =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return snap.exists;
}
```

Аватар: Storage `avatars/{uid}/...` → URL в `photoUrl` (после базовой регистрации).

---

## 7. Repository

`AuthRepositoryImpl` / `UserRepositoryImpl`:

- вызывают DataSource;
- возвращают `Either<Failure, T>`;
- **не** импортируют Flutter widgets;
- DTO → Entity при чтении профиля.

Пример Register:

```dart
@override
Future<Either<Failure, AuthUser>> register({
  required String email,
  required String password,
}) {
  return TaskEither.tryCatch(
    () async {
      final cred = await _authDs.register(email, password);
      final user = cred.user;
      if (user == null) {
        throw StateError('null user after signIn');
      }
      return AuthUser(uid: user.uid, phoneNumber: user.phoneNumber);
    },
    (e, _) => _mapAuthFailure(e),
  ).run();
}
```

Провайдер:

```dart
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    authDs: ref.watch(authRemoteDataSourceProvider),
  );
}
```

---

## 8. Presentation

UI smart/dumb — [architecture_echat.md §3.5](./architecture_echat.md#35-пример-страница-регистрации-auth--register). Ниже — связь с Firebase.

### 8.1. Register

`RegisterController.submit()`:

1. Валидация имени, email, пароля, Terms.
2. `authRepository.register(email, password)`.
3. Ошибка → `state.copyWith(error: failure)`.

Имя с Register можно прокинуть на User Information.

### 8.2. User Information

`UserInfoController.save()`:

1. Опционально upload аватара в Storage.
2. `userRepository.createProfile(...)`.
3. При необходимости `createUserSettings`.
4. `go` на security setup или `/chats`.

Dumb-views не знают о Firebase и Riverpod — только props + callbacks.

---

## 9. Auth guard (go_router)

```dart
redirect: (context, state) {
  final user = /* ref.read(currentUserProvider) */;
  final loggingIn = state.matchedLocation == '/login'
      || state.matchedLocation == '/register';

  if (user == null && !loggingIn) return '/login';
  if (user != null && loggingIn) {
    // есть auth, нет профиля → /signup/profile
    return null; // или явный путь после проверки профиля
  }
  return null;
},
```

Источник истины: `FirebaseAuth.authStateChanges()` → `@riverpod` `currentUserProvider` (`Option<AuthUser>` / `AsyncValue`). Подписка на Firestore-профиль — отдельно, чтобы отличить «вошёл, но не дозаполнил User Information».

---

## 10. Cloud Function (опционально)

При создании пользователя Auth создать `userSettings` (и при желании дописать `eChatPublicId` / `searchTokens`). Пример — [firebase-setup.md §12.2](./firebase-setup.md#122-минимальный-набор-функций).

На Spark без Identity Platform: создавать `userSettings` с клиента в том же `createProfile`.

---

## 11. Проверка

| Шаг | Где смотреть |
| --- | --- |
| Авторизация пройдена | **Authentication → Users** |
| Профиль | **Firestore → Data** → `users/{uid}` |
| Настройки | `userSettings/{uid}` |
| Лог Function | **Functions → Logs** (`createUserSettings` / `onUserCreated`) |

Полный сценарий: [firebase-events.md §9.2](./firebase-events.md#92-регистрация).

Чеклист:

- [ ] Тестовый номер → код → пользователь в Auth
- [ ] Повторный вход тем же номером не дублирует Auth user
- [ ] После User Information есть `users/{uid}` с `displayName`, `phone`, `eChatPublicId`
- [ ] Без auth запись в `users` даёт `PERMISSION_DENIED`
- [ ] Guard: выход → `/login`; вход без профиля → `/signup/profile`

---

## 12. Типичные ошибки

| Симптом | Причина / решение |
| --- | --- |
| `invalid-app-credential` | Нет SHA-1/SHA-256 в Console |
| Слишком много попыток | Подождать или очистить квоту |
| `PERMISSION_DENIED` на `users` | Rules или запись до `signInWithCredential` |
## 12. Типичные ошибки

| Ошибка / Симптом | Решение |
| --- | --- |
| `wrong-password` | Пароль введен неверно |
| `email-already-in-use` | Email уже занят |
| Два пользователя на один email | Не должно: Auth уникален; проверьте другой проект/эмулятор |
| Профиль не создаётся | Ошибка только в UI: смотрите Firestore rules и `createUserProfile` |

---

## Связанные документы

- [firebase-setup.md](./firebase-setup.md) — включение Auth, rules, Functions
- [firebase-database.md](./firebase-database.md) — поля `users`, `userSettings`
- [firebase-events.md](./firebase-events.md) — отладка регистрации в Console
- [firebase-flutter-connect.md](./firebase-flutter-connect.md) — SDK и `main.dart`
- [architecture_echat.md](./architecture_echat.md) — smart/dumb Register, Failure, слои
- [roadmap.md](./roadmap.md) — фаза 2 Auth & Onboarding

---

## Порядок внедрения в коде

1. Domain: `AuthUser`, `AuthRepository`, `Failure.auth`
2. Data: `AuthRemoteDataSource` + `AuthRepositoryImpl` + providers
3. UI: Register (без Firestore)
4. Data: `UserRemoteDataSource.createUserProfile` + экран User Information
5. `userSettings` (клиент или Function)
6. `redirect` в `GoRouter` + `currentUserProvider`
7. Security (PIN / Face ID) — локально, флаги в `users`
