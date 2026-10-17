# Code review: `TErrorBannerWidget`

Дата: 2026-10-17  
Контекст: `lib/src/shared/widgets/t_error_banner_widget.dart` (+ связь с `error_banner_provider`, §10.5 `architecture_echat.md`, Widgetbook).

---

## Вердикт

**Request changes.** Визуально близко к toast-error, но виджет нарушает контракт dumb/`TErrorToast`, а `SnackBar` + `showCloseIcon` ломают закрытие и расходятся с §10.5 (глобальный баннер ≠ `ScaffoldMessenger`).

---

## Что сделано хорошо

- Токены light/dark (`error500`/`error400`, `error50`/`error50Dark`, `neutral800`) совпадают с dartdoc и макетом.
- Текст берётся из `Failure.displayMessage`, не из сырого `String` в UI-state.
- `kAlwaysCompleteAnimation` осознанно закрывает assert `SnackBar` вне messenger (см. комментарий).
- Левая полоска + круглая иконка; `Align` у иконки из‑за `CrossAxisAlignment.stretch` — корректный workaround.
- Отступы `leftMargin` / `rightMargin` удобны для адаптивного хоста.

---

## Findings

### [blocker] `ConsumerWidget` в `shared/widgets` — нарушение dumb-слоя
- Где: `TErrorBannerWidget extends ConsumerWidget` + `ref.watch(errorBannerProvider)`
- Что: shared-виджет знает про Riverpod и провайдер.
- Почему: `layer-presentation` / `architecture-dos-donts` / §10.5 требуют dumb: props `message` + `onClose`, без `WidgetRef`. Хост (`MaterialApp.builder` / smart) должен `watch` и передавать данные.
- Статус: fixed — `StatelessWidget`, props `message` + `onClose`
- Направление: `StatelessWidget` с `message` / `onClose` (как `TErrorToast` в доках); опционально тонкая smart-обёртка рядом с `EChatApp`, не в shared dumb.

### [blocker] `showCloseIcon` не закрывает баннер через `errorBannerProvider`
- Где: `SnackBar(showCloseIcon: true, …)`
- Что: кнопка close в Material вызывает `ScaffoldMessenger.of(context).hideCurrentSnackBar`, а не `errorBannerProvider.notifier.dismiss()`. Swipe `Dismissible` внутри `SnackBar` — то же (`removeCurrentSnackBar`).
- Почему: виджет встраивается в `Stack` / Widgetbook, не через `showSnackBar`. Закрытие либо no-op / ошибка отсутствия messenger, либо не сбрасывает keepAlive-стейт → баннер «залипает» или кнопка бесполезна.
- Статус: fixed — своя `IconButton` + `Dismissible` → `onClose`
- Направление: своя кнопка close → `onClose`; не опираться на API `SnackBar` dismiss.

### [major] `SnackBar` как кастомная карточка — антипаттерн относительно §10.5
- Где: `return SnackBar(...)` + `animation: kAlwaysCompleteAnimation`
- Что: архитектура явно запрещает локальный/`ScaffoldMessenger` snackbar для ошибок действия; нужен свой overlay-toast сверху, max width 480.
- Почему: хак с animation, чужой dismiss/semantics/duration, позиция по умолчанию «bottom floating», лишняя связанность с Material snackbar lifecycle.
- Статус: fixed — `Material` + `Dismissible`, `maxWidth: TSizes.maxFormWidth`
- Направление: `Material` / `DecoratedBox` + `Row` (полоска, иконка, текст, close) без `SnackBar`.

### [major] Имя и контракт расходятся с документацией
- Где: класс `TErrorBannerWidget` / файл `t_error_banner_widget.dart`
- Что: §10.5 и дерево в `architecture_echat.md` — dumb `TErrorToast` (`t_error_toast.dart`), props `message` + `onClose`, max 480.
- Почему: дрейф имени и API усложняет интеграцию хоста и ревью по чеклисту.
- Статус: open — API выровнен (`message` + `onClose`, max 480); имя `TErrorBannerWidget` оставлено как у соседних `T*Widget`
- Направление: либо переименовать/выровнять API под `TErrorToast`, либо обновить §10.5 одним коммитом с UI.

### [major] Длинный текст: overflow / обрезка
- Где: `Text(message)` в `Row` без `Expanded`/`Flexible`; фиксированный `SizedBox(height: 48)`
- Что: длинный `displayMessage` → horizontal overflow; многострочность обрежется по высоте 48.
- Почему: реальные `Failure` (сеть, firestore) часто длиннее одной короткой строки.
- Статус: fixed — `Expanded` + `maxLines: 2` + `ellipsis`, `minHeight: 48` через `IntrinsicHeight`
- Направление: `Expanded` + `maxLines` / `overflow: ellipsis` (или min height + padding без жёстких 48).

