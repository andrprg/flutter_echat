# Макет: авторизация Email / Password (по Figma E-Chat)

Источник phone: [Figma E-Chat, node 21-122](https://www.figma.com/design/Do69JP5vfRzBNw3OO2jRHH/Chatting-App-UI-Kit-Design-_-E-Chat-_-Figma--Community-?node-id=21-122)

**Референс из кита:** [ref-login-signup-phone.png](./ref-login-signup-phone.png) — Login / Register / Verification (телефон + SMS).  
**Интерактив (адаптация под Email/Password):** [auth-email.html](./auth-email.html)

Токены и шрифт Roboto — как в [layouts-tablet-desktop.md](../layouts-tablet-desktop.md). Primary CTA: `#40C4FF` / `gradientLightBlue`.

---

## 1. Что в Figma (phone)

| Экран | Содержимое |
| --- | --- |
| **Login _ Empty / Typing / Filled** | Синяя «волна», заголовок Login, pill **Register**, underline phone (+флаг), Remember me, круглая стрелка |
| **Register _ *** | Волна, Login← pill, phone underline, круглая стрелка |
| **Verification _ Empty / Filled / Error / Resent** | 4 слота кода, таймер / Resend, Error code |

Клавиатура в ките — numeric (телефон / OTP).

---

## 2. Адаптация под Email / Password

SMS Verification **не** реализуем в MVP (Firebase Email/Password). Та же композиция Figma, другие поля:

| Figma | Этот макет |
| --- | --- |
| Phone + флаг страны | **Email** (underline) |
| Verification (4 цифры) | не входит; опционально **Forgot password** отдельным экраном |
| Numeric keyboard | **QWERTY** при фокусе на Email / Password |
| Одна строка ввода на Login | **Email** + **Password** (два underline) |
| Register: phone | Register: **Name** + **Email** + **Password** |

Без изменений относительно кита:

- синий header с волнистым низом (~30–35% высоты);
- заголовок белым слева (Login / Register);
- pill-кнопка перехода (Register / Login←) в углу волны;
- underline-инпуты (не boxed `Card Input`);
- круглая primary-кнопка со стрелкой **справа** над клавиатурой;
- Remember me — круглый checkbox;
- состояния Empty / Typing / Filled (+ Error на Login).

---

## 3. Login (Email / Password)

### Композиция (сверху вниз)

1. Status bar  
2. **Wave header** — `Login` + subtitle «Enter your email and password» + pill `Register`  
3. Белая зона:  
   - label + underline **Email**  
   - label + underline **Password** (+ eye trailing)  
   - **Remember me** (checkbox) · ссылка **Forgot password?**  
   - **FAB стрелка** (справа)  
4. При Typing / Filled — системная QWERTY внизу  
5. Home indicator  

### Состояния

| State | Email | Password | Remember | FAB |
| --- | --- | --- | --- | --- |
| Empty | placeholder | placeholder | off | dimmed / inactive |
| Typing | фокус + каретка | пусто | off | inactive |
| Filled | `alex.rivera@mail.com` | `••••••••` | on | active |
| Error | filled | filled | on | active; красный underline + «Wrong email or password» |

---

## 4. Register (Sign Up)

1. Wave — pill `← Login`, заголовок `Register`, subtitle «Create your account»  
2. Underline: **Name**, **Email**, **Password**  
3. Checkbox Terms (опционально; в Figma Register его нет на phone — можно опустить на phone, оставить на wide)  
4. FAB стрелка справа  

Состояния: Empty / Typing / Filled / Error (email уже занят — красный underline у Email).

---

## 5. Forgot password (дополнение, не в Figma-кадре)

Тот же wave-header (`Forgot password`, pill `← Login`), одно поле Email, FAB стрелка.  
Sent: subtitle «Check your inbox», без FAB.

---

## 6. Tablet / Desktop

| | |
| --- | --- |
| Phone | 393×852, как референс |
| Tablet | центрированный phone-frame или карточка max 400 с той же волной |
| Desktop | split: brand-панель (gradient) + форма с волной / без полного phone chrome |

Один smart-controller; dumb-view параметризуется breakpoint’ом (`MaxWidthBox`).

---

## 7. Компоненты → Flutter

| Figma / макет | Виджет |
| --- | --- |
| Wave header + title + pill | `TAuthHeader` (новый shared) |
| Underline Email / Password / Name | `TUnderlineField` / адаптация `TTextField` |
| Remember me | `TCheckbox` (круглый вариант из кита) |
| FAB стрелка | `TCircleArrowButton` |
| QWERTY | системная клавиатура ОС |

---

## 8. Навигация

```
/login  ↔  /register
/login  →  /forgot-password
успех   →  guard → /chats | /signup/profile | /security
```

См. [firebase-registration.md](../firebase-registration.md).
