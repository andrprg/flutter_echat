# Подключение Firebase к Flutter (flutter_echat)

Краткая инструкция: как связать проект **flutter_echat** с Firebase на стороне Flutter и нативных платформ.

После подключения переходите к полной настройке сервисов E-Chat: [firebase-setup.md](./firebase-setup.md).  
Схема данных: [firebase-database.md](./firebase-database.md).  
Как смотреть события в Console и в приложении: [firebase-events.md](./firebase-events.md).

---

## Содержание

1. [Что понадобится](#1-что-понадобится)
2. [Проект в Firebase Console](#2-проект-в-firebase-console)
3. [Установка FlutterFire CLI](#3-установка-flutterfire-cli)
4. [Команда flutterfire configure](#4-команда-flutterfire-configure)
5. [Пакеты в pubspec.yaml](#5-пакеты-в-pubspecyaml)
6. [Настройка Android](#6-настройка-android)
7. [Настройка iOS](#7-настройка-ios)
8. [Настройка Web (опционально)](#8-настройка-web-опционально)
9. [Инициализация в main.dart](#9-инициализация-в-maindart)
10. [Проверка подключения](#10-проверка-подключения)
11. [Что дальше](#11-что-дальше)
12. [Частые проблемы](#12-частые-проблемы)

---

## 1. Что понадобится

| Требование | Примечание |
| --- | --- |
| Flutter SDK | Проверка: `flutter doctor` |
| Node.js LTS | Для Firebase CLI (опционально на первом шаге) |
| Аккаунт Google | [Firebase Console](https://console.firebase.google.com/) |
| Android Studio / Xcode | Для эмулятора или реального устройства |

Текущий идентификатор Android-приложения в проекте:

```
com.example.flutter_echat
```

Файл: `android/app/build.gradle.kts` → `applicationId`.

---

## 2. Проект в Firebase Console

1. [Firebase Console](https://console.firebase.google.com/) → **Создать проект** (или выберите существующий).
2. **Добавить приложение** → **Android**:
   - Имя пакета: `com.example.flutter_echat`
   - Псевдоним: `flutter_echat` (любой)
   - SHA-1 для debug можно добавить позже (нужен для Phone Auth)
3. **Добавить приложение** → **iOS** (если собираете под iPhone):
   - Bundle ID: укажите тот, что в Xcode (по умолчанию часто `com.example.flutterEchat`)
4. Конфиги `google-services.json` и `GoogleService-Info.plist` **скачивать вручную не обязательно** — их создаст `flutterfire configure`.

---

## 3. Установка FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Убедитесь, что `%USERPROFILE%\AppData\Local\Pub\Cache\bin` (Windows) есть в `PATH`, иначе команда `flutterfire` не найдётся.

Проверка:

```bash
flutterfire --version
```

Опционально — Firebase CLI (для rules, functions):

```bash
npm install -g firebase-tools
firebase login
```

---

## 4. Команда flutterfire configure

В корне проекта:

```bash
cd d:\MyPrograms\flutter_echat
flutterfire configure
```

Интерактивно:

1. Выберите Firebase-проект из списка.
2. Отметьте платформы: **android**, **ios** (и **web**, если нужен).
3. Подтвердите перезапись файлов, если спросит.

После успешного выполнения появятся:

| Файл | Назначение |
| --- | --- |
| `lib/firebase_options.dart` | Ключи и options для `Firebase.initializeApp` |
| `android/app/google-services.json` | Конфиг Android |
| `ios/Runner/GoogleService-Info.plist` | Конфиг iOS |
| `firebase.json` | Конфиг CLI (деплой rules/functions) |

> **Не редактируйте** `firebase_options.dart` вручную — при смене проекта снова запустите `flutterfire configure`.

---

## 5. Пакеты в pubspec.yaml

Минимум для старта — только `firebase_core`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  firebase_core: ^3.13.0
```

Для E-Chat добавьте пакеты по мере разработки экранов:

```yaml
  firebase_auth: ^5.5.2          # Login / OTP
  cloud_firestore: ^5.6.6        # чаты, сообщения, профиль
  firebase_database: ^11.3.4     # online, typing
  firebase_storage: ^12.4.4      # аватары, медиа
  firebase_messaging: ^15.2.4    # push-уведомления
```

Установка:

```bash
flutter pub get
```

Актуальные версии: [pub.dev — FlutterFire](https://firebase.google.com/support/release-notes/flutter).

---

## 6. Настройка Android

### 6.1. Google Services plugin

`android/settings.gradle.kts` — добавьте плагин в блок `plugins`:

```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

`android/app/build.gradle.kts` — подключите плагин:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}
```

### 6.2. minSdk для Firebase Auth (Phone)

Phone Auth требует **minSdk 23+**:

```kotlin
defaultConfig {
    applicationId = "com.example.flutter_echat"
    minSdk = 23
    // ...
}
```

### 6.3. Проверка файла

Убедитесь, что существует:

```
android/app/google-services.json
```

---

## 7. Настройка iOS

### 7.1. Конфиг

После `flutterfire configure` должен быть файл:

```
ios/Runner/GoogleService-Info.plist
```

### 7.2. CocoaPods

```bash
cd ios
pod install
cd ..
```

### 7.3. Минимальная версия iOS

В `ios/Podfile` обычно достаточно iOS 13+ (FlutterFire подтягивает требования плагинов автоматически).

### 7.4. Запуск

Первый запуск на симуляторе/устройстве:

```bash
flutter run -d ios
```

Для **Phone Auth** на iOS позже понадобятся Push Notifications и APNs key — см. [firebase-setup.md §7](./firebase-setup.md#7-authentication-телефон--otp).

---

## 8. Настройка Web (опционально)

Если при `flutterfire configure` выбрали **web**:

1. В `web/index.html` FlutterFire может добавить скрипты Firebase — не удаляйте их.
2. Запуск:

```bash
flutter run -d chrome
```

Для production настройте авторизованные домены:  
Firebase Console → **Authentication** → **Settings** → **Authorized domains**.

---

## 9. Инициализация в main.dart

Firebase нужно инициализировать **до** `runApp`, асинхронно:

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

Импорт `firebase_options.dart` — относительный, файл лежит в `lib/`.

### Порядок инициализации других сервисов

Рекомендуемый порядок в `main()` для E-Chat:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FCM — после core, до runApp
  // await FirebaseMessaging.instance.requestPermission();

  runApp(const MyApp());
}
```

---

## 10. Проверка подключения

### 10.1. Запуск приложения

```bash
flutter clean
flutter pub get
flutter run
```

Ошибок вида `[core/no-app]`, `FirebaseApp not initialized` быть не должно.

### 10.2. Тест Firestore (временный код)

Добавьте в `main()` после инициализации или на кнопку:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testFirebase() async {
  final doc = FirebaseFirestore.instance.collection('_ping').doc('test');
  await doc.set({
    'ok': true,
    'at': FieldValue.serverTimestamp(),
  });
  debugPrint('Firebase Firestore: OK');
}
```

В [Firebase Console](https://console.firebase.google.com/) → **Firestore** → коллекция `_ping` должна появиться после вызова (если Firestore уже создан и rules разрешают запись).

### 10.3. Лог в консоли

При успешной инициализации FlutterFire не выводит отдельное сообщение — главный признак: приложение стартует без исключений из `firebase_core`.

---

## 11. Что дальше

Firebase **подключён** к Flutter, когда есть:

- [x] `lib/firebase_options.dart`
- [x] `Firebase.initializeApp` в `main.dart`
- [x] нативные конфиги (Android / iOS)
- [x] пакет `firebase_core` в `pubspec.yaml`

Дальнейшие шаги для E-Chat (отдельный документ):

| Шаг | Документ |
| --- | --- |
| Phone Auth, Firestore, Storage, FCM, rules | [firebase-setup.md](./firebase-setup.md) |
| Коллекции и поля | [firebase-database.md](./firebase-database.md) |
| Отслеживание событий | [firebase-events.md](./firebase-events.md) |

Краткий порядок:

1. В Console включить **Authentication → Phone**
2. Создать **Firestore** и **Storage**
3. Задеплоить rules: `firebase deploy --only firestore:rules,storage`
4. Реализовать экраны Login → OTP → Profile

---

## 12. Частые проблемы

| Ошибка | Решение |
| --- | --- |
| `flutterfire: command not found` | `dart pub global activate flutterfire_cli`, добавить Pub Cache в PATH |
| `No Firebase App '[DEFAULT]' has been created` | Вызовите `Firebase.initializeApp` до использования любого Firebase API |
| `MissingPluginException` | `flutter clean`, пересборка; на iOS — `pod install` |
| Android: `File google-services.json is missing` | Запустите `flutterfire configure` снова |
| Android: `minSdkVersion X cannot be smaller than 23` | Установите `minSdk = 23` в `build.gradle.kts` |
| iOS: build failed после Firebase | `cd ios && pod deintegrate && pod install` |
| `firebase_options.dart` не найден | Импорт: `import 'firebase_options.dart';` (файл в `lib/`) |
| Разные проекты на Android и iOS | Один `flutterfire configure`, один Firebase project |

---

## Шпаргалка команд

```bash
# Подключение / обновление конфигов
flutterfire configure

# Зависимости
flutter pub get

# Запуск
flutter run

# iOS pods
cd ios && pod install && cd ..
```

---

## Связанные ссылки

- [Официальная документация: Add Firebase to Flutter](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup#install-cli)
- [firebase-setup.md](./firebase-setup.md) — настройка сервисов под E-Chat
- [firebase-database.md](./firebase-database.md) — структура Firestore
- [firebase-events.md](./firebase-events.md) — Console, логи Functions, Analytics
