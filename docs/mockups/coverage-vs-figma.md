# Покрытие макетов tablet/desktop vs Figma E-Chat

Источник phone: [Figma E-Chat, node 21-122](https://www.figma.com/design/Do69JP5vfRzBNw3OO2jRHH/Chatting-App-UI-Kit-Design-_-E-Chat-_-Figma--Community-?node-id=21-122)  
Инвентарь: **89** уникальных фреймов × Light/Dark = **178** (в docs — 176–178).  
HTML: [mockups/echat-tablet-desktop.html](./mockups/echat-tablet-desktop.html)

**Вердикт: покрыто ~8% уникальных экранов.** Сделаны только ключевые shell-раскладки и звонки 1:1; большая часть Figma ещё без tablet/desktop-макетов.

Легенда: ✅ есть в HTML · ⚠ частично · ❌ нет

---

## Сводка

| Блок Figma | Уник. экранов (ориентир) | В HTML |
| --- | ---: | --- |
| Loading / Introduce | ~7 | ❌ |
| Login / Sign Up / User Info | ~12 | ✅ Login · Sign Up / User Info ❌ |
| Face / Touch / PIN / Notification | ~10 | ✅ PIN · Touch · Face (Notification ❌) |
| Chats list / Search / Add menu | ~5 | ⚠ list + empty |
| Conversation (+ states) | ~12 | ⚠ базовая переписка |
| Call / Calling / Video | 3 | ✅ |
| User / Group Information | ~10 | ✅ User Info · Group Info |
| Add Friend / Create Group | ~5 | ❌ |
| Groups (list, chat, calls) | ~10 | ⚠ звонки ✅ · list/chat ❌ |
| Profile / Edit / Logout | ~3 | ✅ Profile · Profile Edit |
| More / Security / Help | ~8 | ✅ More · Invite · Security |
| Notification center | ~2 | ❌ |
| COMING SOON | — | не для MVP |

---

## Детальный чеклист

### Onboarding

| Экран Figma | Tablet/Desktop макет |
| --- | --- |
| Loading _ Start / Middle / Done | ❌ |
| Introduce _ Step 1–4 | ❌ |

### Auth

| Экран Figma | Статус |
| --- | --- |
| Login _ Empty / Typing / Filled | ✅ Login · Login 2 · Login 3 |
| Sign Up _ * | ✅ Sign Up · Sign Up 2 · Sign Up 3 · Sign Up Err |
| Verification _ Empty / Filled / Error / Resent | ❌ |
| Sign Up _ User Information | ❌ |

### Security

| Экран Figma | Статус |
| --- | --- |
| Set / Setting _ Face ID (+ Done, Scanning) | ✅ Face · Face 2 · Face 3 |
| Set / Setting _ Touch ID (+ Done, Scanning) | ✅ Touch · Touch 2 · Touch 3 |
| Set / Setting _ PIN Security (+ Done, Scanning) | ✅ PIN · PIN 2 · PIN 3 |
| Setting _ Notification | ❌ |

### Chats

| Экран Figma | Статус |
| --- | --- |
| Chats (home list) | ✅ |
| Chats _ empty detail (wide) | ✅ |
| Chats _ Click Search | ⚠ поле поиска есть, отдельного экрана нет |
| Chats _ Click Add / PopUp Add | ❌ |
| Chats _ Conversation | ⚠ базовые bubbles |
| Conversation _ Typing / Attachment / Record / Custom | ❌ |
| Chats _ Call | ✅ |
| Chats _ Calling | ✅ |
| Chats _ Video Calling | ✅ |
| Chats _ User Information (+ Media, Links, Docs, Custom, Protected) | ✅ User Info |
| Chats _ User Information 2 (Report / Block) | ✅ User Info 2 |
| User Information _ Media | ✅ Media |
| User Information _ Links | ✅ Links |
| User Information _ Documents | ✅ Documents |
| User Information _ Protected Chat | ✅ Protected |
| Chats _ Group Information | ✅ Group Info |
| Chats _ Group Information 2 (Report / Leave) | ✅ Group Info 2 |

### Add Function

| Экран Figma | Статус |
| --- | --- |
| Add Friend (+ Searching) | ❌ |
| Create Group | ❌ |
| Added Members | ❌ |

### Groups

| Экран Figma | Статус |
| --- | --- |
| Groups (list) | ❌ |
| Groups _ Conversation (+ Custom) | ❌ |
| Groups _ Call / Calling / Video Calling | ✅ G Call · G Calling · G Video · G Calling 2 · G Video 2 |

### Profile & More

| Экран Figma | Статус |
| --- | --- |
| Profile | ✅ John Lennon + fields + Edit / Logout |
| Profile _ Edit | ✅ sheet/modal Cancel · Save |
| Logout | ✅ кнопка на Profile |
| More (Language, Dark Mode, Mute, Invite, Security, Help, Logout) | ✅ More |
| Invite Friends | ✅ Invite |
| Security / Security 2 (Change PIN) | ✅ Security · Security 2 |
| Help Center, Terms, About (отдельные) | ❌ (пункты в More) |
| Notification (in-app) | ❌ |

### COMING SOON (Figma)

Не входят в макеты MVP: Smart Replies, Chat Bots, Game Onlines, Dating и т.п.

---

## Что уже есть в HTML (кнопки тулбара)

1. Chats (master–detail + conversation)  
2. Empty (list без выбора)  
3. Profile / Profile Edit  
4. Auth (Login)  
5. Call  
6. Calling  
7. Video Calling  
8. User Info (Chats _ User Information)  
9. User Info 2 (Report / Block)  
10. Media / Links / Documents / Protected  
11. Group Info / Group Info 2  

Форм-факторы: Tablet 768 · Desktop 1440 · Light · Dark.

---

## Рекомендуемый порядок доделки

1. **P0:** Introduce, Groups list+conversation, More, Add Friend dialog  
2. **P1:** Conversation states (typing, attachment, record), Create Group  
3. **P2:** Help Center, Notification, Groups list/chat  

Обновлять этот файл при добавлении экранов в HTML.