### [minor] Пустой баннер при `errorBannerProvider == null`
- Где: `?.failure.displayMessage ?? ''` — виджет всё равно рисует полный `SnackBar`
- Что: UseCase `Empty` в Widgetbook показывает пустую карточку.
- Почему: видимость должна решать хост (`if (state != null) …`); dumb лучше принимать non-empty `message` или не монтироваться.
- Статус: fixed — `message` обязателен; видимость у хоста / Widgetbook StatefulBuilder

### [minor] Цвет текста не зафиксирован токенами из dartdoc
- Где: `titleLarge?.copyWith(fontSize: 14, height: 1.35)` без `color`
- Что: dartdoc: light `neutral900`, dark `#FFFFFF`; фактически — `onSurface` темы.
- Почему: риск расхождения с макетом при смене text theme.
- Статус: fixed — light `neutral900`, dark `white`

### [suggestion] Safe area внутри shared-виджета
- Где: `MediaQuery.of(context).padding.top` в margin
- Что: отступ статус-бара зашит в UI-компонент.
- Почему: для dumb лучше `SafeArea` у хоста или параметр `topMargin`.
- Статус: open

### [suggestion] `///` на детях `Row` вместо `//`
- Где: строки с «Иконка ошибки» / «Текст ошибки»
- Что: `///` — dartdoc; внутри метода это обычный комментарий, лучше `//`.
- Статус: fixed — комментарии убраны вместе с рефакторингом

### [info] Хост в `lib/` ещё не подключён
- Где: grep — потребители кроме Widgetbook отсутствуют
- Что: WIP; без smart-хоста + `dismiss`/`ValueKey` фича неполная (см. `codereview/2026-10-16-error-banner-provider.md`).
- Статус: open

---

## Чеклист перед merge

