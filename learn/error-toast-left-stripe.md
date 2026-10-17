# Как сделать то, что обведено красным?

Красная вертикальная полоска слева у карточки баннера ошибки (`TErrorToast`).

В макете (`docs/design_kimi/tokens.css`):

```css
.toast-error {
  border-left: 4px solid var(--error);
}
```

## Почему не `Border(left: …)` + `borderRadius`

В Flutter скругление (`borderRadius`) работает только у **одинаковой** рамки со всех сторон. `BoxDecoration(border: Border(left: …), borderRadius: …)` не сработает.

## Как делать

Полоску рисуют отдельным ребёнком и **обрезают** карточку (`clipBehavior`). Тогда 4 px слева скругляются вместе с углами.

```dart
Material(
  color: Theme.of(context).colorScheme.surface,
  elevation: 8,
  shadowColor: TColors.error500.withValues(alpha: 0.22),
  borderRadius: BorderRadius.circular(14),
  clipBehavior: Clip.antiAlias, // скругляет и полоску
  child: IntrinsicHeight(
    child: Row(
      children: [
        ColoredBox(
          color: TColors.error500, // light; в dark — error400
          child: const SizedBox(width: 4),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            child: Row(
              children: [
                // иконка, текст, крестик
              ],
            ),
          ),
        ),
      ],
    ),
  ),
)
```

- `ColoredBox` шириной **4** — обведённая полоска.
- `clipBehavior: Clip.antiAlias` + `borderRadius: 14` обрезают её по левым углам.
- `IntrinsicHeight` растягивает полоску на всю высоту тоста.

Цвет — токены: light `TColors.error500` (`#F44336`), dark `TColors.error400` (`#F6695E`).

Не использовать `VerticalDivider`: у него отступы, угол не зальётся.