- [x] Вынести Riverpod в хост; shared — dumb props
- [x] Закрытие только через `onClose` → `dismiss()` (не `showCloseIcon` у `SnackBar`)
- [x] Заменить `SnackBar` на свою карточку (или явно пересмотреть §10.5)
- [x] Выровнять имя с доками (`TErrorBannerWidget` vs `TErrorToast` в §10.5)
- [x] `maxWidth: TSizes.maxFormWidth` (480)
- [x] Защита длинного текста (`Expanded` + overflow)
- [ ] Хост: показывать виджет только при ненулевом state + `ValueKey` для повторного show
- [x] Ключ `Dismissible` не от текста сообщения (см. ревью #2)

---

## Ревью #2 — 2026-10-17 (повторный проход)

### Вердикт

**Approve** для самого виджета. Блокеры сняты: dumb props, своя карточка, close/swipe → `onClose`, max width 480, токены текста, длинный текст. До merge фичи остаётся хост + пара nits.

### Статус прошлых findings

| Finding | Статус |
| --- | --- |
| ConsumerWidget / Riverpod в shared | **fixed** |
| `showCloseIcon` / SnackBar dismiss | **fixed** |
| SnackBar как карточка | **fixed** (`Material` + shell) |
| Имя vs `TErrorToast` | **open** (API ок; дрейф имени в §10.5) |
| Overflow длинного текста | **fixed** (`maxLines: 2`) |
| Пустой баннер при null | **fixed** |
| Цвет текста токенами | **fixed** |
| Safe area в shared | **open** (acceptable для overlay-shell) |
| `///` в Row | **fixed** |
| Нет хоста в `lib/` | **open** |

### Что улучшилось

- Разбиение на `_ErrorBannerShell` / `_ErrorBannerCard` / body / accent / icon — читаемо.
- Dartdoc с контрактом хоста и примером `ValueKey(identityHashCode(banner))`.
- Widgetbook без Riverpod; usecase `Long message`; закрытие через StatefulBuilder.

### Findings (актуальные)

#### [minor] `Dismissible.key = ValueKey(message)` хрупкий
- Где: `_ErrorBannerShell` → `Dismissible(key: ValueKey<String>(message), …)`
- Что: ключ завязан на текст. Повторный `show` с тем же `displayMessage` без смены внешнего `Key` у `TErrorBannerWidget` → типичный assert «dismissed Dismissible is still part of the tree». Два разных `Failure` с одинаковым текстом тоже не различит.
- Почему: в dartdoc уже рекомендован `ValueKey(identityHashCode(banner))` на корне — этого достаточно для remount; внутренний ключ от `message` дублирует и ослабляет контракт.
- Статус: fixed — стабильный `_kDismissibleKey`; remount через `Key` у `TErrorBannerWidget`; dartdoc усилен; Widgetbook — `UniqueKey()`; `resizeDuration: null`

#### [suggestion] Нет `Semantics(liveRegion: true)`
- Где: `_ErrorBannerCard` / shell
- Что: раньше `SnackBar` давал live region для screen readers; сейчас тихий `Material`.
- Почему: ошибки действия должны объявляться a11y.
- Статус: open

#### [suggestion] `Dismissible.resizeDuration`
- Где: `Dismissible` в shell
- Что: дефолтный resize после swipe может кратко «схлопывать» карточку; для тоста часто ставят `resizeDuration: null`.
- Статус: fixed — `resizeDuration: null`

#### [suggestion] Safe area / top inset в shell
- Где: `MediaQuery.paddingOf(context).top + 8`
- Что: оставлено в shared overlay-shell (не чистый «только paint» dumb).
- Почему: для глобального тоста приемлемо; альтернатива — `topMargin` с хоста.
- Статус: open (не блокер)

#### [info] Хост в приложении всё ещё отсутствует
- Где: `lib/` — нет call-site кроме самого виджета
- Что: без `MaterialApp.builder` + `if (banner != null)` фича неполная
- Статус: open

#### [info] Имя `TErrorBannerWidget` vs `TErrorToast` в доках
- Где: `architecture_echat.md` §10.5, dartdoc провайдера
- Что: API совпал с контрактом toast; имя файла/класса — в стиле `TButtonWidget` / `TAvatarWidget`
- Статус: fixed — §10.5 / дерево / DO + `error_banner_provider` → `TErrorBannerWidget`; хост-пример с `ObjectKey`

### Чеклист #2

- [ ] Хост в `EChatApp` + `ValueKey` на баннере
- [x] Смягчить/убрать `ValueKey(message)` у `Dismissible`
- [ ] (опц.) `Semantics(liveRegion: true)`
- [x] Обновить §10.5: `TErrorBannerWidget` вместо `TErrorToast`

---

## Ревью #3 — 2026-10-17 (повторный проход)

### Вердикт

**Approve.** Актуальный код (277 строк) соответствует контракту dumb toast: props, `Material`-карточка, close/swipe → `onClose`, стабильный `_kDismissibleKey` + remount через внешний `Key`, `resizeDuration: null`, `maxWidth: TSizes.maxFormWidth`, текст с токенами и `maxLines: 2`. Блокеров и новых major нет.

### Код (проверка)

- `StatelessWidget` + `message` / `onClose` / margins — без Riverpod
- Shell: safe-area top, Align topCenter, ConstrainedBox 480, `Dismissible(up)` → `onClose`
- Card: elevation 6, accent bar 8px, icon 28, `IconButton` close с tooltip
- Widgetbook: `_bannerKey` только при повторном «Показать»; knobs не ломают mount
- Потребителей в `lib/` (хост `EChatApp`) по-прежнему нет

### Статус findings ревью #2

| Finding | Статус |
| --- | --- |
| `ValueKey(message)` у Dismissible | **fixed** |
| `resizeDuration` | **fixed** |
| Semantics liveRegion | **open** |
| Safe area в shell | **open** (accepted) |
| Хост в `lib/` | **open** |
| Имя vs `TErrorToast` в §10.5 | **fixed** — `TErrorBannerWidget` + `ErrorBannerState?` / named `show` |

### Findings (новые / мелкие)

#### [suggestion] В dartdoc предпочтительнее `ObjectKey(banner)`
- Где: пример хоста в class-doc `TErrorBannerWidget`
- Что: сейчас `ValueKey(identityHashCode(banner))` — работает; `ObjectKey(banner)` выражает тот же контракт (identity) без ручного хеша.
- Статус: fixed — example → `ObjectKey(banner)` (+ §10.5)

#### [suggestion] Комментарий Widgetbook «StatefulBuilder»
- Где: `widgetbook/.../t_error_banner.dart` — doc у `_ErrorBannerPreview`
- Что: фактически `StatefulWidget` / `State`, не `StatefulBuilder`
- Статус: fixed

### Чеклист #3

- [ ] Хост в `EChatApp` + `ObjectKey(banner)` / `ValueKey(identityHashCode(banner))`
- [ ] (опц.) `Semantics(liveRegion: true)` на карточке
- [x] Обновить §10.5 / dartdoc провайдера: `TErrorBannerWidget`
- [x] (опц.) dartdoc виджета: `ObjectKey(banner)`
- [x] (опц.) Widgetbook comment «StatefulBuilder»
